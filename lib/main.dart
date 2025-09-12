import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:camera/camera.dart';
import 'package:intl/intl.dart';
import 'firebase_options.dart';
// import 'services/firebase_service.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:permission_handler/permission_handler.dart';
// import './utils/data_seeder.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization failed: $e');
    print('App will continue without Firebase functionality');
  }

  // Initialize notification service (simplified)
  try {
    await NotificationService.initialize();
  } catch (e) {
    print('Notification service initialization failed: $e');
  }

  // Seed initial data for testing
  // try {
  //   await DataSeeder.seedAllData();
  // } catch (e) {
  //   print('Error seeding data: $e');
  // }

  runApp(FortuMarsHRMApp());
}

// Background task callback (simplified for now)
void callbackDispatcher() {
  // Simplified notification system
  print('Background task executed');
}

class FortuMarsHRMApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FortuMars HRM Platform',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Color(0xFF1976D2),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: GoogleFonts.outfitTextTheme(),
        primaryTextTheme: GoogleFonts.outfitTextTheme(),
      ),
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Splash Screen
class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeIn),
    );

    _animationController!.forward();

    Timer(Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1976D2),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation!,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/images/fortumars_logo.png',
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SizedBox(height: 30),
              Text(
                'FortuMars',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'HRM Attendance Platform',
                style: GoogleFonts.outfit(
                  color: Colors.white70,
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 50),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Login Screen
class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _empIdController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulate API call
      await Future.delayed(Duration(seconds: 2));

      if (mounted) {
        if (_empIdController.text == 'EMP001' &&
            _passwordController.text == 'password') {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => MainScreen()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Invalid credentials'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 40),
                // Logo
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(
                      'assets/images/fortumars_logo.png',
                      width: 90,
                      height: 90,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Text(
                  'Sign In',
                  style: GoogleFonts.outfit(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF333333),
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Sign in to your account',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                SizedBox(height: 40),

                // Employee ID Field
                TextFormField(
                  controller: _empIdController,
                  decoration: InputDecoration(
                    labelText: 'Employee ID',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your Employee ID';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 30),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF1976D2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 20),

                // Demo Credentials
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Demo Credentials:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('Employee ID: EMP001'),
                      Text('Password: password'),
                    ],
                  ),
                ),
                SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Models
class Employee {
  final String empId;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String department;
  final String shift;
  final String status;
  final double hourlyRate;
  final Location location;
  final bool hasRegisteredFace;
  final String? faceData;
  final String? faceImagePath;
  final String? profileImagePath;
  final DateTime? faceRegistrationDate;
  final DateTime joinDate;
  final String address;
  final String emergencyContact;
  final String emergencyPhone;
  final WorkStatistics workStats;

  Employee({
    required this.empId,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.department,
    required this.shift,
    required this.status,
    required this.hourlyRate,
    required this.location,
    required this.joinDate,
    required this.address,
    required this.emergencyContact,
    required this.emergencyPhone,
    required this.workStats,
    this.hasRegisteredFace = false,
    this.faceData,
    this.faceImagePath,
    this.profileImagePath,
    this.faceRegistrationDate,
  });

  Employee copyWith({
    String? empId,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? department,
    String? shift,
    String? status,
    double? hourlyRate,
    Location? location,
    String? address,
    String? emergencyContact,
    String? emergencyPhone,
    WorkStatistics? workStats,
    bool? hasRegisteredFace,
    String? faceData,
    String? faceImagePath,
    String? profileImagePath,
    DateTime? faceRegistrationDate,
    DateTime? joinDate,
  }) {
    return Employee(
      empId: empId ?? this.empId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      department: department ?? this.department,
      shift: shift ?? this.shift,
      status: status ?? this.status,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      location: location ?? this.location,
      address: address ?? this.address,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      emergencyPhone: emergencyPhone ?? this.emergencyPhone,
      workStats: workStats ?? this.workStats,
      hasRegisteredFace: hasRegisteredFace ?? this.hasRegisteredFace,
      faceData: faceData ?? this.faceData,
      faceImagePath: faceImagePath ?? this.faceImagePath,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      faceRegistrationDate: faceRegistrationDate ?? this.faceRegistrationDate,
      joinDate: joinDate ?? this.joinDate,
    );
  }
}

class WorkStatistics {
  final int totalDaysWorked;
  final double totalHoursWorked;
  final int leaveDaysUsed;
  final int leaveDaysRemaining;
  final double attendanceRate;
  final double averageDailyHours;
  final int lateArrivals;
  final int earlyDepartures;
  final List<AttendanceRecord> recentAttendance;

  WorkStatistics({
    required this.totalDaysWorked,
    required this.totalHoursWorked,
    required this.leaveDaysUsed,
    required this.leaveDaysRemaining,
    required this.attendanceRate,
    required this.averageDailyHours,
    required this.lateArrivals,
    required this.earlyDepartures,
    required this.recentAttendance,
  });
}

class Location {
  final double lat;
  final double lng;

  Location({required this.lat, required this.lng});
}

class AttendanceRecord {
  final String date;
  final String? checkIn;
  final String? checkOut;
  final String status;
  final double hours;
  final String location;
  final String method;

  AttendanceRecord({
    required this.date,
    this.checkIn,
    this.checkOut,
    required this.status,
    required this.hours,
    required this.location,
    required this.method,
  });
}


class LeaveRequest {
  final String id;
  final String empId;
  final String type;
  final String startDate;
  final String endDate;
  final String reason;
  final String status;

  LeaveRequest({
    required this.id,
    required this.empId,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
  });
}

// Attendance time constants
class AttendanceConstants {
  static const TimeOfDay standardCheckIn = TimeOfDay(hour: 9, minute: 0);
  static const TimeOfDay standardCheckOut = TimeOfDay(hour: 18, minute: 0);
  static const int lateToleranceMinutes = 10; // 10 minutes late tolerance
  static const int earlyCheckoutToleranceMinutes = 30; // 30 minutes early checkout tolerance
  static const int lateArrivalsForHalfDay = 3; // 3 late arrivals = 0.5 day leave
}

// Global state management for persistent check-in status
class GlobalState {
  static bool _isCheckedIn = false;
  static String? _checkInTime;
  static String? _checkInMethod;
  static Timer? _updateTimer;
  static List<VoidCallback> _listeners = [];
  
  static bool get isCheckedIn => _isCheckedIn;
  static String? get checkInTime => _checkInTime;
  static String? get checkInMethod => _checkInMethod;
  
  static void setCheckInStatus(bool isCheckedIn, String? checkInTime, String? method) {
    _isCheckedIn = isCheckedIn;
    _checkInTime = checkInTime;
    _checkInMethod = method;
    _notifyListeners();
  }
  
  static void resetCheckInStatus() {
    _isCheckedIn = false;
    _checkInTime = null;
    _checkInMethod = null;
    _notifyListeners();
  }
  
  static void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }
  
  static void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }
  
  static void _notifyListeners() {
    for (var listener in _listeners) {
      listener();
    }
  }
  
  static void startUpdateTimer() {
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(Duration(seconds: 1), (_) {
      _notifyListeners();
    });
  }
  
  static void stopUpdateTimer() {
    _updateTimer?.cancel();
  }
}

// Real-time data management system
class EmployeeData {
  static Employee _currentEmployee = Employee(
    empId: 'EMP001',
    name: 'Sudhi Kumaran',
    email: 'sudhi.kumaran@fortumars.com',
    phone: '+91 9876543210',
    role: 'Frontend & Backend Developer',
    department: 'Development',
    shift: 'Morning',
    status: 'Active',
    hourlyRate: 200,
    location: Location(lat: 11.1085, lng: 77.3411),
    joinDate: DateTime(2023, 1, 15),
    address: '123 Tech Street, Bangalore, Karnataka 560001',
    emergencyContact: 'Priya Kumaran',
    emergencyPhone: '+91 9876543211',
    workStats: WorkStatistics(
      totalDaysWorked: 245,
      totalHoursWorked: 1960.0,
      leaveDaysUsed: 8,
      leaveDaysRemaining: 22,
      attendanceRate: 95.5,
      averageDailyHours: 8.0,
      lateArrivals: 3,
      earlyDepartures: 1,
      recentAttendance: [],
    ),
    hasRegisteredFace: false,
  );

  static Employee get currentEmployee => _currentEmployee;

  static void updateEmployee(Employee updatedEmployee) {
    _currentEmployee = updatedEmployee;
    _saveToLocalStorage();
  }

  static void registerFace(String faceData, String faceImagePath) {
    _currentEmployee = _currentEmployee.copyWith(
      hasRegisteredFace: true,
      faceData: faceData,
      faceImagePath: faceImagePath,
      profileImagePath: faceImagePath, // Set face image as profile picture
      faceRegistrationDate: DateTime.now(),
    );
    _saveToLocalStorage();
  }

  static void updateProfilePicture(String imagePath) {
    _currentEmployee = _currentEmployee.copyWith(
      profileImagePath: imagePath,
    );
    _saveToLocalStorage();
  }

  static void updatePersonalInfo({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? emergencyContact,
    String? emergencyPhone,
  }) {
    _currentEmployee = _currentEmployee.copyWith(
      name: name,
      email: email,
      phone: phone,
      address: address,
      emergencyContact: emergencyContact,
      emergencyPhone: emergencyPhone,
    );
    _saveToLocalStorage();
  }

  static void updateWorkStats(WorkStatistics newStats) {
    _currentEmployee = _currentEmployee.copyWith(
      workStats: newStats,
    );
    _saveToLocalStorage();
  }

  static void addAttendanceRecord(AttendanceRecord record) {
    final currentStats = _currentEmployee.workStats;
    final updatedRecentAttendance = List<AttendanceRecord>.from(currentStats.recentAttendance)
      ..insert(0, record);
    
    // Keep only last 30 days
    if (updatedRecentAttendance.length > 30) {
      updatedRecentAttendance.removeRange(30, updatedRecentAttendance.length);
    }

    // Apply attendance rules
    _applyAttendanceRules(updatedRecentAttendance);

    // Calculate new statistics
    final newStats = _calculateWorkStatistics(updatedRecentAttendance);
    
    _currentEmployee = _currentEmployee.copyWith(
      workStats: newStats,
    );
    _saveToLocalStorage();
  }

  static void _applyAttendanceRules(List<AttendanceRecord> attendance) {
    // Count late arrivals in the last 30 days
    final lateArrivals = attendance.where((record) => 
        record.checkIn != null && _isLateArrival(record.checkIn!)).length;
    
    // Apply rule: 3 late check-ins = 0.5 day leave deduction
    if (lateArrivals >= 3) {
      final halfDayLeaves = (lateArrivals / 3).floor();
      // This would be implemented with a proper leave management system
      print('Applied attendance rule: $lateArrivals late arrivals = $halfDayLeaves half-day leaves');
    }
  }

  static WorkStatistics _calculateWorkStatistics(List<AttendanceRecord> attendance) {
    final totalDays = attendance.length;
    final totalHours = attendance.fold(0.0, (sum, record) => sum + record.hours);
    final leaveDaysUsed = attendance.where((record) => record.status == 'Leave').length;
    final leaveDaysRemaining = 30 - leaveDaysUsed; // Assuming 30 days annual leave
    final attendanceRate = totalDays > 0 ? ((totalDays - leaveDaysUsed) / totalDays) * 100 : 0.0;
    final averageDailyHours = totalDays > 0 ? totalHours / totalDays : 0.0;
    final lateArrivals = attendance.where((record) => record.checkIn != null && 
        _isLateArrival(record.checkIn!)).length;
    final earlyDepartures = attendance.where((record) => record.checkOut != null && 
        _isEarlyDeparture(record.checkOut!)).length;

    return WorkStatistics(
      totalDaysWorked: totalDays,
      totalHoursWorked: totalHours,
      leaveDaysUsed: leaveDaysUsed,
      leaveDaysRemaining: leaveDaysRemaining,
      attendanceRate: attendanceRate,
      averageDailyHours: averageDailyHours,
      lateArrivals: lateArrivals,
      earlyDepartures: earlyDepartures,
      recentAttendance: attendance,
    );
  }

  static bool _isLateArrival(String checkInTime) {
    // Parse the time string (e.g., "3:29 AM") to TimeOfDay
    final timeParts = checkInTime.split(' ');
    final time = timeParts[0].split(':');
    final hour = int.parse(time[0]);
    final minute = int.parse(time[1]);
    final isPM = timeParts.length > 1 && timeParts[1] == 'PM';
    
    final checkIn = TimeOfDay(
      hour: isPM && hour != 12 ? hour + 12 : (hour == 12 && !isPM ? 0 : hour),
      minute: minute,
    );
    
    final standardStart = AttendanceConstants.standardCheckIn;
    final lateThreshold = TimeOfDay(
      hour: standardStart.hour,
      minute: standardStart.minute + AttendanceConstants.lateToleranceMinutes,
    );
    
    return checkIn.hour > lateThreshold.hour || 
           (checkIn.hour == lateThreshold.hour && checkIn.minute > lateThreshold.minute);
  }

  static bool _isEarlyDeparture(String checkOutTime) {
    // Parse the time string (e.g., "5:30 PM") to TimeOfDay
    final timeParts = checkOutTime.split(' ');
    final time = timeParts[0].split(':');
    final hour = int.parse(time[0]);
    final minute = int.parse(time[1]);
    final isPM = timeParts.length > 1 && timeParts[1] == 'PM';
    
    final checkOut = TimeOfDay(
      hour: isPM && hour != 12 ? hour + 12 : (hour == 12 && !isPM ? 0 : hour),
      minute: minute,
    );
    
    final standardEnd = AttendanceConstants.standardCheckOut;
    final earlyThreshold = TimeOfDay(
      hour: standardEnd.hour,
      minute: standardEnd.minute - AttendanceConstants.earlyCheckoutToleranceMinutes,
    );
    
    return checkOut.hour < earlyThreshold.hour || 
           (checkOut.hour == earlyThreshold.hour && checkOut.minute < earlyThreshold.minute);
  }

  static String _getCheckInStatus(String checkInTime) {
    if (_isLateArrival(checkInTime)) {
      return 'Late';
    }
    return 'On Time';
  }

  static String _getCheckOutStatus(String checkOutTime) {
    if (_isEarlyDeparture(checkOutTime)) {
      return 'Early';
    }
    return 'On Time';
  }

  static void _saveToLocalStorage() {
    // In a real app, this would save to SharedPreferences or a database
    // For now, we'll just keep it in memory
    print('Employee data updated and saved');
  }

  static Future<void> loadFromLocalStorage() async {
    // In a real app, this would load from SharedPreferences or a database
    // For now, we'll use the default data
    print('Employee data loaded from storage');
  }
}

// Mock Data
class MockData {
  static List<Employee> get employees {
    try {
      return [
        Employee(
          empId: 'EMP001',
          name: 'Sudhi Kumaran',
          email: 'sudhi.kumaran@fortumars.com',
          phone: '+91 9876543210',
          role: 'Frontend & Backend Developer',
          department: 'Development',
          shift: 'Morning',
          status: 'Active',
          hourlyRate: 200,
          location: Location(lat: 11.1085, lng: 77.3411),
          joinDate: DateTime(2023, 1, 15),
          address: '123 Tech Street, Bangalore, Karnataka 560001',
          emergencyContact: 'Priya Kumaran',
          emergencyPhone: '+91 9876543211',
          workStats: WorkStatistics(
            totalDaysWorked: 245,
            totalHoursWorked: 1960.0,
            leaveDaysUsed: 8,
            leaveDaysRemaining: 22,
            attendanceRate: 95.5,
            averageDailyHours: 8.0,
            lateArrivals: 3,
            earlyDepartures: 1,
            recentAttendance: [],
          ),
          hasRegisteredFace: true,
          faceData: 'face_data_001',
        ),
        Employee(
          empId: 'EMP002',
          name: 'Akash Kumar',
          email: 'akash.kumar@fortumars.com',
          phone: '+91 9876543212',
          role: 'Frontend & Backend Developer',
          department: 'Development',
          shift: 'Morning',
          status: 'Active',
          hourlyRate: 180,
          location: Location(lat: 11.1085, lng: 77.3411),
          joinDate: DateTime(2023, 3, 10),
          address: '456 Developer Lane, Bangalore, Karnataka 560002',
          emergencyContact: 'Ravi Kumar',
          emergencyPhone: '+91 9876543213',
          workStats: WorkStatistics(
            totalDaysWorked: 200,
            totalHoursWorked: 1600.0,
            leaveDaysUsed: 5,
            leaveDaysRemaining: 25,
            attendanceRate: 97.0,
            averageDailyHours: 8.0,
            lateArrivals: 1,
            earlyDepartures: 0,
            recentAttendance: [],
          ),
          hasRegisteredFace: false,
        ),
        Employee(
          empId: 'EMP003',
          name: 'BalaMurugan',
          email: 'bala.murugan@fortumars.com',
          phone: '+91 9876543214',
          role: 'Frontend Developer',
          department: 'Development',
          shift: 'Evening',
          status: 'Active',
          hourlyRate: 150,
          location: Location(lat: 11.1085, lng: 77.3411),
          joinDate: DateTime(2023, 6, 1),
          address: '789 Frontend Street, Bangalore, Karnataka 560003',
          emergencyContact: 'Raj Murugan',
          emergencyPhone: '+91 9876543215',
          workStats: WorkStatistics(
            totalDaysWorked: 180,
            totalHoursWorked: 1440.0,
            leaveDaysUsed: 3,
            leaveDaysRemaining: 27,
            attendanceRate: 98.5,
            averageDailyHours: 8.0,
            lateArrivals: 0,
            earlyDepartures: 1,
            recentAttendance: [],
          ),
          hasRegisteredFace: true,
          faceData: 'face_data_003',
        ),
      ];
    } catch (e) {
      return [
        Employee(
          empId: 'EMP001',
          name: 'Sudhi Kumaran',
          email: 'sudhi.kumaran@fortumars.com',
          phone: '+91 9876543210',
          role: 'Frontend & Backend Developer',
          department: 'Development',
          shift: 'Morning',
          status: 'Active',
          hourlyRate: 200,
          location: Location(lat: 11.1085, lng: 77.3411),
          joinDate: DateTime(2023, 1, 15),
          address: '123 Tech Street, Bangalore, Karnataka 560001',
          emergencyContact: 'Priya Kumaran',
          emergencyPhone: '+91 9876543211',
          workStats: WorkStatistics(
            totalDaysWorked: 245,
            totalHoursWorked: 1960.0,
            leaveDaysUsed: 8,
            leaveDaysRemaining: 22,
            attendanceRate: 95.5,
            averageDailyHours: 8.0,
            lateArrivals: 3,
            earlyDepartures: 1,
            recentAttendance: [],
          ),
          hasRegisteredFace: true,
          faceData: 'face_data_001',
        ),
      ];
    }
  }

  static Map<String, List<AttendanceRecord>> get attendanceData {
    try {
      return {
        'EMP001': [
          AttendanceRecord(
            date: '2024-08-22',
            checkIn: '09:00',
            checkOut: '18:00',
            status: 'Present',
            hours: 8.0,
            location: 'Office',
            method: 'facial',
          ),
          AttendanceRecord(
            date: '2024-08-21',
            checkIn: '09:15',
            checkOut: '18:30',
            status: 'Present',
            hours: 8.25,
            location: 'Office',
            method: 'geo',
          ),
        ],
      };
    } catch (e) {
      return {};
    }
  }


  static List<LeaveRequest> get leaveRequests {
    try {
      return [
        LeaveRequest(
          id: 'LVE001',
          empId: 'EMP002',
          type: 'Sick Leave',
          startDate: '2024-08-25',
          endDate: '2024-08-26',
          reason: 'Medical appointment',
          status: 'Pending',
        ),
      ];
    } catch (e) {
      return [];
    }
  }
}

// Main Screen with Bottom Navigation
class MainScreen extends StatefulWidget {
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  Employee? currentUser;

  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  void _initializeUser() {
    try {
      if (MockData.employees.isNotEmpty) {
        setState(() {
          currentUser = MockData.employees.first;
        });
      } else {
        // Fallback employee if list is empty
        setState(() {
          currentUser = Employee(
            empId: 'EMP001',
            name: 'Sudhi Kumaran',
            email: 'sudhi.kumaran@fortumars.com',
            phone: '+91 9876543210',
            role: 'Frontend & Backend Developer',
            department: 'Development',
            shift: 'Morning',
            status: 'Active',
            hourlyRate: 200,
            location: Location(lat: 11.1085, lng: 77.3411),
            joinDate: DateTime(2023, 1, 15),
            address: '123 Tech Street, Bangalore, Karnataka 560001',
            emergencyContact: 'Priya Kumaran',
            emergencyPhone: '+91 9876543211',
            workStats: WorkStatistics(
              totalDaysWorked: 245,
              totalHoursWorked: 1960.0,
              leaveDaysUsed: 8,
              leaveDaysRemaining: 22,
              attendanceRate: 95.5,
              averageDailyHours: 8.0,
              lateArrivals: 3,
              earlyDepartures: 1,
              recentAttendance: [],
            ),
          );
        });
      }
    } catch (e) {
      // If there's any error, create a fallback employee
      setState(() {
        currentUser = Employee(
          empId: 'EMP001',
          name: 'Sudhi Kumaran',
          email: 'sudhi.kumaran@fortumars.com',
          phone: '+91 9876543210',
          role: 'Frontend & Backend Developer',
          department: 'Development',
          shift: 'Morning',
          status: 'Active',
          hourlyRate: 200,
          location: Location(lat: 11.1085, lng: 77.3411),
          joinDate: DateTime(2023, 1, 15),
          address: '123 Tech Street, Bangalore, Karnataka 560001',
          emergencyContact: 'Priya Kumaran',
          emergencyPhone: '+91 9876543211',
          workStats: WorkStatistics(
            totalDaysWorked: 245,
            totalHoursWorked: 1960.0,
            leaveDaysUsed: 8,
            leaveDaysRemaining: 22,
            attendanceRate: 95.5,
            averageDailyHours: 8.0,
            lateArrivals: 3,
            earlyDepartures: 1,
            recentAttendance: [],
          ),
        );
      });
    }
  }

  final List<Widget> _screens = [
    DashboardScreen(),
    AttendanceScreen(),
    LeaveScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
            // Refresh the current screen when navigating
            if (mounted) {
              setState(() {});
            }
          },
          selectedItemColor: Color(0xFF1976D2),
          unselectedItemColor: Colors.grey,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.access_time),
              label: 'Attendance',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: 'Leave',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

// Real-time Clock Widget
class LiveClock extends StatefulWidget {
  @override
  _LiveClockState createState() => _LiveClockState();
}

class _LiveClockState extends State<LiveClock> {
  Timer? _timer;
  String _currentTime = '';
  String _currentDate = '';

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(Duration(seconds: 1), (_) => _updateTime());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateTime() {
    if (mounted) {
      setState(() {
        final now = DateTime.now();
        _currentTime = DateFormat('HH:mm:ss').format(now);
        _currentDate = DateFormat('EEEE, MMM dd, yyyy').format(now);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo[600]!, Colors.indigo[400]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.access_time, color: Colors.white, size: 24),
              SizedBox(width: 12),
              Text(
                'Current Time',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            _currentTime,
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          Text(
            _currentDate,
            style: GoogleFonts.outfit(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

// Dashboard Screen
class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Add listener for real-time updates
    GlobalState.addListener(_onStateChanged);
    GlobalState.startUpdateTimer();

    // Refresh the screen when it becomes visible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data when dependencies change
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    GlobalState.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/fortumars_logo.png',
              width: 90,
              height: 90,
              fit: BoxFit.contain,
            ),
            Expanded(
              child: Center(
                child: Text(
                  'Dashboard',
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 90,
            ), // Add invisible space on right to balance the logo
          ],
        ),
        centerTitle: true,
        backgroundColor: Color(0xFFF5F5F5),
        foregroundColor: Colors.black87,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.black87),
            onPressed: () {
              setState(() {
                // Refresh the dashboard data
              });
              // Show refresh feedback
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Data refreshed'),
                  duration: Duration(seconds: 1),
                  backgroundColor: Colors.green[600],
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.notifications, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              width: double.infinity,
              padding: EdgeInsets.all(25),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF667eea),
                    Color(0xFF764ba2),
                    Color(0xFFf093fb),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF667eea).withValues(alpha: 0.4),
                    blurRadius: 25,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome Back!',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Sudhi Kumaran',
                    style: GoogleFonts.outfit(
                      color: Colors.white70,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.access_time, color: Colors.white, size: 16),
                      SizedBox(width: 5),
                      Text(
                        'Friday, August 22, 2024',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Live Clock
            LiveClock(),
            SizedBox(height: 20),
            
            // Check-in Timer (if checked in)
            if (GlobalState.isCheckedIn) ...[
              _buildCheckInTimer(),
              SizedBox(height: 20),
            ],


            // Check-in Status Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[600]!, Colors.blue[400]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.access_time, color: Colors.white, size: 24),
                      SizedBox(width: 12),
                      Text(
                        'Check-in Status',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    GlobalState.isCheckedIn ? 'Checked In' : 'Not Checked In',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (GlobalState.checkInTime != null) ...[
                    Text(
                      'Since ${GlobalState.checkInTime}',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    SizedBox(height: 4),
                    Text(
                      _getCheckInStatusText(),
                      style: TextStyle(
                        color: _getCheckInStatusColor(),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: 20),

            // Quick Stats
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Hours Today',
                    '${_calculateTodayHours()}',
                    Icons.timer,
                    Colors.green,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _buildStatCard(
                    'Leave Balance',
                    '${EmployeeData.currentEmployee.workStats.leaveDaysRemaining}',
                    Icons.beach_access,
                    Colors.purple,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'This Month',
                    '${_calculateMonthlyHours()}h',
                    Icons.calendar_month,
                    Colors.blue,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _buildStatCard(
                    'Attendance Rate',
                    '${EmployeeData.currentEmployee.workStats.attendanceRate.toStringAsFixed(1)}%',
                    Icons.trending_up,
                    Colors.green,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Quick Actions
            Text(
              'Quick Actions',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                letterSpacing: 0.3,
              ),
            ),
            SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    'Check In',
                    Icons.login,
                    Colors.green,
                    () async {
                      await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AttendanceScreen(),
                      ),
                      );
                      // Refresh dashboard when returning
                      if (mounted) {
                        setState(() {});
                      }
                    },
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _buildActionCard(
                    'Apply Leave',
                    Icons.calendar_today,
                    Colors.blue,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LeaveScreen()),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _buildActionCard(
                    'View Profile',
                    Icons.person,
                    Colors.purple,
                    () async {
                      await Navigator.push(
                      context,
                        MaterialPageRoute(builder: (context) => ProfileScreen()),
                      );
                      // Refresh dashboard when returning
                      if (mounted) {
                        setState(() {});
                      }
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Analytics Section
            Text(
              'Analytics & Insights',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                letterSpacing: 0.3,
              ),
            ),
            SizedBox(height: 15),
            
            // Analytics Cards
            Row(
              children: [
                Expanded(
                  child: _buildAnalyticsCard(
                    'This Week',
                    '${_calculateWeeklyHours()}h',
                    Icons.trending_up,
                    Colors.blue,
                    '${_calculateWeeklyAttendance()}%',
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _buildAnalyticsCard(
                    'Overtime',
                    '${_calculateOvertimeHours()}h',
                    Icons.schedule,
                    Colors.purple,
                    'This month',
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _buildAnalyticsCard(
                    'Punctuality',
                    '${_calculatePunctualityRate()}%',
                    Icons.timer,
                    Colors.green,
                    'On-time rate',
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _buildAnalyticsCard(
                    'Streak',
                    '${_calculateCurrentStreak()} days',
                    Icons.local_fire_department,
                    Colors.orange,
                    'Current streak',
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Recent Activity
            Text(
              'Recent Activity',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                letterSpacing: 0.3,
              ),
            ),
            SizedBox(height: 15),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: _buildRecentActivities(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      padding: EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          padding: EdgeInsets.all(25),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: 0.15),
                color.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.2),
                blurRadius: 15,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 30),
              SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityItem(
    String title,
    String time,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: EdgeInsets.all(15),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  time,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getCheckInStatusText() {
    if (GlobalState.checkInTime == null) return '';
    final status = EmployeeData._getCheckInStatus(GlobalState.checkInTime!);
    return status == 'Late' ? 'Late Arrival' : 'On Time';
  }

  Color _getCheckInStatusColor() {
    if (GlobalState.checkInTime == null) return Colors.white70;
    final status = EmployeeData._getCheckInStatus(GlobalState.checkInTime!);
    return status == 'Late' ? Colors.orange[300]! : Colors.green[300]!;
  }

  String _calculateTodayHours() {
    if (!GlobalState.isCheckedIn) return '0.0';
    
    final now = DateTime.now();
    final checkInTime = GlobalState.checkInTime;
    if (checkInTime == null) return '0.0';
    
    // Parse check-in time
    final timeParts = checkInTime.split(' ');
    final time = timeParts[0].split(':');
    final hour = int.parse(time[0]);
    final minute = int.parse(time[1]);
    final isPM = timeParts.length > 1 && timeParts[1] == 'PM';
    
    final checkInHour = isPM && hour != 12 ? hour + 12 : (hour == 12 && !isPM ? 0 : hour);
    final checkInDateTime = DateTime(now.year, now.month, now.day, checkInHour, minute);
    
    final hoursWorked = now.difference(checkInDateTime).inHours + 
                       (now.difference(checkInDateTime).inMinutes % 60) / 60.0;
    
    return hoursWorked.toStringAsFixed(1);
  }

  String _calculateMonthlyHours() {
    final currentMonth = DateTime.now().month;
    final currentYear = DateTime.now().year;
    
    final monthlyRecords = EmployeeData.currentEmployee.workStats.recentAttendance
        .where((record) {
          final recordDate = DateTime.parse(record.date);
          return recordDate.month == currentMonth && recordDate.year == currentYear;
        })
        .toList();
    
    double totalHours = 0.0;
    for (var record in monthlyRecords) {
      totalHours += record.hours;
    }
    
    return totalHours.toStringAsFixed(0);
  }

  List<Widget> _buildRecentActivities() {
    final activities = <Widget>[];
    final recentAttendance = EmployeeData.currentEmployee.workStats.recentAttendance;
    
    // Show recent check-ins
    for (int i = 0; i < recentAttendance.length && i < 3; i++) {
      final record = recentAttendance[i];
      final recordDate = DateTime.parse(record.date);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final recordDay = DateTime(recordDate.year, recordDate.month, recordDate.day);
      
      String timeAgo;
      if (recordDay == today) {
        timeAgo = 'Today';
      } else if (recordDay == today.subtract(Duration(days: 1))) {
        timeAgo = 'Yesterday';
      } else {
        final daysDiff = today.difference(recordDay).inDays;
        timeAgo = '$daysDiff days ago';
      }
      
      activities.add(
        _buildActivityItem(
          'Checked ${record.status.toLowerCase()} at ${record.checkIn ?? "N/A"}',
          timeAgo,
          Icons.login,
          record.status == 'Late Arrival' ? Colors.orange : Colors.green,
        ),
      );
      
      if (i < recentAttendance.length - 1 && i < 2) {
        activities.add(Divider(height: 1));
      }
    }
    
    // If no recent activities, show placeholder
    if (activities.isEmpty) {
      activities.add(
        _buildActivityItem(
          'No recent activity',
          'Start by checking in',
          Icons.info,
          Colors.grey,
        ),
      );
    }
    
    return activities;
  }

  Widget _buildAnalyticsCard(String title, String value, IconData icon, Color color, String subtitle) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.outfit(
              fontSize: 11,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  String _calculateWeeklyHours() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(Duration(days: 6));
    
    final weeklyRecords = EmployeeData.currentEmployee.workStats.recentAttendance
        .where((record) {
          final recordDate = DateTime.parse(record.date);
          return recordDate.isAfter(startOfWeek.subtract(Duration(days: 1))) &&
                 recordDate.isBefore(endOfWeek.add(Duration(days: 1)));
        })
        .toList();
    
    double totalHours = 0.0;
    for (var record in weeklyRecords) {
      totalHours += record.hours;
    }
    
    return totalHours.toStringAsFixed(0);
  }

  String _calculateWeeklyAttendance() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(Duration(days: 6));
    
    final weeklyRecords = EmployeeData.currentEmployee.workStats.recentAttendance
        .where((record) {
          final recordDate = DateTime.parse(record.date);
          return recordDate.isAfter(startOfWeek.subtract(Duration(days: 1))) &&
                 recordDate.isBefore(endOfWeek.add(Duration(days: 1)));
        })
        .toList();
    
    final workingDays = 5; // Monday to Friday
    final attendedDays = weeklyRecords.length;
    final attendanceRate = (attendedDays / workingDays) * 100;
    
    return attendanceRate.toStringAsFixed(0);
  }

  String _calculateOvertimeHours() {
    final currentMonth = DateTime.now().month;
    final currentYear = DateTime.now().year;
    
    final monthlyRecords = EmployeeData.currentEmployee.workStats.recentAttendance
        .where((record) {
          final recordDate = DateTime.parse(record.date);
          return recordDate.month == currentMonth && recordDate.year == currentYear;
        })
        .toList();
    
    double overtimeHours = 0.0;
    for (var record in monthlyRecords) {
      if (record.hours > 8.0) {
        overtimeHours += (record.hours - 8.0);
      }
    }
    
    return overtimeHours.toStringAsFixed(1);
  }

  String _calculatePunctualityRate() {
    final currentMonth = DateTime.now().month;
    final currentYear = DateTime.now().year;
    
    final monthlyRecords = EmployeeData.currentEmployee.workStats.recentAttendance
        .where((record) {
          final recordDate = DateTime.parse(record.date);
          return recordDate.month == currentMonth && recordDate.year == currentYear;
        })
        .toList();
    
    if (monthlyRecords.isEmpty) return '0';
    
    int onTimeCount = 0;
    for (var record in monthlyRecords) {
      if (record.status == 'Present') {
        onTimeCount++;
      }
    }
    
    final punctualityRate = (onTimeCount / monthlyRecords.length) * 100;
    return punctualityRate.toStringAsFixed(0);
  }

  String _calculateCurrentStreak() {
    final records = EmployeeData.currentEmployee.workStats.recentAttendance;
    if (records.isEmpty) return '0';
    
    int streak = 0;
    final today = DateTime.now();
    
    for (int i = 0; i < 30; i++) { // Check last 30 days
      final checkDate = today.subtract(Duration(days: i));
      final hasRecord = records.any((record) {
        final recordDate = DateTime.parse(record.date);
        return recordDate.year == checkDate.year &&
               recordDate.month == checkDate.month &&
               recordDate.day == checkDate.day;
      });
      
      if (hasRecord) {
        streak++;
      } else {
        break;
      }
    }
    
    return streak.toString();
  }

  Widget _buildCheckInTimer() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[400]!, Colors.green[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.timer, color: Colors.white, size: 24),
              SizedBox(width: 12),
              Text(
                'Work Timer',
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            _formatElapsedTime(_calculateElapsedTime()),
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Since ${GlobalState.checkInTime ?? "N/A"}',
            style: GoogleFonts.outfit(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Duration _calculateElapsedTime() {
    if (GlobalState.checkInTime == null) return Duration.zero;
    
    try {
      final timeParts = GlobalState.checkInTime!.split(' ');
      final time = timeParts[0].split(':');
      final hour = int.parse(time[0]);
      final minute = int.parse(time[1]);
      final isPM = timeParts.length > 1 && timeParts[1] == 'PM';

      final checkInHour = isPM && hour != 12 ? hour + 12 : (hour == 12 && !isPM ? 0 : hour);
      final checkInDateTime = DateTime.now().copyWith(
        hour: checkInHour,
        minute: minute,
        second: 0,
        millisecond: 0,
      );

      final now = DateTime.now();
      return now.difference(checkInDateTime);
    } catch (e) {
      return Duration.zero;
    }
  }

  String _formatElapsedTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }


  // Removed advanced analytics section
  Widget _buildAdvancedAnalyticsSection() {
    return SizedBox.shrink(); // Empty widget
  }

}

// Leave Management Screen
class LeaveScreen extends StatefulWidget {
  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<LeaveRequest> leaveRequests = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeLeaveRequests();
  }

  void _initializeLeaveRequests() {
    try {
      if (MockData.leaveRequests.isNotEmpty) {
        setState(() {
          leaveRequests = List.from(MockData.leaveRequests);
        });
      }
    } catch (e) {
      // If there's any error, use empty list
      setState(() {
        leaveRequests = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/fortumars_logo.png',
              width: 90,
              height: 90,
              fit: BoxFit.contain,
            ),
            Expanded(
              child: Center(
                child: Text(
                  'Leave Management',
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.indigo[600],
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: Colors.indigo[600],
          tabs: [
            Tab(text: 'Apply Leave'),
            Tab(text: 'My Requests'),
            Tab(text: 'Balance'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildApplyLeaveTab(),
          _buildMyRequestsTab(),
          _buildBalanceTab(),
        ],
      ),
    );
  }

  Widget _buildApplyLeaveTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Apply for Leave',
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 20),
          _buildLeaveForm(),
        ],
      ),
    );
  }

  Widget _buildLeaveForm() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Leave Details',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 20),
          _buildFormField('Leave Type', 'Select leave type'),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildFormField('Start Date', 'Select start date', onTap: _selectDate),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildFormField('End Date', 'Select end date', onTap: _selectDate),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildFormField('Reason', 'Enter reason for leave', maxLines: 3),
          SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitLeaveRequest,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo[600],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Submit Leave Request',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField(String label, String hint, {VoidCallback? onTap, int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              hint,
              style: GoogleFonts.outfit(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _selectDate() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
  }

  void _submitLeaveRequest() {
    // Implement leave request submission
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Leave request submitted successfully'),
        backgroundColor: Colors.green[600],
      ),
    );
  }

  Widget _buildMyRequestsTab() {
    return ListView.builder(
      padding: EdgeInsets.all(20),
      itemCount: leaveRequests.length,
      itemBuilder: (context, index) {
        final request = leaveRequests[index];
        return _buildLeaveRequestCard(request);
      },
    );
  }

  Widget _buildBalanceTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Leave Balance',
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 20),
          _buildBalanceItem('Annual Leave', '20 days', '15 days remaining'),
          _buildBalanceItem('Sick Leave', '10 days', '8 days remaining'),
          _buildBalanceItem('Personal Leave', '5 days', '3 days remaining'),
        ],
      ),
    );
  }

  Widget _buildBalanceItem(String type, String total, String remaining) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            type,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Text(
            total,
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            remaining,
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: Colors.green[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveRequestCard(LeaveRequest request) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                request.type,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              _getLeaveStatusColor(request.status),
            ],
          ),
          SizedBox(height: 8),
          Text(
            '${request.startDate} - ${request.endDate}',
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 4),
          Text(
            request.reason,
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getLeaveStatusColor(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'approved':
        color = Colors.green;
        break;
      case 'pending':
        color = Colors.orange;
        break;
      case 'rejected':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}

// Attendance Report Screen
class AttendanceReportScreen extends StatefulWidget {
  @override
  _AttendanceReportScreenState createState() => _AttendanceReportScreenState();
}

class _AttendanceReportScreenState extends State<AttendanceReportScreen> {
  DateTime _selectedDate = DateTime.now();
  String _selectedFilter = 'All'; // All, Present, Late, Absent
  List<AttendanceRecord> _filteredRecords = [];

  @override
  void initState() {
    super.initState();
    _filterRecords();
  }

  void _filterRecords() {
    final currentUser = EmployeeData.currentEmployee;
    final allRecords = currentUser.workStats.recentAttendance;
    
    setState(() {
      _filteredRecords = allRecords.where((record) {
        final recordDate = DateTime.parse(record.date);
        final isDateMatch = recordDate.year == _selectedDate.year &&
                           recordDate.month == _selectedDate.month &&
                           recordDate.day == _selectedDate.day;
        
        if (!isDateMatch) return false;
        
        switch (_selectedFilter) {
          case 'Present':
            return record.status == 'Present';
          case 'Late':
            return record.status == 'Late Arrival';
          case 'Absent':
            return record.status == 'Absent';
          default:
            return true;
        }
      }).toList();
    });
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _filterRecords();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = EmployeeData.currentEmployee;
    final monthlyStats = _calculateMonthlyStats();
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Attendance Report',
          style: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Monthly Summary
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Monthly Summary',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard('Present', monthlyStats['present'].toString(), Colors.green),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard('Late', monthlyStats['late'].toString(), Colors.orange),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard('Absent', monthlyStats['absent'].toString(), Colors.red),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard('Rate', '${monthlyStats['rate']}%', Colors.blue),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            
            // Date and Filter Controls
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _selectDate,
                    child: Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today, color: Colors.grey[600]),
                          SizedBox(width: 12),
                          Text(
                            DateFormat('MMM dd, yyyy').format(_selectedDate),
                            style: GoogleFonts.outfit(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedFilter,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedFilter = newValue!;
                        _filterRecords();
                      });
                    },
                    items: ['All', 'Present', 'Late', 'Absent']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            
            // Daily Records
            Text(
              'Daily Records',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 16),
            ..._filteredRecords.map((record) => _buildRecordCard(record)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordCard(AttendanceRecord record) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 40,
            decoration: BoxDecoration(
              color: _getStatusColor(record.status),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.status,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Check-in: ${record.checkIn ?? "N/A"}',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                if (record.checkOut != null)
                  Text(
                    'Check-out: ${record.checkOut}',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
          Text(
            record.date,
            style: GoogleFonts.outfit(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Present':
        return Colors.green;
      case 'Late Arrival':
        return Colors.orange;
      case 'Absent':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Map<String, dynamic> _calculateMonthlyStats() {
    final currentMonth = DateTime.now().month;
    final currentYear = DateTime.now().year;
    
    final monthlyRecords = EmployeeData.currentEmployee.workStats.recentAttendance
        .where((record) {
          final recordDate = DateTime.parse(record.date);
          return recordDate.month == currentMonth && recordDate.year == currentYear;
        })
        .toList();
    
    int present = 0;
    int late = 0;
    int absent = 0;
    
    for (var record in monthlyRecords) {
      switch (record.status) {
        case 'Present':
          present++;
          break;
        case 'Late Arrival':
          late++;
          break;
        case 'Absent':
          absent++;
          break;
      }
    }
    
    final total = present + late + absent;
    final rate = total > 0 ? ((present / total) * 100).round() : 0;
    
    return {
      'present': present,
      'late': late,
      'absent': absent,
      'rate': rate,
    };
  }
}

// Profile Screen
class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Add listener for real-time updates
    GlobalState.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    GlobalState.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = EmployeeData.currentEmployee;
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Profile',
          style: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => _showEditProfileDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: currentUser.profileImagePath != null
                        ? FileImage(File(currentUser.profileImagePath!))
                        : null,
                    child: currentUser.profileImagePath == null
                        ? Icon(Icons.person, size: 60, color: Colors.grey[400])
                        : null,
                  ),
                  SizedBox(height: 20),
                  Text(
                    currentUser.name,
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    currentUser.role,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            
            // Personal Information
            _buildInfoSection('Personal Information', [
              _buildInfoItem('Employee ID', currentUser.empId),
              _buildInfoItem('Email', currentUser.email),
              _buildInfoItem('Phone', currentUser.phone),
              _buildInfoItem('Role', currentUser.role),
              _buildInfoItem('Department', currentUser.department),
              _buildInfoItem('Shift', currentUser.shift),
              _buildInfoItem('Status', currentUser.status),
              _buildInfoItem('Join Date', DateFormat('MMM dd, yyyy').format(currentUser.joinDate)),
              _buildInfoItem('Address', currentUser.address),
              _buildInfoItem('Emergency Contact', currentUser.emergencyContact),
              _buildInfoItem('Emergency Phone', currentUser.emergencyPhone),
              _buildInfoItem('Hourly Rate', '\$${currentUser.hourlyRate.toStringAsFixed(2)}'),
            ]),
            
            // Work Statistics
            _buildInfoSection('Work Statistics', [
              _buildInfoItem('Total Days Worked', currentUser.workStats.totalDaysWorked.toString()),
              _buildInfoItem('Total Hours Worked', '${currentUser.workStats.totalHoursWorked.toStringAsFixed(1)}h'),
              _buildInfoItem('Leave Days Used', currentUser.workStats.leaveDaysUsed.toString()),
              _buildInfoItem('Leave Days Remaining', currentUser.workStats.leaveDaysRemaining.toString()),
              _buildInfoItem('Attendance Rate', '${currentUser.workStats.attendanceRate.toStringAsFixed(1)}%'),
              _buildInfoItem('Average Daily Hours', '${currentUser.workStats.averageDailyHours.toStringAsFixed(1)}h'),
              _buildInfoItem('Late Arrivals', currentUser.workStats.lateArrivals.toString()),
              _buildInfoItem('Early Departures', currentUser.workStats.earlyDepartures.toString()),
            ]),
            
            // Actions
            _buildInfoSection('Actions', [
              _buildActionItem('Edit Profile', Icons.edit, () => _showEditProfileDialog(context)),
              _buildActionItem('Manage Face Data', Icons.face, () => _showFaceManagementDialog(context)),
              _buildActionItem('Attendance Reports', Icons.analytics, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AttendanceReportScreen()),
                );
              }),
              _buildActionItem('Settings', Icons.settings, () {}),
              _buildActionItem('Help & Support', Icons.help, () {}),
              _buildActionItem('Logout', Icons.logout, () => _showLogoutDialog(context)),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: Colors.indigo[600], size: 20),
            SizedBox(width: 16),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            Spacer(),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
          ],
        ),
      ),
    );
  }

  void _showFaceManagementDialog(BuildContext context) {
    final currentUser = EmployeeData.currentEmployee;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Face Management'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (currentUser.hasRegisteredFace) ...[
              Text('You have registered face data.'),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _registerFace();
                },
                child: Text('Update Face Data'),
              ),
            ] else ...[
              Text('You haven\'t registered face data yet.'),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _registerFace();
                },
                child: Text('Register Face Data'),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _registerFace() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FaceRegistrationScreen(),
      ),
    ).then((_) {
      setState(() {});
    });
  }

  void _showEditProfileDialog(BuildContext context) {
    final currentUser = EmployeeData.currentEmployee;
    final nameController = TextEditingController(text: currentUser.name);
    final emailController = TextEditingController(text: currentUser.email);
    final phoneController = TextEditingController(text: currentUser.phone);
    final addressController = TextEditingController(text: currentUser.address);
    final emergencyContactController = TextEditingController(text: currentUser.emergencyContact);
    final emergencyPhoneController = TextEditingController(text: currentUser.emergencyPhone);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(labelText: 'Phone'),
              ),
              TextField(
                controller: addressController,
                decoration: InputDecoration(labelText: 'Address'),
              ),
              TextField(
                controller: emergencyContactController,
                decoration: InputDecoration(labelText: 'Emergency Contact'),
              ),
              TextField(
                controller: emergencyPhoneController,
                decoration: InputDecoration(labelText: 'Emergency Phone'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              EmployeeData.updatePersonalInfo(
                name: nameController.text,
                email: emailController.text,
                phone: phoneController.text,
                address: addressController.text,
                emergencyContact: emergencyContactController.text,
                emergencyPhone: emergencyPhoneController.text,
              );
              Navigator.pop(context);
              setState(() {});
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement logout logic
            },
            child: Text('Logout'),
          ),
        ],
      ),
    );
  }
}

