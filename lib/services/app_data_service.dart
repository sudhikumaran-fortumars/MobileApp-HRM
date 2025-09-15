import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_service.dart';
import '../models.dart';

class AppDataService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static Employee? _currentEmployee;
  static List<AttendanceRecord> _attendanceHistory = [];
  static List<LeaveRequest> _leaveRequests = [];

  // ==================== EMPLOYEE MANAGEMENT ====================

  // Load current employee from Firebase
  static Future<Employee?> loadCurrentEmployee() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final employeeId = prefs.getString('employeeId');
      
      if (employeeId == null) {
        print('No employee ID found in local storage');
        return null;
      }

      final doc = await _firestore.collection('employees').doc(employeeId).get();
      if (doc.exists) {
        final data = doc.data()!;
        _currentEmployee = _mapFirebaseToEmployee(data);
        return _currentEmployee;
      }
      return null;
    } catch (e) {
      print('Error loading current employee: $e');
      return null;
    }
  }

  // Login employee
  static Future<Map<String, dynamic>> loginEmployee(String employeeId, String password) async {
    try {
      final result = await FirebaseService.signInEmployee(employeeId, password);
      
      if (result?['success'] == true) {
        _currentEmployee = _mapFirebaseToEmployee(result!['employee']);
        await _loadEmployeeData();
        return result;
      }
      return result ?? {'success': false, 'message': 'Login failed'};
    } catch (e) {
      print('Login error: $e');
      return {'success': false, 'message': 'Login failed: $e'};
    }
  }

  // ==================== ATTENDANCE MANAGEMENT ====================

  // Check-in employee
  static Future<Map<String, dynamic>> checkIn(String method, Map<String, dynamic>? additionalData) async {
    if (_currentEmployee == null) {
      return {'success': false, 'message': 'No employee logged in'};
    }

    try {
      final result = await FirebaseService.checkIn(_currentEmployee!.empId, method, additionalData);
      
      if (result['success'] == true) {
        // Update local state
        GlobalState.isCheckedIn = true;
        GlobalState.checkInTime = _formatTime(DateTime.now());
        GlobalState.checkInMethod = method;
        
        // Reload attendance data
        await _loadAttendanceHistory();
        
        return result;
      }
      return result;
    } catch (e) {
      print('Check-in error: $e');
      return {'success': false, 'message': 'Check-in failed: $e'};
    }
  }

  // Check-out employee
  static Future<Map<String, dynamic>> checkOut() async {
    if (_currentEmployee == null) {
      return {'success': false, 'message': 'No employee logged in'};
    }

    try {
      final result = await FirebaseService.checkOut(_currentEmployee!.empId);
      
      if (result['success'] == true) {
        // Update local state
        GlobalState.isCheckedIn = false;
        GlobalState.checkInTime = null;
        GlobalState.checkInMethod = null;
        
        // Reload attendance data
        await _loadAttendanceHistory();
        
        return result;
      }
      return result;
    } catch (e) {
      print('Check-out error: $e');
      return {'success': false, 'message': 'Check-out failed: $e'};
    }
  }

  // Get attendance history
  static Future<List<AttendanceRecord>> getAttendanceHistory() async {
    if (_currentEmployee == null) return [];
    
    try {
      final firebaseData = await FirebaseService.getAttendanceHistory(_currentEmployee!.empId);
      _attendanceHistory = firebaseData.map((data) => _mapFirebaseToAttendanceRecord(data)).toList();
      return _attendanceHistory;
    } catch (e) {
      print('Error loading attendance history: $e');
      return _attendanceHistory;
    }
  }

  // Get today's attendance
  static Future<Map<String, dynamic>?> getTodayAttendance() async {
    if (_currentEmployee == null) return null;
    
    try {
      return await FirebaseService.getTodayAttendance(_currentEmployee!.empId);
    } catch (e) {
      print('Error loading today attendance: $e');
      return null;
    }
  }

  // ==================== LEAVE MANAGEMENT ====================

  // Apply for leave
  static Future<Map<String, dynamic>> applyForLeave(Map<String, dynamic> leaveData) async {
    if (_currentEmployee == null) {
      return {'success': false, 'message': 'No employee logged in'};
    }

    try {
      leaveData['employeeId'] = _currentEmployee!.empId;
      leaveData['employeeName'] = _currentEmployee!.name;
      
      final result = await FirebaseService.applyForLeave(leaveData);
      
      if (result['success'] == true) {
        await _loadLeaveRequests();
      }
      
      return result;
    } catch (e) {
      print('Apply for leave error: $e');
      return {'success': false, 'message': 'Leave application failed: $e'};
    }
  }

  // Get leave requests
  static Future<List<LeaveRequest>> getLeaveRequests() async {
    if (_currentEmployee == null) return [];
    
    try {
      final firebaseData = await FirebaseService.getEmployeeLeaveRequests(_currentEmployee!.empId);
      _leaveRequests = firebaseData.map((data) => _mapFirebaseToLeaveRequest(data)).toList();
      return _leaveRequests;
    } catch (e) {
      print('Error loading leave requests: $e');
      return _leaveRequests;
    }
  }

  // ==================== DATA LOADING ====================

  // Load all employee data
  static Future<void> _loadEmployeeData() async {
    if (_currentEmployee == null) return;
    
    try {
      await Future.wait([
        _loadAttendanceHistory(),
        _loadLeaveRequests(),
      ]);
    } catch (e) {
      print('Error loading employee data: $e');
    }
  }

  // Load attendance history
  static Future<void> _loadAttendanceHistory() async {
    _attendanceHistory = await getAttendanceHistory();
  }

  // Load leave requests
  static Future<void> _loadLeaveRequests() async {
    _leaveRequests = await getLeaveRequests();
  }

  // ==================== DATA MAPPING ====================

  // Map Firebase data to Employee object
  static Employee _mapFirebaseToEmployee(Map<String, dynamic> data) {
    return Employee(
      empId: data['employeeId'] ?? 'EMP001',
      name: data['name'] ?? 'Unknown',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      role: data['role'] ?? 'Employee',
      department: data['department'] ?? 'General',
      shift: data['shift'] ?? 'Day Shift',
      status: data['status'] ?? 'Active',
      hourlyRate: (data['hourlyRate'] ?? 0).toDouble(),
      location: Location(lat: 11.1085, lng: 77.3411), // Default location
      joinDate: data['joinDate'] != null 
          ? (data['joinDate'] as Timestamp).toDate() 
          : DateTime.now(),
      address: data['address'] ?? '',
      emergencyContact: data['emergencyContact'] ?? '',
      emergencyPhone: data['emergencyPhone'] ?? '',
      workStats: WorkStatistics(
        totalDaysWorked: data['totalDaysWorked'] ?? 0,
        totalHoursWorked: (data['totalHoursWorked'] ?? 0).toDouble(),
        leaveDaysUsed: data['leaveDaysUsed'] ?? 0,
        leaveDaysRemaining: data['leaveBalance'] ?? 0,
        attendanceRate: (data['attendanceRate'] ?? 0).toDouble(),
        averageDailyHours: (data['averageDailyHours'] ?? 8).toDouble(),
        lateArrivals: data['lateArrivals'] ?? 0,
        earlyDepartures: data['earlyDepartures'] ?? 0,
        recentAttendance: _attendanceHistory,
      ),
      hasRegisteredFace: data['hasRegisteredFace'] ?? false,
      faceData: data['faceData'],
      profileImagePath: data['profileImagePath'],
    );
  }

  // Map Firebase data to AttendanceRecord
  static AttendanceRecord _mapFirebaseToAttendanceRecord(Map<String, dynamic> data) {
    final checkInTime = data['checkInTime'] != null 
        ? (data['checkInTime'] as Timestamp).toDate() 
        : null;
    final checkOutTime = data['checkOutTime'] != null 
        ? (data['checkOutTime'] as Timestamp).toDate() 
        : null;

    return AttendanceRecord(
      date: data['date'] ?? '',
      checkIn: checkInTime != null ? _formatTime(checkInTime) : null,
      checkOut: checkOutTime != null ? _formatTime(checkOutTime) : null,
      status: data['status'] ?? 'Unknown',
      hours: (data['hoursWorked'] ?? 0).toDouble(),
      location: data['location'] ?? 'Office',
      method: data['method'] ?? 'manual',
    );
  }

  // Map Firebase data to LeaveRequest
  static LeaveRequest _mapFirebaseToLeaveRequest(Map<String, dynamic> data) {
    return LeaveRequest(
      id: data['id'] ?? '',
      empId: data['employeeId'] ?? '',
      type: data['type'] ?? 'Casual Leave',
      startDate: data['startDate'] ?? '',
      endDate: data['endDate'] ?? '',
      reason: data['reason'] ?? '',
      status: data['status'] ?? 'Pending',
      appliedDate: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
    );
  }

  // ==================== UTILITY METHODS ====================

  // Format time to string
  static String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    
    return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }

  // Get current employee
  static Employee? get currentEmployee => _currentEmployee;

  // Get attendance history
  static List<AttendanceRecord> get attendanceHistory => _attendanceHistory;

  // Get leave requests
  static List<LeaveRequest> get leaveRequests => _leaveRequests;

  // Sign out
  static Future<void> signOut() async {
    try {
      await FirebaseService.signOut();
      _currentEmployee = null;
      _attendanceHistory.clear();
      _leaveRequests.clear();
      
      // Reset global state
      GlobalState.isCheckedIn = false;
      GlobalState.checkInTime = null;
      GlobalState.checkInMethod = null;
    } catch (e) {
      print('Sign out error: $e');
    }
  }

  // ==================== FILE STORAGE ====================

  // Upload profile picture
  static Future<String?> uploadProfilePicture(Uint8List imageBytes) async {
    if (_currentEmployee == null) return null;
    
    try {
      final downloadUrl = await FirebaseService.uploadProfilePicture(
        _currentEmployee!.empId,
        imageBytes,
      );
      
      if (downloadUrl != null) {
        // Update local employee data
        _currentEmployee = _currentEmployee!.copyWith(
          profileImagePath: downloadUrl,
        );
        
        // Update global state
        GlobalState.currentEmployee = _currentEmployee;
      }
      
      return downloadUrl;
    } catch (e) {
      print('Upload profile picture error: $e');
      return null;
    }
  }

  // Upload document
  static Future<String?> uploadDocument(
    String documentType,
    Uint8List fileBytes,
    String fileName,
  ) async {
    if (_currentEmployee == null) return null;
    
    try {
      return await FirebaseService.uploadDocument(
        _currentEmployee!.empId,
        documentType,
        fileBytes,
        fileName,
      );
    } catch (e) {
      print('Upload document error: $e');
      return null;
    }
  }

  // Upload attendance photo
  static Future<String?> uploadAttendancePhoto(Uint8List imageBytes) async {
    if (_currentEmployee == null) return null;
    
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      return await FirebaseService.uploadAttendancePhoto(
        _currentEmployee!.empId,
        imageBytes,
        timestamp,
      );
    } catch (e) {
      print('Upload attendance photo error: $e');
      return null;
    }
  }

  // Delete file
  static Future<bool> deleteFile(String filePath) async {
    try {
      return await FirebaseService.deleteFile(filePath);
    } catch (e) {
      print('Delete file error: $e');
      return false;
    }
  }

  // Get file download URL
  static Future<String?> getDownloadUrl(String filePath) async {
    try {
      return await FirebaseService.getDownloadUrl(filePath);
    } catch (e) {
      print('Get download URL error: $e');
      return null;
    }
  }

  // List files in directory
  static Future<List<dynamic>> listFiles(String path) async {
    try {
      return await FirebaseService.listFiles(path);
    } catch (e) {
      print('List files error: $e');
      return [];
    }
  }
}
