import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // ==================== AUTHENTICATION ====================

  // Employee Login with ID and Password
  static Future<Map<String, dynamic>?> signInEmployee(
    String employeeId,
    String password,
  ) async {
    try {
      // Query Firestore for employee credentials
      final employeeDoc = await _firestore
          .collection('employees')
          .where('employeeId', isEqualTo: employeeId)
          .where('password', isEqualTo: password)
          .get();

      if (employeeDoc.docs.isNotEmpty) {
        final employeeData = employeeDoc.docs.first.data();
        employeeData['docId'] = employeeDoc.docs.first.id;

        // Store employee data locally
        await _storeEmployeeLocally(employeeData);

        return {
          'success': true,
          'employee': employeeData,
          'message': 'Login successful',
        };
      } else {
        return {'success': false, 'message': 'Invalid employee ID or password'};
      }
    } catch (e) {
      print('Employee sign in error: $e');
      return {'success': false, 'message': 'Login failed: $e'};
    }
  }

  // Create new employee account
  static Future<Map<String, dynamic>> createEmployeeAccount(
    Map<String, dynamic> employeeData,
  ) async {
    try {
      // Check if employee ID already exists
      final existingEmployee = await _firestore
          .collection('employees')
          .where('employeeId', isEqualTo: employeeData['employeeId'])
          .get();

      if (existingEmployee.docs.isNotEmpty) {
        return {'success': false, 'message': 'Employee ID already exists'};
      }

      // Add timestamp
      employeeData['createdAt'] = FieldValue.serverTimestamp();
      employeeData['lastLogin'] = FieldValue.serverTimestamp();
      employeeData['isActive'] = true;

      // Create employee document
      final docRef = await _firestore.collection('employees').add(employeeData);

      return {
        'success': true,
        'employeeId': docRef.id,
        'message': 'Employee account created successfully',
      };
    } catch (e) {
      print('Create employee error: $e');
      return {'success': false, 'message': 'Failed to create account: $e'};
    }
  }

  // Get current employee data
  static Future<Map<String, dynamic>?> getCurrentEmployee() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final employeeId = prefs.getString('employeeId');

      if (employeeId != null) {
        final doc = await _firestore
            .collection('employees')
            .doc(employeeId)
            .get();
        if (doc.exists) {
          return doc.data();
        }
      }
      return null;
    } catch (e) {
      print('Get current employee error: $e');
      return null;
    }
  }

  // Update employee profile
  static Future<bool> updateEmployeeProfile(
    String employeeId,
    Map<String, dynamic> updates,
  ) async {
    try {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('employees').doc(employeeId).update(updates);
      return true;
    } catch (e) {
      print('Update employee error: $e');
      return false;
    }
  }

  // ==================== ATTENDANCE MANAGEMENT ====================

  // Check-in with method
  static Future<Map<String, dynamic>> checkIn(
    String employeeId,
    String method,
    Map<String, dynamic>? additionalData,
  ) async {
    try {
      final now = DateTime.now();
      final checkInData = {
        'employeeId': employeeId,
        'method': method,
        'checkInTime': FieldValue.serverTimestamp(),
        'date':
            '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'checked-in',
        'additionalData': additionalData ?? {},
      };

      // Check if already checked in today
      final existingAttendance = await _firestore
          .collection('attendance')
          .where('employeeId', isEqualTo: employeeId)
          .where('date', isEqualTo: checkInData['date'])
          .where('status', isEqualTo: 'checked-in')
          .get();

      if (existingAttendance.docs.isNotEmpty) {
        return {'success': false, 'message': 'Already checked in today'};
      }

      // Create attendance record
      final docRef = await _firestore.collection('attendance').add(checkInData);

      // Update employee's last check-in
      await _firestore.collection('employees').doc(employeeId).update({
        'lastCheckIn': FieldValue.serverTimestamp(),
        'lastCheckInMethod': method,
      });

      return {
        'success': true,
        'attendanceId': docRef.id,
        'message': 'Check-in successful via $method',
        'data': checkInData,
      };
    } catch (e) {
      print('Check-in error: $e');
      return {'success': false, 'message': 'Check-in failed: $e'};
    }
  }

  // Check-out
  static Future<Map<String, dynamic>> checkOut(String employeeId) async {
    try {
      final now = DateTime.now();
      final today =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      // Find today's check-in record
      final attendanceQuery = await _firestore
          .collection('attendance')
          .where('employeeId', isEqualTo: employeeId)
          .where('date', isEqualTo: today)
          .where('status', isEqualTo: 'checked-in')
          .get();

      if (attendanceQuery.docs.isEmpty) {
        return {
          'success': false,
          'message': 'No check-in record found for today',
        };
      }

      final attendanceDoc = attendanceQuery.docs.first;
      final checkInTime = attendanceDoc.data()['checkInTime'] as Timestamp;

      // Calculate hours worked
      final checkOutTime = now;
      final hoursWorked =
          checkOutTime.difference(checkInTime.toDate()).inMinutes / 60.0;

      // Update attendance record
      await _firestore.collection('attendance').doc(attendanceDoc.id).update({
        'checkOutTime': FieldValue.serverTimestamp(),
        'status': 'checked-out',
        'hoursWorked': hoursWorked,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Update employee's last check-out
      await _firestore.collection('employees').doc(employeeId).update({
        'lastCheckOut': FieldValue.serverTimestamp(),
        'totalHoursThisMonth': FieldValue.increment(hoursWorked),
      });

      return {
        'success': true,
        'message': 'Check-out successful',
        'hoursWorked': hoursWorked,
        'checkOutTime': now,
      };
    } catch (e) {
      print('Check-out error: $e');
      return {'success': false, 'message': 'Check-out failed: $e'};
    }
  }

  // Get attendance history
  static Future<List<Map<String, dynamic>>> getAttendanceHistory(
    String employeeId, {
    int limit = 30,
  }) async {
    try {
      final query = await _firestore
          .collection('attendance')
          .where('employeeId', isEqualTo: employeeId)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .get();

      return query.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Get attendance history error: $e');
      return [];
    }
  }

  // Get today's attendance status
  static Future<Map<String, dynamic>?> getTodayAttendance(
    String employeeId,
  ) async {
    try {
      final now = DateTime.now();
      final today =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      final query = await _firestore
          .collection('attendance')
          .where('employeeId', isEqualTo: employeeId)
          .where('date', isEqualTo: today)
          .get();

      if (query.docs.isNotEmpty) {
        final data = query.docs.first.data() as Map<String, dynamic>;
        data['id'] = query.docs.first.id;
        return data;
      }
      return null;
    } catch (e) {
      print('Get today attendance error: $e');
      return null;
    }
  }

  // ==================== TASK MANAGEMENT ====================

  // Create new task
  static Future<Map<String, dynamic>> createTask(
    Map<String, dynamic> taskData,
  ) async {
    try {
      taskData['createdAt'] = FieldValue.serverTimestamp();
      taskData['updatedAt'] = FieldValue.serverTimestamp();
      taskData['status'] = 'pending';

      final docRef = await _firestore.collection('tasks').add(taskData);

      return {
        'success': true,
        'taskId': docRef.id,
        'message': 'Task created successfully',
      };
    } catch (e) {
      print('Create task error: $e');
      return {'success': false, 'message': 'Failed to create task: $e'};
    }
  }

  // Get tasks for employee
  static Future<List<Map<String, dynamic>>> getEmployeeTasks(
    String employeeId, {
    String? status,
    int limit = 50,
  }) async {
    try {
      Query query = _firestore
          .collection('tasks')
          .where('assignedTo', isEqualTo: employeeId)
          .orderBy('createdAt', descending: true);

      if (status != null && status != 'all') {
        query = query.where('status', isEqualTo: status);
      }

      final querySnapshot = await query.limit(limit).get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Get employee tasks error: $e');
      return [];
    }
  }

  // Update task status
  static Future<bool> updateTaskStatus(
    String taskId,
    String newStatus,
    String? notes,
  ) async {
    try {
      final updates = {
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (notes != null) {
        updates['notes'] = notes;
      }

      await _firestore.collection('tasks').doc(taskId).update(updates);
      return true;
    } catch (e) {
      print('Update task status error: $e');
      return false;
    }
  }

  // ==================== LEAVE MANAGEMENT ====================

  // Apply for leave
  static Future<Map<String, dynamic>> applyForLeave(
    Map<String, dynamic> leaveData,
  ) async {
    try {
      leaveData['createdAt'] = FieldValue.serverTimestamp();
      leaveData['status'] = 'pending';
      leaveData['approvedBy'] = null;
      leaveData['approvedAt'] = null;

      final docRef = await _firestore
          .collection('leave_requests')
          .add(leaveData);

      return {
        'success': true,
        'leaveId': docRef.id,
        'message': 'Leave request submitted successfully',
      };
    } catch (e) {
      print('Apply for leave error: $e');
      return {
        'success': false,
        'message': 'Failed to submit leave request: $e',
      };
    }
  }

  // Get leave requests for employee
  static Future<List<Map<String, dynamic>>> getEmployeeLeaveRequests(
    String employeeId,
  ) async {
    try {
      final query = await _firestore
          .collection('leave_requests')
          .where('employeeId', isEqualTo: employeeId)
          .orderBy('createdAt', descending: true)
          .get();

      return query.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Get leave requests error: $e');
      return [];
    }
  }

  // Get leave balance
  static Future<Map<String, dynamic>> getLeaveBalance(String employeeId) async {
    try {
      final employeeDoc = await _firestore
          .collection('employees')
          .doc(employeeId)
          .get();
      if (employeeDoc.exists) {
        final data = employeeDoc.data()!;
        return {
          'sick': data['sickLeaveBalance'] ?? 0,
          'casual': data['casualLeaveBalance'] ?? 0,
          'annual': data['annualLeaveBalance'] ?? 0,
          'emergency': data['emergencyLeaveBalance'] ?? 0,
          'maternity': data['maternityLeaveBalance'] ?? 0,
        };
      }
      return {};
    } catch (e) {
      print('Get leave balance error: $e');
      return {};
    }
  }

  // ==================== FILE STORAGE ====================

  // Upload profile picture
  static Future<String?> uploadProfilePicture(
    String employeeId,
    Uint8List imageBytes,
  ) async {
    try {
      final ref = _storage.ref('profile_pictures/$employeeId.jpg');
      final uploadTask = ref.putData(imageBytes);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Update employee profile with new picture URL
      await _firestore.collection('employees').doc(employeeId).update({
        'profilePictureUrl': downloadUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return downloadUrl;
    } catch (e) {
      print('Upload profile picture error: $e');
      return null;
    }
  }

  // Upload document
  static Future<String?> uploadDocument(
    String employeeId,
    String documentType,
    Uint8List fileBytes,
    String fileName,
  ) async {
    try {
      final ref = _storage.ref('documents/$employeeId/$documentType/$fileName');
      final uploadTask = ref.putData(fileBytes);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      print('Upload document error: $e');
      return null;
    }
  }

  // ==================== NOTIFICATIONS ====================

  // Subscribe to notifications
  static Future<void> subscribeToNotifications(String employeeId) async {
    try {
      await _messaging.subscribeToTopic('all_employees');
      await _messaging.subscribeToTopic('employee_$employeeId');

      // Get FCM token
      final token = await _messaging.getToken();
      if (token != null) {
        await _firestore.collection('employees').doc(employeeId).update({
          'fcmToken': token,
          'lastTokenUpdate': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Subscribe to notifications error: $e');
    }
  }

  // ==================== UTILITY METHODS ====================

  // Store employee data locally
  static Future<void> _storeEmployeeLocally(
    Map<String, dynamic> employeeData,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('employeeId', employeeData['docId']);
      await prefs.setString('employeeName', employeeData['name'] ?? '');
      await prefs.setString('employeeEmail', employeeData['email'] ?? '');
      await prefs.setString('department', employeeData['department'] ?? '');
    } catch (e) {
      print('Store employee locally error: $e');
    }
  }

  // Sign out
  static Future<void> signOut() async {
    try {
      await _auth.signOut();

      // Clear local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      print('Sign out error: $e');
    }
  }

  // Get current user
  static User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  static Stream<User?> get authStateChanges => _auth.authStateChanges();
}