// Face Registration Screen
class FaceRegistrationScreen extends StatefulWidget {
  @override
  _FaceRegistrationScreenState createState() => _FaceRegistrationScreenState();
}

class _FaceRegistrationScreenState extends State<FaceRegistrationScreen> {
  bool _isCapturing = false;
  bool _isProcessing = false;
  String? _capturedImagePath;
  String? _faceData;
  CameraController? _cameraController;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _cameraController = CameraController(
          cameras.first,
          ResolutionPreset.medium,
        );
        await _cameraController!.initialize();
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Register Face',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: _isCameraInitialized
          ? _buildCameraView()
          : Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
    );
  }

  Widget _buildCameraView() {
    return Stack(
      children: [
        // Camera Preview
        Positioned.fill(
          child: CameraPreview(_cameraController!),
        ),
        
        // Overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
            ),
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _isCapturing ? Colors.green : Colors.white,
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(125),
                      ),
                      child: Center(
                        child: Text(
                          'Position your face\nwithin the circle',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Capture Button
                Padding(
                  padding: EdgeInsets.all(30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Cancel Button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.8),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.close, color: Colors.white, size: 30),
                        ),
                      ),
                      
                      // Capture Button
                      GestureDetector(
                        onTap: _isProcessing ? null : _startFaceCapture,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: _isProcessing 
                                ? Colors.grey.withValues(alpha: 0.8)
                                : Colors.white.withValues(alpha: 0.8),
                            shape: BoxShape.circle,
                          ),
                          child: _isProcessing
                              ? CircularProgressIndicator(color: Colors.black)
                              : Icon(Icons.camera_alt, color: Colors.black, size: 40),
                        ),
                      ),
                      
                      // Placeholder for symmetry
                      Container(width: 60, height: 60),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _startFaceCapture() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    setState(() {
      _isCapturing = true;
      _isProcessing = true;
    });

    try {
      // Take picture
      final XFile image = await _cameraController!.takePicture();
      
      // Simulate face processing
      await Future.delayed(Duration(seconds: 2));
      
      // Simulate face data extraction
      final faceData = 'face_data_${DateTime.now().millisecondsSinceEpoch}';
      
      setState(() {
        _capturedImagePath = image.path;
        _faceData = faceData;
        _isCapturing = false;
        _isProcessing = false;
      });
      
      // Register face with employee data
      EmployeeData.registerFace(image.path, faceData);
      
      _showRegistrationSuccess();
      
    } catch (e) {
      setState(() {
        _isCapturing = false;
        _isProcessing = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error capturing face: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showRegistrationSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 30),
            SizedBox(width: 12),
            Text('Success!'),
          ],
        ),
        content: Text('Face registered successfully! You can now use facial recognition for check-in.'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to profile
            },
            child: Text('Continue'),
          ),
        ],
      ),
    );
  }
}

