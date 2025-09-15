import 'dart:convert';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models.dart';

class EnhancedOTPAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Test mode flag - set to false for real Firebase Phone Auth
  static const bool _isTestMode = false;


  // ==================== PHONE NUMBER VERIFICATION ====================

  static Future<Map<String, dynamic>> sendOTP(String phoneNumber, String countryCode) async {
    try {
      print('🔍 Starting OTP send process...');
      print('📱 Phone number: $phoneNumber');
      print('🌍 Country code: $countryCode');
      
      // Clean phone number (remove spaces, dashes, etc.)
      String cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
      
      // Combine country code with phone number
      String fullPhoneNumber = '$countryCode$cleanPhone';
      print('📞 Full phone number: $fullPhoneNumber');

      // Verify phone number format
      if (cleanPhone.length < 7) {
        print('❌ Invalid phone number format: $cleanPhone');
        return {
          'success': false,
          'message': 'Invalid phone number format. Please enter a valid phone number.',
        };
      }

      // Additional validation for common phone number patterns
      if (cleanPhone.length > 15) {
        print('❌ Phone number too long: $cleanPhone');
        return {
          'success': false,
          'message': 'Phone number is too long. Please check and try again.',
        };
      }

      // Test mode - simulate OTP sending
      if (_isTestMode) {
        print('🧪 TEST MODE: Simulating OTP send...');
        
        // Store test verification ID
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('verificationId', 'test_verification_id_${DateTime.now().millisecondsSinceEpoch}');
        await prefs.setString('phoneNumber', fullPhoneNumber);
        await prefs.setString('countryCode', countryCode);
        await prefs.setInt('resendToken', 12345);
        
        print('✅ TEST MODE: OTP simulation completed');
        return {
          'success': true,
          'message': 'TEST MODE: OTP sent successfully to $fullPhoneNumber\n\nFor testing, use OTP: 123456',
          'phoneNumber': fullPhoneNumber,
        };
      }

      print('🚀 Sending OTP via Firebase...');
      
      // Use Completer to handle async verification
      final completer = Completer<Map<String, dynamic>>();
      
      // Send OTP using Firebase Phone Auth
      await _auth.verifyPhoneNumber(
        phoneNumber: fullPhoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          print('✅ Auto-verification completed');
          try {
            final result = await _signInWithCredential(credential, fullPhoneNumber);
            if (!completer.isCompleted) {
              completer.complete(result);
            }
          } catch (e) {
            print('❌ Auto-verification error: $e');
            if (!completer.isCompleted) {
              completer.complete({
                'success': false,
                'message': 'Auto-verification failed: $e',
              });
            }
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          print('❌ Verification failed: ${e.code} - ${e.message}');
          print('❌ Error details: ${e.toString()}');
          if (!completer.isCompleted) {
            completer.complete({
              'success': false,
              'message': 'Failed to send OTP: ${e.message}',
            });
          }
        },
        codeSent: (String verificationId, int? resendToken) async {
          print('✅ OTP sent successfully!');
          print('🆔 Verification ID: $verificationId');
          
          // Store verification ID for later use
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('verificationId', verificationId);
          await prefs.setString('phoneNumber', fullPhoneNumber);
          await prefs.setString('countryCode', countryCode);
          if (resendToken != null) {
            await prefs.setInt('resendToken', resendToken);
            print('🔄 Resend token stored');
          }
          
          if (!completer.isCompleted) {
            completer.complete({
              'success': true,
              'message': 'OTP sent successfully to $fullPhoneNumber',
              'phoneNumber': fullPhoneNumber,
            });
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print('⏰ Auto-retrieval timeout');
          if (!completer.isCompleted) {
            completer.complete({
              'success': false,
              'message': 'OTP sending timeout. Please try again.',
            });
          }
        },
        timeout: const Duration(seconds: 60),
      );

      // Wait for the verification process to complete
      final result = await completer.future.timeout(
        Duration(seconds: 65),
        onTimeout: () {
          print('⏰ OTP send timeout');
          return {
            'success': false,
            'message': 'OTP sending timeout. Please try again.',
          };
        },
      );
      
      return result;
    } catch (e) {
      print('❌ OTP send error: ${e.toString()}');
      print('❌ Error type: ${e.runtimeType}');
      
      String errorMessage = 'Failed to send OTP';
      
      if (e.toString().contains('network')) {
        errorMessage = 'Network error. Please check your internet connection.';
      } else if (e.toString().contains('invalid-phone-number')) {
        errorMessage = 'Invalid phone number format. Please check the number.';
      } else if (e.toString().contains('too-many-requests')) {
        errorMessage = 'Too many requests. Please try again later.';
      } else if (e.toString().contains('quota-exceeded')) {
        errorMessage = 'SMS quota exceeded. Please try again later.';
      } else if (e.toString().contains('app-not-authorized')) {
        errorMessage = 'App not authorized for phone authentication. Please contact support.';
      }
      
      return {
        'success': false,
        'message': '$errorMessage\n\nError details: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> verifyOTP(String otp) async {
    try {
      print('🔍 Verifying OTP: $otp');
      
      final prefs = await SharedPreferences.getInstance();
      final verificationId = prefs.getString('verificationId');
      final phoneNumber = prefs.getString('phoneNumber');

      if (verificationId == null || phoneNumber == null) {
        print('❌ No verification in progress');
        return {
          'success': false,
          'message': 'No verification in progress. Please request OTP first.',
        };
      }

      // Test mode - accept test OTP
      if (_isTestMode) {
        print('🧪 TEST MODE: Verifying test OTP...');
        
        if (otp == '123456') {
          print('✅ TEST MODE: OTP verified successfully');
          
          // Simulate successful verification
          return {
            'success': true,
            'message': 'Phone verified successfully',
            'isNewUser': true, // Always new user in test mode
            'phoneNumber': phoneNumber,
            'userId': 'test_user_${DateTime.now().millisecondsSinceEpoch}',
          };
        } else {
          print('❌ TEST MODE: Invalid OTP');
          return {
            'success': false,
            'message': 'Invalid OTP. For testing, use: 123456',
          };
        }
      }

      // Real Firebase verification
      print('🔐 Verifying OTP with Firebase...');
      
      // Create credential
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otp,
      );

      // Sign in with credential
      final result = await _signInWithCredential(credential, phoneNumber);
      return result;
    } catch (e) {
      print('❌ OTP verification error: ${e.toString()}');
      return {
        'success': false,
        'message': 'OTP verification failed: ${e.toString()}',
      };
    }
  }

  static Future<Map<String, dynamic>> resendOTP() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final phoneNumber = prefs.getString('phoneNumber');
      final countryCode = prefs.getString('countryCode');
      final resendToken = prefs.getInt('resendToken');

      if (phoneNumber == null || countryCode == null) {
        return {
          'success': false,
          'message': 'No phone number found. Please start verification again.',
        };
      }

      // Test mode
      if (_isTestMode) {
        print('🧪 TEST MODE: Resending OTP...');
        await Future.delayed(Duration(seconds: 1));
        return {
          'success': true,
          'message': 'OTP resent successfully (Test Mode)',
          'phoneNumber': phoneNumber,
        };
      }

      // Real Firebase resend
      print('🔄 Resending OTP via Firebase...');
      
      final completer = Completer<Map<String, dynamic>>();
      
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          print('✅ Auto-verification completed on resend');
          try {
            final result = await _signInWithCredential(credential, phoneNumber);
            if (!completer.isCompleted) {
              completer.complete(result);
            }
          } catch (e) {
            if (!completer.isCompleted) {
              completer.complete({
                'success': false,
                'message': 'Auto-verification failed: $e',
              });
            }
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          print('❌ Resend verification failed: ${e.message}');
          if (!completer.isCompleted) {
            completer.complete({
              'success': false,
              'message': 'Failed to resend OTP: ${e.message}',
            });
          }
        },
        codeSent: (String verificationId, int? newResendToken) async {
          print('✅ OTP resent successfully!');
          
          // Update stored verification ID
          await prefs.setString('verificationId', verificationId);
          if (newResendToken != null) {
            await prefs.setInt('resendToken', newResendToken);
          }
          
          if (!completer.isCompleted) {
            completer.complete({
              'success': true,
              'message': 'OTP resent successfully to $phoneNumber',
              'phoneNumber': phoneNumber,
            });
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print('⏰ Auto-retrieval timeout on resend');
          if (!completer.isCompleted) {
            completer.complete({
              'success': false,
              'message': 'OTP resend timeout. Please try again.',
            });
          }
        },
        timeout: Duration(seconds: 60),
        forceResendingToken: resendToken,
      );

      final result = await completer.future.timeout(
        Duration(seconds: 65),
        onTimeout: () {
          return {
            'success': false,
            'message': 'OTP resend timeout. Please try again.',
          };
        },
      );
      
      return result;
    } catch (e) {
      print('❌ Resend OTP error: $e');
      return {
        'success': false,
        'message': 'Failed to resend OTP: $e',
      };
    }
  }

  // ==================== USER REGISTRATION ====================

  static Future<Map<String, dynamic>> registerUser({
    required String phoneNumber,
    required String username,
    required String password,
    required String fullName,
    required String email,
    required String department,
    required String position,
  }) async {
    try {
      // Test mode - simulate authenticated user
      if (_isTestMode) {
        print('🧪 TEST MODE: Simulating user registration...');
        print('📝 Registration details:');
        print('   - Username: $username');
        print('   - Full Name: $fullName');
        print('   - Email: $email');
        print('   - Phone: $phoneNumber');
        print('   - Department: $department');
        print('   - Position: $position');
        
        try {
          // Create a test user ID
          final testUserId = 'test_user_${DateTime.now().millisecondsSinceEpoch}';
          print('🆔 Test User ID: $testUserId');
          
          // Check if username already exists using SharedPreferences (web-compatible)
          print('🔍 Checking if username exists...');
          final prefs = await SharedPreferences.getInstance();
          final existingUsername = prefs.getString('username');
          if (existingUsername == username) {
            print('❌ Username already exists');
            return {
              'success': false,
              'message': 'Username already exists',
            };
          }
          print('✅ Username is available');

          // Create employee record
          print('👤 Creating employee record...');
          final employee = Employee(
            empId: testUserId,
            name: fullName,
            email: email,
            phone: phoneNumber,
            department: department,
            role: position,
            shift: '9:00 AM - 6:00 PM',
            status: 'Active',
            hourlyRate: 0.0,
            location: Location(lat: 0.0, lng: 0.0),
            joinDate: DateTime.now(),
            address: 'Office Address',
            emergencyContact: 'Emergency Contact',
            emergencyPhone: phoneNumber,
            workStats: WorkStatistics(
              totalDaysWorked: 0,
              totalHoursWorked: 0.0,
              leaveDaysUsed: 0,
              leaveDaysRemaining: 20,
              attendanceRate: 0.0,
              averageDailyHours: 0.0,
              lateArrivals: 0,
              earlyDepartures: 0,
              recentAttendance: [],
            ),
            profileImagePath: null,
          );
          print('✅ Employee record created');

          // Store user data using SharedPreferences (works on web)
          print('💾 Storing user data in SharedPreferences...');
          await _storeUserData(employee, username, password);
          print('✅ User data stored');

          // Set current employee
          print('👤 Setting current employee...');
          GlobalState.currentEmployee = employee;
          print('✅ Current employee set');

          print('🎉 TEST MODE: User registered successfully!');
          return {
            'success': true,
            'message': 'User registered successfully',
            'employee': employee,
          };
        } catch (e) {
          print('❌ Registration error in test mode: $e');
          print('❌ Error type: ${e.runtimeType}');
          return {
            'success': false,
            'message': 'Registration failed in test mode: ${e.toString()}',
          };
        }
      }

      final user = _auth.currentUser;
      if (user == null) {
        return {
          'success': false,
          'message': 'No authenticated user found',
        };
      }

      // Check if username already exists using SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final existingUsername = prefs.getString('username');
      if (existingUsername == username) {
        return {
          'success': false,
          'message': 'Username already exists',
        };
      }

      // Create employee record
      final employee = Employee(
        empId: user.uid,
        name: fullName,
        email: email,
        phone: phoneNumber,
        department: department,
        role: position,
        shift: '9:00 AM - 6:00 PM',
        status: 'Active',
        hourlyRate: 0.0,
        location: Location(lat: 0.0, lng: 0.0),
        joinDate: DateTime.now(),
        address: 'Office Address',
        emergencyContact: 'Emergency Contact',
        emergencyPhone: phoneNumber,
        workStats: WorkStatistics(
          totalDaysWorked: 0,
          totalHoursWorked: 0.0,
          leaveDaysUsed: 0,
          leaveDaysRemaining: 20,
          attendanceRate: 0.0,
          averageDailyHours: 0.0,
          lateArrivals: 0,
          earlyDepartures: 0,
          recentAttendance: [],
        ),
        profileImagePath: null,
      );

      // Store user data using SharedPreferences (works on web)
      await _storeUserData(employee, username, password);

      // Save to Firebase
      await _firestore.collection('employees').doc(user.uid).set({
        'empId': employee.empId,
        'name': employee.name,
        'email': employee.email,
        'phone': employee.phone,
        'department': employee.department,
        'role': employee.role,
        'profileImagePath': employee.profileImagePath,
        'status': employee.status,
        'joinDate': employee.joinDate.toIso8601String(),
        'username': username,
        'password': password, // In production, hash this password
        'workStats': {
          'totalDaysWorked': employee.workStats.totalDaysWorked,
          'totalHoursWorked': employee.workStats.totalHoursWorked,
          'leaveDaysUsed': employee.workStats.leaveDaysUsed,
          'leaveDaysRemaining': employee.workStats.leaveDaysRemaining,
          'attendanceRate': employee.workStats.attendanceRate,
          'averageDailyHours': employee.workStats.averageDailyHours,
          'lateArrivals': employee.workStats.lateArrivals,
          'earlyDepartures': employee.workStats.earlyDepartures,
          'recentAttendance': employee.workStats.recentAttendance.map((e) => {
            'date': e.date,
            'checkIn': e.checkIn,
            'checkOut': e.checkOut,
            'status': e.status,
            'hours': e.hours,
            'location': e.location,
            'method': e.method,
          }).toList(),
        },
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      });

      // Set current employee
      GlobalState.currentEmployee = employee;

      return {
        'success': true,
        'message': 'User registered successfully',
        'employee': employee,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Registration failed: ${e.toString()}',
      };
    }
  }

  // ==================== USER LOGIN ====================

  static Future<Map<String, dynamic>> loginWithCredentials(String username, String password) async {
    try {
      // Test mode - simulate login
      if (_isTestMode) {
        print('🧪 TEST MODE: Simulating user login...');
        
        // Get stored user data from SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final storedUsername = prefs.getString('username');
        final storedPassword = prefs.getString('password');
        final employeeJson = prefs.getString('current_employee');
        
        if (storedUsername != username || storedPassword != password) {
          return {
            'success': false,
            'message': 'Invalid username or password',
          };
        }
        
        if (employeeJson == null) {
          return {
            'success': false,
            'message': 'User data not found',
          };
        }
        
        // Parse employee data
        final employeeData = jsonDecode(employeeJson);
        final employee = Employee(
          empId: employeeData['empId'] ?? '',
          name: employeeData['name'] ?? '',
          email: employeeData['email'] ?? '',
          phone: employeeData['phone'] ?? '',
          role: employeeData['role'] ?? '',
          department: employeeData['department'] ?? '',
          shift: employeeData['shift'] ?? 'Morning',
          status: employeeData['status'] ?? 'Active',
          hourlyRate: (employeeData['hourlyRate'] ?? 0.0).toDouble(),
          location: Location(
            lat: employeeData['location']['lat'] ?? 0.0,
            lng: employeeData['location']['lng'] ?? 0.0,
          ),
          joinDate: DateTime.parse(employeeData['joinDate'] ?? DateTime.now().toIso8601String()),
          address: employeeData['address'] ?? '',
          emergencyContact: employeeData['emergencyContact'] ?? '',
          emergencyPhone: employeeData['emergencyPhone'] ?? '',
          workStats: WorkStatistics(
            totalDaysWorked: employeeData['workStats']['totalDaysWorked'] ?? 0,
            totalHoursWorked: (employeeData['workStats']['totalHoursWorked'] ?? 0.0).toDouble(),
            leaveDaysUsed: employeeData['workStats']['leaveDaysUsed'] ?? 0,
            leaveDaysRemaining: employeeData['workStats']['leaveDaysRemaining'] ?? 20,
            attendanceRate: (employeeData['workStats']['attendanceRate'] ?? 0.0).toDouble(),
            averageDailyHours: (employeeData['workStats']['averageDailyHours'] ?? 0.0).toDouble(),
            lateArrivals: employeeData['workStats']['lateArrivals'] ?? 0,
            earlyDepartures: employeeData['workStats']['earlyDepartures'] ?? 0,
            recentAttendance: [],
          ),
          profileImagePath: employeeData['profileImagePath'],
          hasRegisteredFace: employeeData['hasRegisteredFace'] ?? false,
        );

        // Set current employee
        GlobalState.currentEmployee = employee;

        print('✅ TEST MODE: Login successful');
        return {
          'success': true,
          'message': 'Login successful',
          'employee': employee,
        };
      }

      // Get stored user data from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final storedUsername = prefs.getString('username');
      final storedPassword = prefs.getString('password');
      final employeeJson = prefs.getString('current_employee');
      
      if (storedUsername != username || storedPassword != password) {
        return {
          'success': false,
          'message': 'Invalid username or password',
        };
      }
      
      if (employeeJson == null) {
        return {
          'success': false,
          'message': 'User data not found',
        };
      }
      
      // Parse employee data
      final employeeData = jsonDecode(employeeJson);
      final employee = Employee(
        empId: employeeData['empId'] ?? '',
        name: employeeData['name'] ?? '',
        email: employeeData['email'] ?? '',
        phone: employeeData['phone'] ?? '',
        role: employeeData['role'] ?? '',
        department: employeeData['department'] ?? '',
        shift: employeeData['shift'] ?? 'Morning',
        status: employeeData['status'] ?? 'Active',
        hourlyRate: (employeeData['hourlyRate'] ?? 0.0).toDouble(),
        location: Location(
          lat: employeeData['location']['lat'] ?? 0.0,
          lng: employeeData['location']['lng'] ?? 0.0,
        ),
        joinDate: DateTime.parse(employeeData['joinDate'] ?? DateTime.now().toIso8601String()),
        address: employeeData['address'] ?? '',
        emergencyContact: employeeData['emergencyContact'] ?? '',
        emergencyPhone: employeeData['emergencyPhone'] ?? '',
        workStats: WorkStatistics(
          totalDaysWorked: employeeData['workStats']['totalDaysWorked'] ?? 0,
          totalHoursWorked: (employeeData['workStats']['totalHoursWorked'] ?? 0.0).toDouble(),
          leaveDaysUsed: employeeData['workStats']['leaveDaysUsed'] ?? 0,
          leaveDaysRemaining: employeeData['workStats']['leaveDaysRemaining'] ?? 20,
          attendanceRate: (employeeData['workStats']['attendanceRate'] ?? 0.0).toDouble(),
          averageDailyHours: (employeeData['workStats']['averageDailyHours'] ?? 0.0).toDouble(),
          lateArrivals: employeeData['workStats']['lateArrivals'] ?? 0,
          earlyDepartures: employeeData['workStats']['earlyDepartures'] ?? 0,
          recentAttendance: [],
        ),
        profileImagePath: employeeData['profileImagePath'],
        hasRegisteredFace: employeeData['hasRegisteredFace'] ?? false,
      );

      // Update last login
      await _updateLastLogin(employee.empId);

      // Set current employee
      GlobalState.currentEmployee = employee;

      return {
        'success': true,
        'message': 'Login successful',
        'employee': employee,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Login failed: ${e.toString()}',
      };
    }
  }

  // ==================== HELPER METHODS ====================

  static Future<Map<String, dynamic>> _signInWithCredential(
    PhoneAuthCredential credential,
    String? phoneNumber,
  ) async {
    try {
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null) {
        // Check if user exists in database
        final employee = await _getEmployeeFromFirestore(user.uid);
        if (employee != null) {
          // Existing user - direct login
          await _storeEmployeeLocally(employee);
          GlobalState.currentEmployee = employee;
          return {
            'success': true,
            'message': 'Login successful',
            'isNewUser': false,
            'employee': employee,
          };
        } else {
          // New user - needs registration
          return {
            'success': true,
            'message': 'Phone verified. Please complete registration.',
            'isNewUser': true,
            'phoneNumber': phoneNumber,
            'userId': user.uid,
          };
        }
      }

      return {
        'success': false,
        'message': 'Authentication failed',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Authentication failed: ${e.toString()}',
      };
    }
  }

  static Future<Employee?> _getEmployeeFromFirestore(String userId) async {
    try {
      final doc = await _firestore.collection('employees').doc(userId).get();
      if (doc.exists) {
        final data = doc.data()!;
        return _mapFirebaseToEmployee(data);
      }
      return null;
    } catch (e) {
      print('Error getting employee from Firestore: $e');
      return null;
    }
  }

  static Employee _mapFirebaseToEmployee(Map<String, dynamic> data) {
    return Employee(
      empId: data['empId'] ?? '',
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      department: data['department'] ?? '',
      role: data['role'] ?? '',
      shift: data['shift'] ?? '9:00 AM - 6:00 PM',
      status: data['status'] ?? 'Active',
      hourlyRate: (data['hourlyRate'] ?? 0).toDouble(),
      location: Location(
        lat: data['location']?['lat'] ?? 0.0,
        lng: data['location']?['lng'] ?? 0.0,
      ),
      joinDate: DateTime.tryParse(data['joinDate'] ?? '') ?? DateTime.now(),
      address: data['address'] ?? 'Office Address',
      emergencyContact: data['emergencyContact'] ?? 'Emergency Contact',
      emergencyPhone: data['emergencyPhone'] ?? '',
      workStats: WorkStatistics(
        totalDaysWorked: data['workStats']?['totalDaysWorked'] ?? 0,
        totalHoursWorked: (data['workStats']?['totalHoursWorked'] ?? 0).toDouble(),
        leaveDaysUsed: data['workStats']?['leaveDaysUsed'] ?? 0,
        leaveDaysRemaining: data['workStats']?['leaveDaysRemaining'] ?? 20,
        attendanceRate: (data['workStats']?['attendanceRate'] ?? 0).toDouble(),
        averageDailyHours: (data['workStats']?['averageDailyHours'] ?? 0).toDouble(),
        lateArrivals: data['workStats']?['lateArrivals'] ?? 0,
        earlyDepartures: data['workStats']?['earlyDepartures'] ?? 0,
        recentAttendance: (data['workStats']?['recentAttendance'] as List<dynamic>? ?? [])
            .map((e) => AttendanceRecord(
              date: e['date'] ?? '',
              checkIn: e['checkIn'],
              checkOut: e['checkOut'],
              status: e['status'] ?? '',
              hours: (e['hours'] ?? 0).toDouble(),
              location: e['location'] ?? '',
              method: e['method'] ?? '',
            ))
            .toList(),
      ),
      profileImagePath: data['profileImagePath'],
    );
  }

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


  static Future<void> _updateLastLogin(String empId) async {
    try {
      await _firestore.collection('employees').doc(empId).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Update last login error: $e');
    }
  }


  static Future<void> _storeUserData(Employee employee, String username, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Store employee data as JSON
      final employeeJson = {
        'empId': employee.empId,
        'name': employee.name,
        'email': employee.email,
        'phone': employee.phone,
        'role': employee.role,
        'department': employee.department,
        'shift': employee.shift,
        'status': employee.status,
        'hourlyRate': employee.hourlyRate,
        'location': {
          'lat': employee.location.lat,
          'lng': employee.location.lng,
        },
        'joinDate': employee.joinDate.toIso8601String(),
        'address': employee.address,
        'emergencyContact': employee.emergencyContact,
        'emergencyPhone': employee.emergencyPhone,
        'workStats': {
          'totalDaysWorked': employee.workStats.totalDaysWorked,
          'totalHoursWorked': employee.workStats.totalHoursWorked,
          'leaveDaysUsed': employee.workStats.leaveDaysUsed,
          'leaveDaysRemaining': employee.workStats.leaveDaysRemaining,
          'attendanceRate': employee.workStats.attendanceRate,
          'averageDailyHours': employee.workStats.averageDailyHours,
          'lateArrivals': employee.workStats.lateArrivals,
          'earlyDepartures': employee.workStats.earlyDepartures,
          'recentAttendance': employee.workStats.recentAttendance,
        },
        'profileImagePath': employee.profileImagePath,
        'hasRegisteredFace': employee.hasRegisteredFace,
      };
      
      await prefs.setString('current_employee', jsonEncode(employeeJson));
      await prefs.setString('username', username);
      await prefs.setString('password', password);
      
      print('✅ User data stored in SharedPreferences');
    } catch (e) {
      print('❌ Error storing user data: $e');
    }
  }

  // ==================== LOGOUT ====================

  static Future<void> logout() async {
    try {
      await _auth.signOut();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      GlobalState.currentEmployee = null;
      GlobalState.isCheckedIn = false;
    } catch (e) {
      print('Logout error: $e');
    }
  }
}
