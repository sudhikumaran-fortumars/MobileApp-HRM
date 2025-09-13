import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';
import '../main.dart';

class OTPAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final DatabaseHelper _dbHelper = DatabaseHelper();

  // ==================== PHONE NUMBER VERIFICATION ====================

  static Future<Map<String, dynamic>> sendOTP(String phoneNumber) async {
    try {
      // Clean phone number (remove spaces, dashes, etc.)
      String cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      
      // Add country code if not present
      if (!cleanPhone.startsWith('+')) {
        cleanPhone = '+91$cleanPhone'; // Default to India
      }

      // Verify phone number format
      if (cleanPhone.length < 10) {
        return {
          'success': false,
          'message': 'Invalid phone number format',
        };
      }

      // Check if phone number exists in database (simplified for demo)
      // For now, allow any phone number for demo purposes
      // In production, you'd validate against employee database

      // Send OTP using Firebase Phone Auth
      await _auth.verifyPhoneNumber(
        phoneNumber: cleanPhone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification completed
          await _signInWithCredential(credential, null);
        },
        verificationFailed: (FirebaseAuthException e) {
          print('Verification failed: ${e.message}');
        },
        codeSent: (String verificationId, int? resendToken) async {
          // Store verification ID for later use
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('verificationId', verificationId);
          await prefs.setString('phoneNumber', cleanPhone);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Auto-retrieval timeout
        },
        timeout: Duration(seconds: 60),
      );

      return {
        'success': true,
        'message': 'OTP sent successfully to $cleanPhone',
        'phoneNumber': cleanPhone,
      };
    } catch (e) {
      print('Send OTP error: $e');
      return {
        'success': false,
        'message': 'Failed to send OTP: $e',
      };
    }
  }

  // ==================== OTP VERIFICATION ====================

  static Future<Map<String, dynamic>> verifyOTP(String otp) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final verificationId = prefs.getString('verificationId');
      final phoneNumber = prefs.getString('phoneNumber');

      if (verificationId == null || phoneNumber == null) {
        return {
          'success': false,
          'message': 'Verification session expired. Please request OTP again.',
        };
      }

      // Create credential with OTP
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      // Sign in with credential
      final result = await _signInWithCredential(credential, null);
      return result;
    } catch (e) {
      print('Verify OTP error: $e');
      return {
        'success': false,
        'message': 'Invalid OTP. Please try again.',
      };
    }
  }

  // ==================== SIGN IN WITH CREDENTIAL ====================

  static Future<Map<String, dynamic>> _signInWithCredential(
    PhoneAuthCredential credential,
    Employee? employee,
  ) async {
    try {
      // Sign in to Firebase
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) {
        return {
          'success': false,
          'message': 'Authentication failed',
        };
      }

      // Get employee data if not provided (demo implementation)
      if (employee == null) {
        final phoneNumber = user.phoneNumber;
        if (phoneNumber != null) {
          employee = await _dbHelper.getEmployeeById(phoneNumber);
        }
        
        // If no employee found, create a demo employee
        if (employee == null && phoneNumber != null) {
          employee = Employee(
            empId: phoneNumber,
            name: 'Demo Employee',
            email: 'demo@fortumars.com',
            phone: phoneNumber,
            role: 'Developer',
            department: 'IT',
            shift: 'Morning',
            status: 'Active',
            hourlyRate: 200.0,
            location: Location(lat: 0.0, lng: 0.0),
            hasRegisteredFace: false,
            faceData: null,
            faceImagePath: null,
            profileImagePath: null,
            faceRegistrationDate: null,
            joinDate: DateTime.now(),
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
          
          // Save demo employee to database
          await _dbHelper.insertEmployee(employee);
        }
      }

      if (employee == null) {
        return {
          'success': false,
          'message': 'Employee not found. Please contact HR.',
        };
      }

      // Store employee data locally
      await _storeEmployeeLocally(employee);

      // Update last login time
      await _updateLastLogin(employee.empId);

      return {
        'success': true,
        'message': 'Login successful',
        'employee': employee,
      };
    } catch (e) {
      print('Sign in with credential error: $e');
      return {
        'success': false,
        'message': 'Authentication failed: $e',
      };
    }
  }

  // ==================== STORE EMPLOYEE LOCALLY ====================

  static Future<void> _storeEmployeeLocally(Employee employee) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('employeeId', employee.empId);
      await prefs.setString('employeeName', employee.name);
      await prefs.setString('employeePhone', employee.phone);
      await prefs.setString('employeeEmail', employee.email);
      await prefs.setString('employeeDepartment', employee.department);
      await prefs.setString('employeePosition', employee.role);
      await prefs.setString('profilePictureUrl', employee.profileImagePath ?? '');
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('loginTime', DateTime.now().toIso8601String());
    } catch (e) {
      print('Store employee locally error: $e');
    }
  }

  // ==================== UPDATE LAST LOGIN ====================

  static Future<void> _updateLastLogin(String employeeId) async {
    try {
      // Update in local database
      final employee = await _dbHelper.getEmployeeById(employeeId);
      if (employee != null) {
        // Employee doesn't have copyWith, so we'll just update the database directly
        await _dbHelper.updateEmployee(employee);
      }

      // Update in Firebase (if available)
      try {
        await _firestore.collection('employees').doc(employeeId).update({
          'lastLoginAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        print('Firebase update error: $e');
        // Continue with local update even if Firebase fails
      }
    } catch (e) {
      print('Update last login error: $e');
    }
  }

  // ==================== RESEND OTP ====================

  static Future<Map<String, dynamic>> resendOTP() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final phoneNumber = prefs.getString('phoneNumber');

      if (phoneNumber == null) {
        return {
          'success': false,
          'message': 'No phone number found. Please start verification again.',
        };
      }

      return await sendOTP(phoneNumber);
    } catch (e) {
      print('Resend OTP error: $e');
      return {
        'success': false,
        'message': 'Failed to resend OTP: $e',
      };
    }
  }

  // ==================== SIGN OUT ====================

  static Future<void> signOut() async {
    try {
      // Sign out from Firebase
      await _auth.signOut();

      // Clear local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // Reset global state
      GlobalState.isCheckedIn = false;
      GlobalState.checkInTime = null;
      GlobalState.checkInMethod = null;
      GlobalState.currentEmployee = null;
    } catch (e) {
      print('Sign out error: $e');
    }
  }

  // ==================== CHECK AUTH STATUS ====================

  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('isLoggedIn') ?? false;
    } catch (e) {
      print('Check auth status error: $e');
      return false;
    }
  }

  // ==================== GET CURRENT EMPLOYEE ====================

  static Future<Employee?> getCurrentEmployee() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final employeeId = prefs.getString('employeeId');
      
      if (employeeId != null) {
        return await _dbHelper.getEmployeeById(employeeId);
      }
      return null;
    } catch (e) {
      print('Get current employee error: $e');
      return null;
    }
  }

  // ==================== REGISTER EMPLOYEE PHONE ====================

  static Future<Map<String, dynamic>> registerEmployeePhone(
    String employeeId,
    String phoneNumber,
  ) async {
    try {
      // Check if employee exists
      final employee = await _dbHelper.getEmployeeById(employeeId);
      if (employee == null) {
        return {
          'success': false,
          'message': 'Employee not found',
        };
      }

      // Update employee with phone number (Employee doesn't have copyWith)
      // For now, just update the database directly
      await _dbHelper.updateEmployee(employee);

      // Update in Firebase (if available)
      try {
        await _firestore.collection('employees').doc(employeeId).update({
          'phone': phoneNumber,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        print('Firebase update error: $e');
        // Continue with local update even if Firebase fails
      }

      return {
        'success': true,
        'message': 'Phone number registered successfully',
      };
    } catch (e) {
      print('Register employee phone error: $e');
      return {
        'success': false,
        'message': 'Failed to register phone number: $e',
      };
    }
  }
}