// Face Verification Screen
class FaceVerificationScreen extends StatefulWidget {
  @override
  _FaceVerificationScreenState createState() => _FaceVerificationScreenState();
}

class _FaceVerificationScreenState extends State<FaceVerificationScreen> {
  bool _isScanning = false;
  bool _isProcessing = false;
  String? _verificationResult;
  String? _errorMessage;
  CameraController? _cameraController;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _cameraController = CameraController(
          cameras.first,
          ResolutionPreset.medium,
        );
        await _cameraController!.initialize();
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Face Verification',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: _isCameraInitialized
          ? _buildCameraView()
          : Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
    );
  }

  Widget _buildCameraView() {
    return Stack(
      children: [
        // Camera Preview
        Positioned.fill(
          child: CameraPreview(_cameraController!),
        ),
        
        // Overlay
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
            ),
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _isScanning ? Colors.green : Colors.white,
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(125),
                      ),
                      child: Center(
                        child: Text(
                          'Look at the camera\nfor verification',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                
                // Action Buttons
                Padding(
                  padding: EdgeInsets.all(30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Cancel Button
                      GestureDetector(
                        onTap: () => Navigator.pop(context, false),
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.8),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.close, color: Colors.white, size: 30),
                        ),
                      ),
                      
                      // Scan Button
                      GestureDetector(
                        onTap: _isProcessing ? null : _startFaceVerification,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: _isProcessing 
                                ? Colors.grey.withValues(alpha: 0.8)
                                : Colors.white.withValues(alpha: 0.8),
                            shape: BoxShape.circle,
                          ),
                          child: _isProcessing
                              ? CircularProgressIndicator(color: Colors.black)
                              : Icon(Icons.face, color: Colors.black, size: 40),
                        ),
                      ),
                      
                      // Placeholder for symmetry
                      Container(width: 60, height: 60),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _startFaceVerification() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    setState(() {
      _isScanning = true;
      _isProcessing = true;
    });

    try {
      // Take picture
      final XFile image = await _cameraController!.takePicture();
      
      // Simulate face verification process
      await Future.delayed(Duration(seconds: 3));
      
      // Check if user has registered face data
      final currentUser = EmployeeData.currentEmployee;
      if (!currentUser.hasRegisteredFace) {
        setState(() {
          _isScanning = false;
          _isProcessing = false;
        });
        _showVerificationError('No registered face found. Please register your face first in Profile > Manage Face Data.');
        return;
      }
      
      // Simulate verification result (20% success rate for better security)
      final isVerified = DateTime.now().millisecondsSinceEpoch % 5 == 0;
      
      setState(() {
        _isScanning = false;
        _isProcessing = false;
        _verificationResult = isVerified ? 'success' : 'failed';
      });
      
      if (isVerified) {
        _showVerificationSuccess();
      } else {
        _showVerificationError('Face verification failed. Please ensure good lighting and try again.');
      }
      
    } catch (e) {
      setState(() {
        _isScanning = false;
        _isProcessing = false;
      });
      
      _showVerificationError('Error during verification: $e');
    }
  }

  void _showVerificationSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 30),
            SizedBox(width: 12),
            Text('Verification Successful!'),
          ],
        ),
        content: Text('Face verified successfully!'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context, true); // Return success
            },
            child: Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showVerificationError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red, size: 30),
            SizedBox(width: 12),
            Text('Verification Failed'),
          ],
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Try Again'),
          ),
        ],
      ),
    );
  }
}

