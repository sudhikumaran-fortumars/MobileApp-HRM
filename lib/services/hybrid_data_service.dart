import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'database_helper.dart';
import 'firebase_service.dart';
import 'enhanced_otp_auth_service.dart';
import '../main.dart';

class HybridDataService {
  static final DatabaseHelper _dbHelper = DatabaseHelper();
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static Employee? _currentEmployee;
  static List<AttendanceRecord> _attendanceHistory = [];
  static List<LeaveRequest> _leaveRequests = [];

  // ==================== INITIALIZATION ====================

  static Future<void> initialize() async {
    try {
      // Initialize local database
      await _dbHelper.database;

  // Load current employee from GlobalState (new authentication system)
  _currentEmployee = GlobalState.currentEmployee;

      // Load attendance history
      if (_currentEmployee != null) {
        _attendanceHistory = await _dbHelper.getAttendanceRecords(_currentEmployee!.empId);
        _leaveRequests = await _dbHelper.getLeaveRequests(_currentEmployee!.empId);
      }

      // Sync data with Firebase in background
      _syncWithFirebase();
    } catch (e) {
      print('Hybrid data service initialization error: $e');
    }
  }

  // ==================== AUTHENTICATION ====================

  static Future<Map<String, dynamic>> loginWithOTP(String phoneNumber, String countryCode) async {
    return await EnhancedOTPAuthService.sendOTP(phoneNumber, countryCode);
  }

  static Future<Map<String, dynamic>> verifyOTP(String otp) async {
    return await EnhancedOTPAuthService.verifyOTP(otp);
  }

  static Future<Map<String, dynamic>> loginWithCredentials(String username, String password) async {
    return await EnhancedOTPAuthService.loginWithCredentials(username, password);
  }

  static Future<void> signOut() async {
    GlobalState.currentEmployee = null;
    _currentEmployee = null;
    _attendanceHistory.clear();
    _leaveRequests.clear();
  }

  // ==================== EMPLOYEE MANAGEMENT ====================

  static Employee? get currentEmployee => GlobalState.currentEmployee;

  static Future<void> updateEmployeeProfile(Employee updatedEmployee) async {
    try {
      // Update local database
      await _dbHelper.updateEmployee(updatedEmployee);
      
      // Update GlobalState
      GlobalState.currentEmployee = updatedEmployee;

      // Update Firebase in background
      _updateEmployeeInFirebase(updatedEmployee);
    } catch (e) {
      print('Update employee profile error: $e');
    }
  }

