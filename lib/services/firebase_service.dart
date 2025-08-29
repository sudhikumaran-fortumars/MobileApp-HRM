import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // Authentication methods
  static Future<UserCredential?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Sign in error: $e');
      return null;
    }
  }

  static Future<UserCredential?> createUserWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Sign up error: $e');
      return null;
    }
  }

  static Future<void> signOut() async {
    await _auth.signOut();
  }

  static User? get currentUser => _auth.currentUser;

  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Firestore methods for HRM data
  static Future<void> addEmployee(Map<String, dynamic> employeeData) async {
    try {
      await _firestore.collection('employees').add(employeeData);
    } catch (e) {
      print('Add employee error: $e');
    }
  }

  static Future<void> updateEmployee(
    String employeeId,
    Map<String, dynamic> employeeData,
  ) async {
    try {
      await _firestore
          .collection('employees')
          .doc(employeeId)
          .update(employeeData);
    } catch (e) {
      print('Update employee error: $e');
    }
  }

  static Future<Map<String, dynamic>?> getEmployee(String employeeId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('employees')
          .doc(employeeId)
          .get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Get employee error: $e');
      return null;
    }
  }

  static Stream<QuerySnapshot> getEmployeesStream() {
    return _firestore.collection('employees').snapshots();
  }

  // Attendance methods
  static Future<void> markAttendance(
    String employeeId,
    Map<String, dynamic> attendanceData,
  ) async {
    try {
      await _firestore.collection('attendance').add({
        'employeeId': employeeId,
        'timestamp': FieldValue.serverTimestamp(),
        ...attendanceData,
      });
    } catch (e) {
      print('Mark attendance error: $e');
    }
  }

  static Stream<QuerySnapshot> getAttendanceStream(String employeeId) {
    return _firestore
        .collection('attendance')
        .where('employeeId', isEqualTo: employeeId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Task methods
  static Future<void> addTask(Map<String, dynamic> taskData) async {
    try {
      await _firestore.collection('tasks').add(taskData);
    } catch (e) {
      print('Add task error: $e');
    }
  }

  static Future<void> updateTask(
    String taskId,
    Map<String, dynamic> taskData,
  ) async {
    try {
      await _firestore.collection('tasks').doc(taskId).update(taskData);
    } catch (e) {
      print('Update task error: $e');
    }
  }

  static Stream<QuerySnapshot> getTasksStream() {
    return _firestore.collection('tasks').snapshots();
  }

  // Leave management methods
  static Future<void> applyLeave(Map<String, dynamic> leaveData) async {
    try {
      await _firestore.collection('leave_requests').add(leaveData);
    } catch (e) {
      print('Apply leave error: $e');
    }
  }

  static Future<void> updateLeaveStatus(String leaveId, String status) async {
    try {
      await _firestore.collection('leave_requests').doc(leaveId).update({
        'status': status,
      });
    } catch (e) {
      print('Update leave status error: $e');
    }
  }

  static Stream<QuerySnapshot> getLeaveRequestsStream() {
    return _firestore.collection('leave_requests').snapshots();
  }

  // Storage methods for profile pictures and documents
  static Future<String?> uploadProfilePicture(
    String userId,
    Uint8List imageBytes,
  ) async {
    try {
      Reference ref = _storage.ref().child('profile_pictures/$userId.jpg');
      await ref.putData(imageBytes);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Upload profile picture error: $e');
      return null;
    }
  }

  static Future<String?> uploadDocument(
    String userId,
    String documentType,
    Uint8List documentBytes,
  ) async {
    try {
      Reference ref = _storage.ref().child(
        'documents/$userId/$documentType.pdf',
      );
      await ref.putData(documentBytes);
      return await ref.getDownloadURL();
    } catch (e) {
      print('Upload document error: $e');
      return null;
    }
  }
}