// Attendance Screen with all features
class AttendanceScreen extends StatefulWidget {
  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  String attendanceMethod = 'facial';
  bool showCamera = false;
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _timer;
  Duration _elapsedTime = Duration.zero;
  
  bool get isCheckedIn => GlobalState.isCheckedIn;
  String? get checkInTime => GlobalState.checkInTime;

  @override
  void initState() {
    super.initState();
    GlobalState.addListener(_onStateChanged);
    _startTimer();
    // Refresh data when screen becomes visible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data when dependencies change
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    GlobalState.removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Stack(
        children: [
          _buildMainContent(),
          if (_isLoading) _buildLoadingOverlay(),
          if (_errorMessage != null) _buildErrorSnackBar(),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/fortumars_logo.png',
              width: 90,
              height: 90,
              fit: BoxFit.contain,
            ),
            Expanded(
              child: Center(
                child: Text(
                  'Attendance',
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Main Attendance Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isCheckedIn 
                      ? [Colors.green[400]!, Colors.green[600]!]
                      : [Colors.indigo[400]!, Colors.indigo[600]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: (isCheckedIn ? Colors.green : Colors.indigo).withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    isCheckedIn ? Icons.check_circle : Icons.login,
                    size: 60,
                    color: Colors.white,
                  ),
                  SizedBox(height: 16),
                  Text(
                    isCheckedIn ? 'Checked In' : 'Not Checked In',
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  if (isCheckedIn) ...[
                    SizedBox(height: 8),
                    Text(
                      'Time: ${checkInTime ?? "N/A"}',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    Text(
                      _getCheckInStatusText(),
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: _getCheckInStatusColor(),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 12),
                    // Elapsed Time Timer
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Elapsed Time',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            _formatElapsedTime(_elapsedTime),
                            style: GoogleFonts.outfit(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: 20),

            // Expected Times Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Expected Times',
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTimeItem(
                          'Check-in',
                          '${AttendanceConstants.standardCheckIn}',
                          'Â±${AttendanceConstants.lateToleranceMinutes} min',
                          Colors.green,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _buildTimeItem(
                          'Check-out',
                          '${AttendanceConstants.standardCheckOut}',
                          'Â±${AttendanceConstants.earlyCheckoutToleranceMinutes} min',
                          Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Check-in/Check-out Buttons
            if (!isCheckedIn) ...[
              _buildCheckInButton(),
            ] else ...[
              _buildCheckOutButton(),
            ],
            SizedBox(height: 20),

            // Attendance Summary
            _buildAttendanceSummary(),
            SizedBox(height: 20),

            // Recent History
            _buildRecentHistory(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeItem(String title, String time, String tolerance, Color color) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            time,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            tolerance,
            style: GoogleFonts.outfit(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckInButton() {
    return Column(
      children: [
        // Method Selection
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Check-in Method',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildMethodOption(
                      'Facial Recognition',
                      Icons.face,
                      'facial',
                      attendanceMethod == 'facial',
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _buildMethodOption(
                      'QR Scanner',
                      Icons.qr_code_scanner,
                      'qr',
                      attendanceMethod == 'qr',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 16),
        
        // Check-in Button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () => _performCheckIn(attendanceMethod),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.login, size: 24),
                SizedBox(width: 12),
                Text(
                  'Check In',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckOutButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _checkOut,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[600],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, size: 24),
            SizedBox(width: 12),
            Text(
              'Check Out',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodOption(String title, IconData icon, String value, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          attendanceMethod = value;
        });
      },
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.indigo[50] : Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.indigo[600]! : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.indigo[600] : Colors.grey[600],
              size: 32,
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.indigo[600] : Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceSummary() {
    final currentUser = EmployeeData.currentEmployee;
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s Summary',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem('Hours Worked', _calculateHours()),
              ),
              Expanded(
                child: _buildSummaryItem('Status', isCheckedIn ? 'Active' : 'Inactive'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildRecentHistory() {
    final currentUser = EmployeeData.currentEmployee;
    final recentAttendance = currentUser.workStats.recentAttendance.take(5).toList();
    
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent History',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          ...recentAttendance.map((record) => _buildHistoryItem(record)).toList(),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(AttendanceRecord record) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 40,
            decoration: BoxDecoration(
              color: _getStatusColor(record.status),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.status,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '${record.checkIn ?? "N/A"} - ${record.checkOut ?? "N/A"}',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            record.date,
            style: GoogleFonts.outfit(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Present':
        return Colors.green;
      case 'Late Arrival':
        return Colors.orange;
      case 'Absent':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _performCheckIn(String method) {
    print('Performing check-in via $method'); // Debug log
    
    // Check if facial recognition is required
    if (method == 'facial') {
      final currentUser = EmployeeData.currentEmployee;
      if (!currentUser.hasRegisteredFace) {
        _showError('Please register your face first in Profile > Manage Face Data');
        return;
      }
      
      // Navigate to face verification
      _showFaceVerificationForCheckIn();
      return;
    }
    
    // For QR code or other methods, proceed directly
    if (method == 'qr') {
      _showQRScanner();
    } else {
      _processCheckIn(method);
    }
  }

  void _showFaceVerificationForCheckIn() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FaceVerificationScreen(),
      ),
    ).then((result) {
      if (result == true) {
        _processCheckIn('facial');
      } else {
        _showError('Face verification failed. Please try again.');
      }
    });
  }

  void _showQRScanner() {
    // Simulate QR code scanning
    _showLoading(true);
    
    Timer(Duration(seconds: 2), () {
      _showLoading(false);
      
      // Simulate QR code validation (90% success rate)
      final isQRValid = DateTime.now().millisecondsSinceEpoch % 10 != 0;
      
      if (isQRValid) {
        _processCheckIn('qr');
      } else {
        _showError('Invalid QR code. Please try again.');
      }
    });
  }

  void _processCheckIn(String method) {
    // Show loading
    _showLoading(true);
    
    // Simulate processing time
    Timer(Duration(milliseconds: 1500), () {
      final checkInTimeStr = TimeOfDay.now().format(context);
      final checkInStatus = EmployeeData._getCheckInStatus(checkInTimeStr);
      
      print('Check-in time: $checkInTimeStr'); // Debug log
      print('Check-in status: $checkInStatus'); // Debug log
      
      // Update global state
      GlobalState.setCheckInStatus(true, checkInTimeStr, method);
      
      // Start the timer
      _startTimer();
      
      
      setState(() {
        // Trigger rebuild
      });
      
      print('State updated - isCheckedIn: ${GlobalState.isCheckedIn}, checkInTime: ${GlobalState.checkInTime}'); // Debug log
      
      // Hide loading
      _showLoading(false);
      
      // Show success feedback
      _showSuccessFeedback(checkInStatus == 'Late' ? 'late' : 'success');

      // Add attendance record to real-time data
      final attendanceRecord = AttendanceRecord(
        date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        checkIn: checkInTimeStr,
        checkOut: null,
        hours: 0.0,
        status: checkInStatus == 'Late' ? 'Late Arrival' : 'Present',
        method: method,
        location: 'Office',
      );

      EmployeeData.addAttendanceRecord(attendanceRecord);
      print('Employee data updated and saved'); // Debug log

      // Show success message
      String message;
      Color backgroundColor;
      if (checkInStatus == 'Late') {
        message = 'Checked in late via $method ($checkInTimeStr)';
        backgroundColor = Colors.orange[600]!;
      } else {
        message = 'Checked in successfully via $method ($checkInTimeStr)';
        backgroundColor = Colors.green[600]!;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'View Dashboard',
            textColor: Colors.white,
            onPressed: () {
              Navigator.pop(context); // Go back to dashboard
            },
          ),
        ),
      );
    });
  }

  void _checkOut() {
    final currentUser = EmployeeData.currentEmployee;
    
    if (currentUser.hasRegisteredFace) {
      _showFaceVerificationForCheckOut();
    } else {
      _performCheckOut();
    }
  }

  void _showFaceVerificationForCheckOut() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FaceVerificationScreen(),
      ),
    ).then((result) {
      if (result == true) {
        _performCheckOut();
      }
    });
  }

  void _performCheckOut() {
    final checkOutTimeStr = TimeOfDay.now().format(context);
    final currentUser = EmployeeData.currentEmployee;
    
    // Find the latest attendance record for today
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final todayRecords = currentUser.workStats.recentAttendance
        .where((record) => record.date == today)
        .toList();
    
    if (todayRecords.isNotEmpty) {
      final latestRecord = todayRecords.first;
      final checkInTime = _parseTimeString(latestRecord.checkIn!);
      final checkOutTime = _parseTimeString(checkOutTimeStr);
      final hoursWorked = _calculateHoursWorked(checkInTime, checkOutTime);
      
      // Determine check-out status
      final checkOutStatus = EmployeeData._getCheckOutStatus(checkOutTimeStr);
      
      // Update the record - create a new record with updated values
      final updatedRecord = AttendanceRecord(
        date: latestRecord.date,
        checkIn: latestRecord.checkIn,
        checkOut: checkOutTimeStr,
        hours: hoursWorked,
        status: checkOutStatus == 'Early' ? 'Early Departure' : latestRecord.status,
        method: latestRecord.method,
        location: latestRecord.location,
      );
      
      // Replace the old record with the updated one
      final index = currentUser.workStats.recentAttendance.indexOf(latestRecord);
      if (index != -1) {
        currentUser.workStats.recentAttendance[index] = updatedRecord;
      }
      
      // Update work statistics - recalculate from all attendance records
      final newStats = EmployeeData._calculateWorkStatistics(currentUser.workStats.recentAttendance);
      EmployeeData.updateWorkStats(newStats);
      
      print('Check-out completed: $checkOutTimeStr, Hours: $hoursWorked');
    }
    
    // Reset global state
    GlobalState.resetCheckInStatus();
    
    // Stop the timer
    _timer?.cancel();
    _elapsedTime = Duration.zero;
    
    setState(() {});
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Checked out successfully at $checkOutTimeStr'),
        backgroundColor: Colors.blue[600],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  TimeOfDay _parseTimeString(String timeStr) {
    final timeParts = timeStr.split(' ');
    final time = timeParts[0].split(':');
    final hour = int.parse(time[0]);
    final minute = int.parse(time[1]);
    final isPM = timeParts.length > 1 && timeParts[1] == 'PM';

    return TimeOfDay(
      hour: isPM && hour != 12 ? hour + 12 : (hour == 12 && !isPM ? 0 : hour),
      minute: minute,
    );
  }

  double _calculateHoursWorked(TimeOfDay checkIn, TimeOfDay checkOut) {
    final checkInMinutes = checkIn.hour * 60 + checkIn.minute;
    final checkOutMinutes = checkOut.hour * 60 + checkOut.minute;
    final totalMinutes = checkOutMinutes - checkInMinutes;
    return totalMinutes / 60.0;
  }

  String _calculateHours() {
    if (checkInTime == null) return '0.0';
    // Simple calculation - in real app, calculate actual hours
    return '${DateTime.now().difference(DateTime.now().subtract(Duration(hours: 2))).inHours}.0';
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.5),
      child: Center(
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Processing...',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorSnackBar() {
    return Positioned(
      top: 100,
      left: 16,
      right: 16,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red[600],
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                _errorMessage!,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.close, color: Colors.white),
              onPressed: () {
                setState(() {
                  _errorMessage = null;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLoading(bool loading) {
    setState(() {
      _isLoading = loading;
    });
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
    });
    // Auto-hide error after 5 seconds
    Timer(Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _errorMessage = null;
        });
      }
    });
  }

  void _showSuccessFeedback(String type) {
    // Haptic feedback
    // HapticFeedback.lightImpact(); // Uncomment when haptic_feedback package is added
    
    // Visual feedback with animation
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: type == 'success' ? Colors.green[100] : Colors.orange[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  type == 'success' ? Icons.check_circle : Icons.schedule,
                  color: type == 'success' ? Colors.green[600] : Colors.orange[600],
                  size: 40,
                ),
              ),
              SizedBox(height: 16),
              Text(
                type == 'success' ? 'Check-in Successful!' : 'Late Check-in',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 8),
              Text(
                type == 'success' 
                  ? 'You have successfully checked in'
                  : 'You checked in late today',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: type == 'success' ? Colors.green[600] : Colors.orange[600],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );

    // Auto-close after 3 seconds
    Timer(Duration(seconds: 3), () {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    });
  }

  String _getCheckInStatusText() {
    if (checkInTime == null) return '';
    final status = EmployeeData._getCheckInStatus(checkInTime!);
    return status == 'Late' ? 'Late Arrival' : 'On Time';
  }

  Color _getCheckInStatusColor() {
    if (checkInTime == null) return Colors.grey;
    final status = EmployeeData._getCheckInStatus(checkInTime!);
    return status == 'Late' ? Colors.orange : Colors.green;
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted && isCheckedIn && checkInTime != null) {
        _updateElapsedTime();
      }
    });
  }

  void _updateElapsedTime() {
    if (checkInTime != null) {
      try {
        // Parse the check-in time
        final timeParts = checkInTime!.split(' ');
        final time = timeParts[0].split(':');
        final hour = int.parse(time[0]);
        final minute = int.parse(time[1]);
        final isPM = timeParts.length > 1 && timeParts[1] == 'PM';

        final checkInHour = isPM && hour != 12 ? hour + 12 : (hour == 12 && !isPM ? 0 : hour);
        final checkInDateTime = DateTime.now().copyWith(
          hour: checkInHour,
          minute: minute,
          second: 0,
          millisecond: 0,
        );

        final now = DateTime.now();
        _elapsedTime = now.difference(checkInDateTime);
        
        if (mounted) {
          setState(() {});
        }
      } catch (e) {
        print('Error calculating elapsed time: $e');
      }
    }
  }

  String _formatElapsedTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

}

// Notification Service
class NotificationService {
  static Future<void> initialize() async {
    // Simplified notification service
    print('Notification service initialized');
  }

  static Future<void> showCheckInReminder() async {
    print('Check-in reminder: Time to check in!');
  }

  static Future<void> showCheckOutReminder() async {
    print('Check-out reminder: Time to check out!');
  }

  static Future<void> showAchievementUnlocked(String achievementName) async {
    print('Achievement unlocked: $achievementName');
  }

  static Future<void> showStreakMilestone(int streak) async {
    print('Streak milestone: $streak days!');
  }
}