  static Future<void> _updateEmployeeInFirebase(Employee employee) async {
    try {
      await _firestore.collection('employees').doc(employee.empId).update({
        'name': employee.name,
        'email': employee.email,
        'phone': employee.phone,
        'department': employee.department,
        'position': employee.role,
        'profilePictureUrl': employee.profileImagePath,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Firebase employee update error: $e');
    }
  }

  // ==================== ATTENDANCE MANAGEMENT ====================

  static Future<Map<String, dynamic>> checkIn({
    required String method,
    String? location,
    Uint8List? photo,
  }) async {
    // Use GlobalState.currentEmployee instead of local _currentEmployee
    final currentEmployee = GlobalState.currentEmployee;
    if (currentEmployee == null) {
      return {'success': false, 'message': 'No employee logged in'};
    }

    try {
      final now = DateTime.now();
      final today = now.toIso8601String().split('T')[0];

      // Check if already checked in today
      final todayAttendance = await _dbHelper.getTodayAttendance(currentEmployee.empId);
      if (todayAttendance != null && todayAttendance.checkIn != null) {
        return {'success': false, 'message': 'Already checked in today'};
      }

      // Upload photo if provided
      if (photo != null) {
        await FirebaseService.uploadAttendancePhoto(
          currentEmployee.empId,
          photo,
          now.millisecondsSinceEpoch.toString(),
        );
      }

      // Create attendance record
      final attendanceRecord = AttendanceRecord(
        date: today,
        checkIn: now.toIso8601String(),
        checkOut: null,
        status: 'In Progress',
        hours: 0.0,
        location: location ?? 'Office',
        method: method,
      );

      // Save to local database
      await _dbHelper.insertAttendanceRecord(attendanceRecord);
      final newRecord = attendanceRecord; // AttendanceRecord doesn't have copyWith

      // Update local state
      _attendanceHistory.insert(0, newRecord);
      GlobalState.isCheckedIn = true;
      GlobalState.checkInTime = now.toIso8601String();
      GlobalState.checkInMethod = method;

      // Sync with Firebase in background
      _syncAttendanceToFirebase(newRecord);

      return {
        'success': true,
        'message': 'Checked in successfully',
        'attendance': newRecord,
      };
    } catch (e) {
      print('Check in error: $e');
      return {'success': false, 'message': 'Check in failed: $e'};
    }
  }

  static Future<Map<String, dynamic>> checkOut({
    required String method,
    String? location,
    Uint8List? photo,
  }) async {
    // Use GlobalState.currentEmployee instead of local _currentEmployee
    final currentEmployee = GlobalState.currentEmployee;
    if (currentEmployee == null) {
      return {'success': false, 'message': 'No employee logged in'};
    }

    try {
      final now = DateTime.now();

      // Get today's attendance record
      final todayAttendance = await _dbHelper.getTodayAttendance(currentEmployee.empId);
      if (todayAttendance == null || todayAttendance.checkIn == null) {
        return {'success': false, 'message': 'Not checked in today'};
      }

      if (todayAttendance.checkOut != null) {
        return {'success': false, 'message': 'Already checked out today'};
      }

      // Upload photo if provided
      if (photo != null) {
        await FirebaseService.uploadAttendancePhoto(
          currentEmployee.empId,
          photo,
          now.millisecondsSinceEpoch.toString(),
        );
      }

      // Calculate work hours
      final checkInTime = DateTime.parse(todayAttendance.checkIn!);
      final workHours = DateTime.now().difference(checkInTime).inMinutes / 60.0;

      // Create updated attendance record
      final updatedRecord = AttendanceRecord(
        date: todayAttendance.date,
        checkIn: todayAttendance.checkIn,
        checkOut: now.toIso8601String(),
        status: 'Completed',
        hours: workHours,
        location: todayAttendance.location,
        method: todayAttendance.method,
      );

      // Update local database
      await _dbHelper.updateAttendanceRecord(updatedRecord);

      // Update local state
      final index = _attendanceHistory.indexWhere((r) => r.date == updatedRecord.date);
      if (index != -1) {
        _attendanceHistory[index] = updatedRecord;
      }

      GlobalState.isCheckedIn = false;
      GlobalState.checkInTime = null;
      GlobalState.checkInMethod = null;

      // Sync with Firebase in background
      _syncAttendanceToFirebase(updatedRecord);

      return {
        'success': true,
        'message': 'Checked out successfully',
        'attendance': updatedRecord,
      };
    } catch (e) {
      print('Check out error: $e');
      return {'success': false, 'message': 'Check out failed: $e'};
    }
  }

  static Future<void> _syncAttendanceToFirebase(AttendanceRecord record) async {
    try {
      final data = {
        'employeeId': record.date, // Using date as identifier for now
        'checkInTime': record.checkIn,
        'checkOutTime': record.checkOut,
        'checkInMethod': record.method,
        'checkOutMethod': record.method,
        'checkInLocation': record.location,
        'checkOutLocation': record.location,
        'checkInPhoto': null,
        'checkOutPhoto': null,
        'workHours': record.hours,
        'breakTimeMinutes': 0,
        'date': record.date,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      // Use date as document ID since AttendanceRecord doesn't have id
      await _firestore.collection('attendance').doc(record.date).set(data);
    } catch (e) {
      print('Firebase attendance sync error: $e');
    }
  }

  // ==================== LEAVE MANAGEMENT ====================

  static Future<Map<String, dynamic>> submitLeaveRequest(LeaveRequest request) async {
    // Use GlobalState.currentEmployee instead of local _currentEmployee
    final currentEmployee = GlobalState.currentEmployee;
    if (currentEmployee == null) {
      return {'success': false, 'message': 'No employee logged in'};
    }

    try {
      // Save to local database
      await _dbHelper.insertLeaveRequest(request);
      final newRequest = request; // LeaveRequest doesn't have copyWith

      // Update local state
      _leaveRequests.insert(0, newRequest);

      // Sync with Firebase in background
      _syncLeaveRequestToFirebase(newRequest);

      return {
        'success': true,
        'message': 'Leave request submitted successfully',
        'request': newRequest,
      };
    } catch (e) {
      print('Submit leave request error: $e');
      return {'success': false, 'message': 'Failed to submit leave request: $e'};
    }
  }

  static Future<void> _syncLeaveRequestToFirebase(LeaveRequest request) async {
    try {
      final data = {
        'employeeId': request.empId,
        'leaveType': request.type,
        'startDate': request.startDate,
        'endDate': request.endDate,
        'reason': request.reason,
        'status': request.status,
        'appliedDate': request.appliedDate.toIso8601String(),
        'approvedBy': null,
        'approvedDate': null,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      // Use empId + startDate as document ID since LeaveRequest doesn't have id
      await _firestore.collection('leave_requests').doc('${request.empId}_${request.startDate}').set(data);
    } catch (e) {
      print('Firebase leave request sync error: $e');
    }
  }

  // ==================== FILE STORAGE ====================

  static Future<String?> uploadProfilePicture(Uint8List imageBytes) async {
    // Use GlobalState.currentEmployee instead of local _currentEmployee
    final currentEmployee = GlobalState.currentEmployee;
    if (currentEmployee == null) return null;

    try {
      final downloadUrl = await FirebaseService.uploadProfilePicture(
        currentEmployee.empId,
        imageBytes,
      );

      if (downloadUrl != null) {
        // Update GlobalState.currentEmployee with new profile image
        final updatedEmployee = Employee(
          empId: currentEmployee.empId,
          name: currentEmployee.name,
          email: currentEmployee.email,
          phone: currentEmployee.phone,
          role: currentEmployee.role,
          department: currentEmployee.department,
          shift: currentEmployee.shift,
          status: currentEmployee.status,
          hourlyRate: currentEmployee.hourlyRate,
          location: currentEmployee.location,
          hasRegisteredFace: currentEmployee.hasRegisteredFace,
          faceData: currentEmployee.faceData,
          faceImagePath: currentEmployee.faceImagePath,
          profileImagePath: downloadUrl,
          faceRegistrationDate: currentEmployee.faceRegistrationDate,
          joinDate: currentEmployee.joinDate,
          address: currentEmployee.address,
          emergencyContact: currentEmployee.emergencyContact,
          emergencyPhone: currentEmployee.emergencyPhone,
          workStats: currentEmployee.workStats,
        );
        GlobalState.currentEmployee = updatedEmployee;
        await updateEmployeeProfile(updatedEmployee);
      }

      return downloadUrl;
    } catch (e) {
      print('Upload profile picture error: $e');
      return null;
    }
  }

  // ==================== DATA RETRIEVAL ====================

  static List<AttendanceRecord> get attendanceHistory => _attendanceHistory;
  static List<LeaveRequest> get leaveRequests => _leaveRequests;

  static Future<List<AttendanceRecord>> getAttendanceHistory() async {
    final currentEmployee = GlobalState.currentEmployee;
    if (currentEmployee != null) {
      _attendanceHistory = await _dbHelper.getAttendanceRecords(currentEmployee.empId);
    }
    return _attendanceHistory;
  }

  static Future<List<LeaveRequest>> getLeaveRequests() async {
    final currentEmployee = GlobalState.currentEmployee;
    if (currentEmployee != null) {
      _leaveRequests = await _dbHelper.getLeaveRequests(currentEmployee.empId);
    }
    return _leaveRequests;
  }

  // ==================== SYNC OPERATIONS ====================

  static Future<void> _syncWithFirebase() async {
    try {
      // Sync employees
      await _syncEmployeesFromFirebase();
      
      // Sync attendance records
      await _syncAttendanceFromFirebase();
      
      // Sync leave requests
      await _syncLeaveRequestsFromFirebase();
    } catch (e) {
      print('Firebase sync error: $e');
    }
  }

  static Future<void> _syncEmployeesFromFirebase() async {
    try {
      final snapshot = await _firestore.collection('employees').get();
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final employee = _mapFirebaseToEmployee(data);
        await _dbHelper.insertEmployee(employee);
      }
    } catch (e) {
      print('Sync employees error: $e');
    }
  }

  static Future<void> _syncAttendanceFromFirebase() async {
    final currentEmployee = GlobalState.currentEmployee;
    if (currentEmployee == null) return;

    try {
      final snapshot = await _firestore
          .collection('attendance')
          .where('employeeId', isEqualTo: currentEmployee.empId)
          .get();
      
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final record = _mapFirebaseToAttendance(data);
        await _dbHelper.insertAttendanceRecord(record);
      }
    } catch (e) {
      print('Sync attendance error: $e');
    }
  }

  static Future<void> _syncLeaveRequestsFromFirebase() async {
    final currentEmployee = GlobalState.currentEmployee;
    if (currentEmployee == null) return;

    try {
      final snapshot = await _firestore
          .collection('leave_requests')
          .where('employeeId', isEqualTo: currentEmployee.empId)
          .get();
      
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final request = _mapFirebaseToLeaveRequest(data);
        await _dbHelper.insertLeaveRequest(request);
      }
    } catch (e) {
      print('Sync leave requests error: $e');
    }
  }

  // ==================== DATA MAPPING ====================

  static Employee _mapFirebaseToEmployee(Map<String, dynamic> data) {
    return Employee(
      empId: data['employeeId'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      role: data['position'] ?? '',
      department: data['department'] ?? '',
      shift: 'Morning',
      status: 'Active',
      hourlyRate: 200.0,
      location: Location(lat: 0.0, lng: 0.0),
      hasRegisteredFace: false,
      faceData: null,
      faceImagePath: null,
      profileImagePath: data['profilePictureUrl'],
      faceRegistrationDate: null,
      joinDate: data['createdAt'] != null ? DateTime.parse(data['createdAt']) : DateTime.now(),
      address: '',
      emergencyContact: '',
      emergencyPhone: '',
      workStats: WorkStatistics(
        totalDaysWorked: 0,
        totalHoursWorked: 0.0,
        leaveDaysUsed: 0,
        leaveDaysRemaining: 20,
        attendanceRate: 100.0,
        averageDailyHours: 8.0,
        lateArrivals: 0,
        earlyDepartures: 0,
        recentAttendance: [],
      ),
    );
  }

  static AttendanceRecord _mapFirebaseToAttendance(Map<String, dynamic> data) {
    return AttendanceRecord(
      date: data['date'] ?? '',
      checkIn: data['checkInTime'],
      checkOut: data['checkOutTime'],
      status: data['checkOutTime'] != null ? 'Completed' : 'In Progress',
      hours: data['workHours']?.toDouble() ?? 0.0,
      location: data['checkInLocation'] ?? '',
      method: data['checkInMethod'] ?? '',
    );
  }

  static LeaveRequest _mapFirebaseToLeaveRequest(Map<String, dynamic> data) {
    return LeaveRequest(
      id: data['id']?.toString() ?? '',
      empId: data['employeeId'] ?? '',
      type: data['leaveType'] ?? '',
      startDate: data['startDate'] ?? '',
      endDate: data['endDate'] ?? '',
      reason: data['reason'] ?? '',
      status: data['status'] ?? 'pending',
      appliedDate: data['appliedDate'] != null ? DateTime.parse(data['appliedDate']) : DateTime.now(),
    );
  }
}
