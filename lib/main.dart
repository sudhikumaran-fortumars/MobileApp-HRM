<<<<<<< HEAD
﻿import 'package:flutter/material.dart';
=======
import 'package:flutter/material.dart';
>>>>>>> 3b9ce857a92dc199a5e3d88b6807ade16bfdb101
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
<<<<<<< HEAD
import 'widgets/live_clock_widget.dart';
import 'widgets/work_timer_widget.dart';
import 'widgets/checkin_status_widget.dart';
import 'screens/attendance_analytics_screen.dart';
import 'services/work_timer_service.dart';
=======
>>>>>>> 3b9ce857a92dc199a5e3d88b6807ade16bfdb101
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

  // Seed initial data for testing
  // try {
  //   await DataSeeder.seedAllData();
  // } catch (e) {
  //   print('Error seeding data: $e');
  // }

  runApp(FortuMarsHRMApp());
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
  final String role;
  final String department;
  final String shift;
  final String status;
  final double hourlyRate;
  final Location location;

  Employee({
    required this.empId,
    required this.name,
    required this.role,
    required this.department,
    required this.shift,
    required this.status,
    required this.hourlyRate,
    required this.location,
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

class Task {
  final String id;
  final String title;
  final String assignedTo;
  final String assignedBy;
  final String deadline;
  final String status;
  final String priority;
  final int estimatedHours;
  final String? description;

  Task({
    required this.id,
    required this.title,
    required this.assignedTo,
    required this.assignedBy,
    required this.deadline,
    required this.status,
    required this.priority,
    required this.estimatedHours,
    this.description,
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

<<<<<<< HEAD
// Real-time data management
class DataManager {
  static Employee? _currentUser;
  static List<Map<String, dynamic>> _attendanceHistory = [];
  static List<LeaveRequest> _leaveRequests = [];

  static Employee? get currentUser => _currentUser;
  static List<Map<String, dynamic>> get attendanceHistory => _attendanceHistory;
  static List<LeaveRequest> get leaveRequests => _leaveRequests;

  static void setCurrentUser(Employee user) {
    _currentUser = user;
  }

  static void addAttendanceRecord(Map<String, dynamic> record) {
    _attendanceHistory.insert(0, record);
  }

  static void updateAttendanceRecord(int index, Map<String, dynamic> record) {
    if (index >= 0 && index < _attendanceHistory.length) {
      _attendanceHistory[index] = record;
    }
  }

  static void addLeaveRequest(LeaveRequest request) {
    _leaveRequests.add(request);
  }

  static void clearData() {
    _currentUser = null;
    _attendanceHistory.clear();
    _leaveRequests.clear();
=======
// Mock Data
class MockData {
  static List<Employee> get employees {
    try {
      return [
        Employee(
          empId: 'EMP001',
          name: 'Sudhi Kumaran',
          role: 'Frontend & Backend Developer',
          department: 'Development',
          shift: 'Morning',
          status: 'Active',
          hourlyRate: 200,
          location: Location(lat: 11.1085, lng: 77.3411),
        ),
        Employee(
          empId: 'EMP002',
          name: 'Akash Kumar',
          role: 'Frontend & Backend Developer',
          department: 'Development',
          shift: 'Morning',
          status: 'Active',
          hourlyRate: 180,
          location: Location(lat: 11.1085, lng: 77.3411),
        ),
        Employee(
          empId: 'EMP003',
          name: 'BalaMurugan',
          role: 'Frontend Developer',
          department: 'Development',
          shift: 'Evening',
          status: 'Active',
          hourlyRate: 150,
          location: Location(lat: 11.1085, lng: 77.3411),
        ),
      ];
    } catch (e) {
      return [
        Employee(
          empId: 'EMP001',
          name: 'Sudhi Kumaran',
          role: 'Frontend & Backend Developer',
          department: 'Development',
          shift: 'Morning',
          status: 'Active',
          hourlyRate: 200,
          location: Location(lat: 11.1085, lng: 77.3411),
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

  static List<Task> get tasks {
    try {
      return [
        Task(
          id: 'TASK001',
          title: 'Develop Login System',
          assignedTo: 'EMP001',
          assignedBy: 'ADMIN',
          deadline: '2024-08-25',
          status: 'In Progress',
          priority: 'High',
          estimatedHours: 8,
          description: 'Implement JWT-based authentication system',
        ),
        Task(
          id: 'TASK002',
          title: 'Design Dashboard UI',
          assignedTo: 'EMP003',
          assignedBy: 'EMP001',
          deadline: '2024-08-26',
          status: 'Pending',
          priority: 'Medium',
          estimatedHours: 6,
          description: 'Create responsive dashboard interface',
        ),
      ];
    } catch (e) {
      return [];
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
>>>>>>> 3b9ce857a92dc199a5e3d88b6807ade16bfdb101
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
<<<<<<< HEAD
    // Initialize with a default user for demo purposes
    // In a real app, this would come from authentication/login
    setState(() {
      currentUser = Employee(
        empId: 'EMP001',
        name: 'Current User',
        role: 'Employee',
        department: 'Development',
        shift: 'Morning',
        status: 'Active',
        hourlyRate: 200,
        location: Location(lat: 11.1085, lng: 77.3411),
      );
      DataManager.setCurrentUser(currentUser!);
    });
=======
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
            role: 'Frontend & Backend Developer',
            department: 'Development',
            shift: 'Morning',
            status: 'Active',
            hourlyRate: 200,
            location: Location(lat: 11.1085, lng: 77.3411),
          );
        });
      }
    } catch (e) {
      // If there's any error, create a fallback employee
      setState(() {
        currentUser = Employee(
          empId: 'EMP001',
          name: 'Sudhi Kumaran',
          role: 'Frontend & Backend Developer',
          department: 'Development',
          shift: 'Morning',
          status: 'Active',
          hourlyRate: 200,
          location: Location(lat: 11.1085, lng: 77.3411),
        );
      });
    }
>>>>>>> 3b9ce857a92dc199a5e3d88b6807ade16bfdb101
  }

  final List<Widget> _screens = [
    DashboardScreen(),
    AttendanceScreen(),
<<<<<<< HEAD
    AttendanceAnalyticsScreen(),
=======
    TaskScreen(),
>>>>>>> 3b9ce857a92dc199a5e3d88b6807ade16bfdb101
    LeaveScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

<<<<<<< HEAD
    // Ensure current index is within valid range
    final safeIndex = _currentIndex.clamp(0, _screens.length - 1);
    if (_currentIndex != safeIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _currentIndex = safeIndex;
          });
        }
      });
    }

    return Scaffold(
      body: _screens[safeIndex],
=======
    return Scaffold(
      body: _screens[_currentIndex],
>>>>>>> 3b9ce857a92dc199a5e3d88b6807ade16bfdb101
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
<<<<<<< HEAD
            final safeIndex = index.clamp(0, _screens.length - 1);
            setState(() {
              _currentIndex = safeIndex;
=======
            setState(() {
              _currentIndex = index;
>>>>>>> 3b9ce857a92dc199a5e3d88b6807ade16bfdb101
            });
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
<<<<<<< HEAD
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics),
              label: 'Analytics',
            ),
=======
            BottomNavigationBarItem(icon: Icon(Icons.task), label: 'Tasks'),
>>>>>>> 3b9ce857a92dc199a5e3d88b6807ade16bfdb101
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

// Dashboard Screen
<<<<<<< HEAD
class DashboardScreen extends StatefulWidget {
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final WorkTimerService _workTimerService = WorkTimerService();
  bool _isCheckedIn = false;
  String? _checkInTime;

  @override
  void initState() {
    super.initState();
    _workTimerService.addListener(_onTimerChanged);
    _workTimerService.loadTimerState();
    _loadCheckInStatus();
  }

  @override
  void dispose() {
    _workTimerService.removeListener(_onTimerChanged);
    super.dispose();
  }

  void _onTimerChanged() {
    if (mounted) {
      setState(() {
        _isCheckedIn = _workTimerService.isRunning;
        _checkInTime = _workTimerService.startTime?.toString().substring(11, 16);
      });
    }
  }

  Future<void> _loadCheckInStatus() async {
    // Check if timer is running to determine check-in status
    setState(() {
      _isCheckedIn = _workTimerService.isRunning;
      _checkInTime = _workTimerService.startTime?.toString().substring(11, 16);
    });
  }

=======
class DashboardScreen extends StatelessWidget {
>>>>>>> 3b9ce857a92dc199a5e3d88b6807ade16bfdb101
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

<<<<<<< HEAD
            // Live Clock Widget
            LiveClockWidget(),
            SizedBox(height: 20),

            // Check-in Status
            CheckInStatusWidget(
              isCheckedIn: _isCheckedIn,
              checkInTime: _checkInTime,
            ),
            SizedBox(height: 20),

=======
>>>>>>> 3b9ce857a92dc199a5e3d88b6807ade16bfdb101
            // Quick Stats
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Hours Today',
<<<<<<< HEAD
                    _workTimerService.isRunning ? _workTimerService.hoursWorked.toStringAsFixed(1) : '0.0',
                    Icons.timer,
                    _workTimerService.isRunning ? Colors.green : Colors.grey,
=======
                    '8.0',
                    Icons.timer,
                    Colors.green,
>>>>>>> 3b9ce857a92dc199a5e3d88b6807ade16bfdb101
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _buildStatCard(
                    'Tasks Pending',
                    '2',
                    Icons.assignment,
                    Colors.orange,
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
                    '160h',
                    Icons.calendar_month,
                    Colors.blue,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _buildStatCard(
                    'Leave Balance',
                    '12',
                    Icons.beach_access,
                    Colors.purple,
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
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AttendanceScreen(),
                      ),
                    ),
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
<<<<<<< HEAD
=======
                Expanded(
                  child: _buildActionCard(
                    'View Tasks',
                    Icons.task,
                    Colors.purple,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TaskScreen()),
                    ),
                  ),
                ),
>>>>>>> 3b9ce857a92dc199a5e3d88b6807ade16bfdb101
              ],
            ),
            SizedBox(height: 20),

<<<<<<< HEAD

=======
>>>>>>> 3b9ce857a92dc199a5e3d88b6807ade16bfdb101
            // Recent Activity
            Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
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
                children: [
                  _buildActivityItem(
                    'Checked in at 9:00 AM',
                    'Today',
                    Icons.login,
                    Colors.green,
                  ),
                  Divider(height: 1),
                  _buildActivityItem(
                    'Task "Develop Login System" updated',
                    '2 hours ago',
                    Icons.task,
                    Colors.blue,
                  ),
                  Divider(height: 1),
                  _buildActivityItem(
                    'Leave request submitted',
                    'Yesterday',
                    Icons.calendar_today,
                    Colors.orange,
                  ),
                ],
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
}

// Attendance Screen with all features
class AttendanceScreen extends StatefulWidget {
  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

<<<<<<< HEAD
class _AttendanceScreenState extends State<AttendanceScreen> with TickerProviderStateMixin {
  bool isCheckedIn = false;
  String? checkInTime;
  String? checkOutTime;
  String attendanceMethod = 'facial';
  bool showCamera = false;
  bool isOnBreak = false;
  String? breakStartTime;
  int totalBreakMinutes = 0;
  int selectedTabIndex = 0;
  
  final WorkTimerService _workTimerService = WorkTimerService();
  
  
  List<Map<String, dynamic>> get attendanceHistory => DataManager.attendanceHistory;
  
  @override
  void initState() {
    super.initState();
    _workTimerService.addListener(_onTimerChanged);
    _workTimerService.loadTimerState();
    
    // Initialize check-in status based on timer service
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          isCheckedIn = _workTimerService.isRunning;
          isOnBreak = _workTimerService.isOnBreak;
          if (isCheckedIn && _workTimerService.startTime != null) {
            checkInTime = _workTimerService.startTime!.toString().substring(11, 16);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _workTimerService.removeListener(_onTimerChanged);
    super.dispose();
  }

  void _onTimerChanged() {
    if (mounted) {
      setState(() {
        // Sync check-in status with timer service
        isCheckedIn = _workTimerService.isRunning;
        // Update check-in time if we just checked in
        if (isCheckedIn && checkInTime == null) {
          checkInTime = _workTimerService.startTime?.toString().substring(11, 16);
        }
        // Update break status
        isOnBreak = _workTimerService.isOnBreak;
      });
    }
  }
  
=======
class _AttendanceScreenState extends State<AttendanceScreen> {
  bool isCheckedIn = false;
  String? checkInTime;
  String attendanceMethod = 'facial';
  bool showCamera = false;
>>>>>>> 3b9ce857a92dc199a5e3d88b6807ade16bfdb101

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
                  'Attendance',
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
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
<<<<<<< HEAD
            // Enhanced Current Status Card
            Container(
              width: double.infinity,
                    padding: EdgeInsets.all(30),
=======
            // Current Status Card
            AnimatedContainer(
              duration: Duration(milliseconds: 500),
              width: double.infinity,
              padding: EdgeInsets.all(25),
>>>>>>> 3b9ce857a92dc199a5e3d88b6807ade16bfdb101
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isCheckedIn
                      ? [Color(0xFF00b09b), Color(0xFF96c93d)]
                      : [Color(0xFFff416c), Color(0xFFff4b2b)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
<<<<<<< HEAD
                      borderRadius: BorderRadius.circular(30),
=======
                borderRadius: BorderRadius.circular(25),
>>>>>>> 3b9ce857a92dc199a5e3d88b6807ade16bfdb101
                boxShadow: [
                  BoxShadow(
                    color: (isCheckedIn ? Color(0xFF00b09b) : Color(0xFFff416c))
                        .withValues(alpha: 0.4),
<<<<<<< HEAD
                          blurRadius: 30,
                          offset: Offset(0, 15),
=======
                    blurRadius: 25,
                    offset: Offset(0, 12),
>>>>>>> 3b9ce857a92dc199a5e3d88b6807ade16bfdb101
                  ),
                ],
              ),
              child: Column(
                children: [
<<<<<<< HEAD
                        // Status Icon with Animation
                        Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                    isCheckedIn ? Icons.check_circle : Icons.access_time,
                    color: Colors.white,
                            size: 60,
                  ),
                        ),
                        SizedBox(height: 20),
                        
                        // Status Text
=======
                  Icon(
                    isCheckedIn ? Icons.check_circle : Icons.access_time,
                    color: Colors.white,
                    size: 50,
                  ),
                  SizedBox(height: 10),
>>>>>>> 3b9ce857a92dc199a5e3d88b6807ade16bfdb101
                  Text(
                    isCheckedIn ? 'Checked In' : 'Not Checked In',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
<<<<<<< HEAD
                            fontSize: 28,
=======
                      fontSize: 26,
>>>>>>> 3b9ce857a92dc199a5e3d88b6807ade16bfdb101
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
<<<<<<< HEAD
                        
                        // Time Information
                        if (checkInTime != null) ...[
                          SizedBox(height: 8),
                    Text(
                      'Since $checkInTime',
                            style: GoogleFonts.outfit(
                              color: Colors.white70,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                        
                        // Break Status
                        if (isCheckedIn && isOnBreak) ...[
                          SizedBox(height: 8),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.coffee, color: Colors.white, size: 16),
                                SizedBox(width: 8),
                                Text(
                                  'On Break - $breakStartTime',
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                  ),
                ],
              ),
                          ),
                        ],
                        
                        SizedBox(height: 25),
                        
                        // Work Timer (only when checked in)
                        if (isCheckedIn) ...[
                          WorkTimerWidget(),
                          SizedBox(height: 25),
                        ],
                        
                        // Check-in Methods (only when not checked in)
                        if (!isCheckedIn) ...[
                  Text(
                            'Choose Check-in Method',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                              fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                          SizedBox(height: 20),
                  Row(
                    children: [
                              // Facial Recognition Button
                      Expanded(
                                child: _buildCheckInMethodCard(
                                  'Facial Recognition',
                                  'Use camera for face detection',
                                  Icons.face,
                                  Colors.blue,
                                  () => _showFacialRecognition(),
                                ),
                              ),
                              SizedBox(width: 12),
                              // QR Code Button
                              Expanded(
                                child: _buildCheckInMethodCard(
                                  'QR Code Scan',
                                  'Scan office QR code',
                                  Icons.qr_code_scanner,
                          Colors.green,
                                  () => _showQRScanner(),
                                ),
                              ),
                            ],
                          ),
                        ],
                        
                        // Action Buttons (when checked in)
                        if (isCheckedIn) ...[
                          Row(
                            children: [
                              // Check Out Button
                      Expanded(
                                flex: 2,
                                child: AnimatedContainer(
                                  duration: Duration(milliseconds: 300),
                                  child: ElevatedButton(
                                    onPressed: _checkOut,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.red,
                                      padding: EdgeInsets.symmetric(vertical: 20),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      elevation: 10,
                                      shadowColor: Colors.red.withValues(alpha: 0.4),
                                    ),
                                    child: Text(
                          'Check Out',
                                      style: GoogleFonts.outfit(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              
                              // Break Button
                              SizedBox(width: 12),
                      Expanded(
                                child: ElevatedButton(
                                  onPressed: isOnBreak ? _endBreak : _startBreak,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isOnBreak ? Colors.red : Colors.orange,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(vertical: 20),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    elevation: 10,
                                    shadowColor: (isOnBreak ? Colors.red : Colors.orange)
                                        .withValues(alpha: 0.4),
                                  ),
                                  child: Text(
                                    isOnBreak ? 'End Break' : 'Break',
                                    style: GoogleFonts.outfit(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
=======
                  if (checkInTime != null)
                    Text(
                      'Since $checkInTime',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      child: ElevatedButton(
                        onPressed: isCheckedIn
                            ? _checkOut
                            : _showAttendanceOptions,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: isCheckedIn
                              ? Colors.red
                              : Colors.green,
                          padding: EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 8,
                          shadowColor: (isCheckedIn ? Colors.red : Colors.green)
                              .withValues(alpha: 0.3),
                        ),
                        child: Text(
                          isCheckedIn ? 'Check Out' : 'Check In',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Today's Summary
            AnimatedContainer(
              duration: Duration(milliseconds: 400),
              width: double.infinity,
              padding: EdgeInsets.all(25),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.white, Color(0xFFf8f9fa)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: Colors.grey.withValues(alpha: 0.1),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today\'s Summary',
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
                        child: _buildSummaryItem(
                          'Check In',
                          checkInTime ?? '--:--',
                          Icons.login,
                          Colors.green,
                        ),
                      ),
                      Expanded(
                        child: _buildSummaryItem(
                          'Check Out',
                          isCheckedIn ? '--:--' : '18:00',
                          Icons.logout,
                          Colors.red,
                        ),
                      ),
                      Expanded(
                        child: _buildSummaryItem(
                          'Hours',
                          isCheckedIn ? _calculateHours() : '8.0',
                          Icons.timer,
                          Colors.blue,
>>>>>>> 3b9ce857a92dc199a5e3d88b6807ade16bfdb101
                        ),
                      ),
                    ],
                  ),
<<<<<<< HEAD
                        ],
                ],
              ),
            ),
            SizedBox(height: 25),

            // Tab Navigation
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
=======
                ],
              ),
            ),
            SizedBox(height: 20),

            // Attendance History
            Text(
              'Attendance History',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                letterSpacing: 0.3,
              ),
            ),
            SizedBox(height: 15),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
>>>>>>> 3b9ce857a92dc199a5e3d88b6807ade16bfdb101
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
<<<<<<< HEAD
              child: Row(
                children: [
                  Expanded(
                    child: _buildTabButton('Today', 0, Icons.today),
                  ),
                  Expanded(
                    child: _buildTabButton('History', 1, Icons.history),
                  ),
                  Expanded(
                    child: _buildTabButton('Stats', 2, Icons.analytics),
=======
              child: Column(
                children: [
                  _buildHistoryItem(
                    'August 21, 2024',
                    '09:15 - 18:30',
                    '8.25 hrs',
                    'Present',
                    Colors.green,
                  ),
                  Divider(height: 1),
                  _buildHistoryItem(
                    'August 20, 2024',
                    '09:00 - 18:00',
                    '8.0 hrs',
                    'Present',
                    Colors.green,
                  ),
                  Divider(height: 1),
                  _buildHistoryItem(
                    'August 19, 2024',
                    '--:-- - --:--',
                    '0.0 hrs',
                    'Absent',
                    Colors.red,
                  ),
                  Divider(height: 1),
                  _buildHistoryItem(
                    'August 18, 2024',
                    '09:30 - 17:45',
                    '7.25 hrs',
                    'Present',
                    Colors.green,
>>>>>>> 3b9ce857a92dc199a5e3d88b6807ade16bfdb101
                  ),
                ],
              ),
            ),
<<<<<<< HEAD
            SizedBox(height: 20),

            // Tab Content
            AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              child: _buildTabContent(),
            ),
=======
>>>>>>> 3b9ce857a92dc199a5e3d88b6807ade16bfdb101
          ],
        ),
      ),
    );
  }

<<<<<<< HEAD


  Widget _buildCheckInMethodCard(
=======
  void _showAttendanceOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Choose Check-in Method',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 20),
            _buildAttendanceOption(
              'Facial Recognition',
              'Use camera for face detection',
              Icons.face,
              Colors.blue,
              () => _checkInWithMethod('facial'),
            ),
            _buildAttendanceOption(
              'QR Code Scan',
              'Scan office QR code',
              Icons.qr_code_scanner,
              Colors.green,
              () => _checkInWithMethod('qr'),
            ),
            _buildAttendanceOption(
              'Geo Location',
              'Check location proximity',
              Icons.location_on,
              Colors.purple,
              () => _checkInWithMethod('geo'),
            ),
            _buildAttendanceOption(
              'Manual Entry',
              'Manual check-in',
              Icons.edit,
              Colors.orange,
              () => _checkInWithMethod('manual'),
            ),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceOption(
>>>>>>> 3b9ce857a92dc199a5e3d88b6807ade16bfdb101
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
<<<<<<< HEAD
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.2),
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 30,
              ),
            ),
            SizedBox(height: 15),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              subtitle,
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
=======
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          Navigator.pop(context);
          onTap();
        },
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        tileColor: Colors.grey[50],
>>>>>>> 3b9ce857a92dc199a5e3d88b6807ade16bfdb101
      ),
    );
  }

<<<<<<< HEAD
=======
  void _checkInWithMethod(String method) {
    switch (method) {
      case 'facial':
        _showFacialRecognition();
      case 'qr':
        _showQRScanner();
      case 'geo':
        _checkInWithGeo();
      case 'manual':
        _checkInManual();
    }
  }
>>>>>>> 3b9ce857a92dc199a5e3d88b6807ade16bfdb101

  void _showFacialRecognition() {
    showDialog(
      context: context,
<<<<<<< HEAD
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.face, color: Colors.blue, size: 28),
            SizedBox(width: 10),
            Text('Facial Recognition', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          ],
        ),
        content: SizedBox(
          height: 250,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blue, width: 3),
                  color: Colors.blue.withValues(alpha: 0.1),
                ),
                child: Icon(Icons.face, size: 60, color: Colors.blue),
              ),
              SizedBox(height: 20),
              Text(
                'Position your face in the camera',
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                'Make sure your face is well-lit and centered',
                style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              LinearProgressIndicator(
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
=======
      builder: (context) => AlertDialog(
        title: Text('Facial Recognition'),
        content: SizedBox(
          height: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.face, size: 80, color: Colors.blue),
              SizedBox(height: 20),
              Text('Position your face in the camera'),
              SizedBox(height: 20),
              LinearProgressIndicator(),
>>>>>>> 3b9ce857a92dc199a5e3d88b6807ade16bfdb101
            ],
          ),
        ),
        actions: [
          TextButton(
<<<<<<< HEAD
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.outfit(color: Colors.grey[600])),
          ),
          ElevatedButton(
=======
>>>>>>> 3b9ce857a92dc199a5e3d88b6807ade16bfdb101
            onPressed: () {
              Navigator.pop(context);
              _performCheckIn('Facial Recognition');
            },
<<<<<<< HEAD
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
            child: Text('Start Recognition', style: GoogleFonts.outfit(color: Colors.white)),
=======
            child: Text('Recognize'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
>>>>>>> 3b9ce857a92dc199a5e3d88b6807ade16bfdb101
          ),
        ],
      ),
    );
  }

  void _showQRScanner() {
    showDialog(
      context: context,
<<<<<<< HEAD
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.qr_code_scanner, color: Colors.green, size: 28),
            SizedBox(width: 10),
            Text('QR Code Scanner', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          ],
        ),
        content: SizedBox(
          height: 250,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.green, width: 3),
                  color: Colors.green.withValues(alpha: 0.1),
                ),
                child: Icon(Icons.qr_code_scanner, size: 60, color: Colors.green),
              ),
              SizedBox(height: 20),
              Text(
                'Point camera at office QR code',
                style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                'Ensure the QR code is clearly visible',
                style: GoogleFonts.outfit(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              LinearProgressIndicator(
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
=======
      builder: (context) => AlertDialog(
        title: Text('QR Code Scanner'),
        content: SizedBox(
          height: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.qr_code_scanner, size: 80, color: Colors.green),
              SizedBox(height: 20),
              Text('Scanning for office QR code...'),
              SizedBox(height: 20),
              LinearProgressIndicator(),
>>>>>>> 3b9ce857a92dc199a5e3d88b6807ade16bfdb101
            ],
          ),
        ),
        actions: [
          TextButton(
<<<<<<< HEAD
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.outfit(color: Colors.grey[600])),
          ),
          ElevatedButton(
=======
>>>>>>> 3b9ce857a92dc199a5e3d88b6807ade16bfdb101
            onPressed: () {
              Navigator.pop(context);
              _performCheckIn('QR Code');
            },
<<<<<<< HEAD
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
            child: Text('Scan Complete', style: GoogleFonts.outfit(color: Colors.white)),
=======
            child: Text('Scan Complete'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
>>>>>>> 3b9ce857a92dc199a5e3d88b6807ade16bfdb101
          ),
        ],
      ),
    );
  }

<<<<<<< HEAD

  void _performCheckIn(String method) {
    // Start the work timer first
    _workTimerService.startTimer();
    
    // Get current time and determine status
    DateTime now = DateTime.now();
    String currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    String status = _determineAttendanceStatus(now);
    
    // Add to attendance history
    DataManager.addAttendanceRecord({
      'date': _formatDate(now),
      'checkIn': currentTime,
      'checkOut': '--:--',
      'hours': 0.0,
      'status': status,
      'breaks': 0,
      'overtime': 0.0,
    });
    setState(() {});
    
    // The state will be updated by _onTimerChanged listener
    // Just show the success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Checked in successfully via $method - $status'),
        backgroundColor: status == 'On Time' ? Colors.green : Colors.orange,
=======
  void _checkInWithGeo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Location Verification'),
        content: Text('Checking your location...'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Simulate location check
              Future.delayed(Duration(seconds: 1), () {
                _performCheckIn('Geo Location');
              });
            },
            child: Text('Verify'),
          ),
        ],
      ),
    );
  }

  void _checkInManual() {
    _performCheckIn('Manual Entry');
  }

  void _performCheckIn(String method) {
    setState(() {
      isCheckedIn = true;
      checkInTime = TimeOfDay.now().format(context);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Checked in successfully via $method'),
        backgroundColor: Colors.green,
>>>>>>> 3b9ce857a92dc199a5e3d88b6807ade16bfdb101
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

<<<<<<< HEAD
  String _determineAttendanceStatus(DateTime checkInTime) {
    // Define expected check-in time (9:00 AM)
    DateTime expectedTime = DateTime(checkInTime.year, checkInTime.month, checkInTime.day, 9, 0);
    
    // Check if check-in is within 15 minutes of expected time (9:00-9:15)
    Duration difference = checkInTime.difference(expectedTime);
    
    if (difference.inMinutes <= 15) {
      return 'On Time';
    } else {
      return 'Late';
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${date.day}/${months[date.month - 1]}/${date.year}';
  }

  void _checkOut() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.logout, color: Colors.red, size: 28),
              SizedBox(width: 12),
              Text(
                'Check Out?',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to check out? This will stop your work timer and end your work session.',
            style: GoogleFonts.outfit(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.outfit(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Stop the work timer first
                _workTimerService.stopTimer();
                
                // Get current time and calculate hours worked
                DateTime now = DateTime.now();
                String currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
                double hoursWorked = _workTimerService.hoursWorked;
                
                // Update the most recent attendance record with check-out info
                checkOutTime = currentTime;
                if (attendanceHistory.isNotEmpty) {
                  DataManager.updateAttendanceRecord(0, {
                    ...attendanceHistory[0],
                    'checkOut': currentTime,
                    'hours': hoursWorked,
                  });
                }
                setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
                    content: Text('Checked out successfully! Worked ${hoursWorked.toStringAsFixed(1)} hours today! 👋'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Check Out',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
=======
  void _checkOut() {
    setState(() {
      isCheckedIn = false;
      checkInTime = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Checked out successfully'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
>>>>>>> 3b9ce857a92dc199a5e3d88b6807ade16bfdb101
    );
  }

  String _calculateHours() {
    if (checkInTime == null) return '0.0';
    // Simple calculation - in real app, calculate actual hours
    return '${DateTime.now().difference(DateTime.now().subtract(Duration(hours: 2))).inHours}.0';
  }

<<<<<<< HEAD
  Widget _buildTabButton(String title, int index, IconData icon) {
    final isSelected = selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTabIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF1976D2) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
      children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[600],
              size: 24,
            ),
            SizedBox(height: 4),
        Text(
              title,
              style: GoogleFonts.outfit(
                color: isSelected ? Colors.white : Colors.grey[600],
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (selectedTabIndex) {
      case 0:
        return _buildTodayTab();
      case 1:
        return _buildHistoryTab();
      case 2:
        return _buildStatsTab();
      default:
        return _buildTodayTab();
    }
  }

  Widget _buildTodayTab() {
    return Container(
      key: ValueKey('today'),
      padding: EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Color(0xFFf8f9fa)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
=======
  Widget _buildSummaryItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildHistoryItem(
    String date,
    String time,
    String hours,
    String status,
    Color statusColor,
  ) {
    return Padding(
      padding: EdgeInsets.all(15),
      child: Row(
        children: [
          Expanded(
>>>>>>> 3b9ce857a92dc199a5e3d88b6807ade16bfdb101
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
<<<<<<< HEAD
            'Today\'s Summary',
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w600,
                    color: Colors.black87,
              letterSpacing: 0.3,
            ),
          ),
          SizedBox(height: 20),
          
          // Enhanced Summary Grid
          Row(
            children: [
              Expanded(
                child: _buildEnhancedSummaryItem(
                  'Check In',
                  checkInTime ?? '--:--',
                  Icons.login,
                  Colors.green,
                  isCheckedIn,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildEnhancedSummaryItem(
                  'Check Out',
                  checkOutTime ?? (isCheckedIn ? '--:--' : '18:00'),
                  Icons.logout,
                  Colors.red,
                  !isCheckedIn,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildEnhancedSummaryItem(
                  'Hours Worked',
                  isCheckedIn ? _calculateHours() : '8.0',
                  Icons.timer,
                  Colors.blue,
                  false,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildEnhancedSummaryItem(
                  'Break Time',
                  '${totalBreakMinutes}m',
                  Icons.coffee,
                  Colors.orange,
                  isOnBreak,
                ),
              ),
            ],
          ),
          
          // Break Progress
          if (isCheckedIn) ...[
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Work Progress',
                  style: GoogleFonts.outfit(
                          fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                        ),
                      ),
                      Text(
                        '${_getWorkProgress()}%',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: _getWorkProgress() / 100,
                    backgroundColor: Colors.blue.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    minHeight: 8,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return Container(
      key: ValueKey('history'),
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
          Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Attendance',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'View All',
                    style: GoogleFonts.outfit(
                      color: Color(0xFF1976D2),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
=======
                  date,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
>>>>>>> 3b9ce857a92dc199a5e3d88b6807ade16bfdb101
                ),
              ],
            ),
          ),
<<<<<<< HEAD
          if (attendanceHistory.isEmpty)
            Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Text(
                  'No attendance records yet',
                  style: GoogleFonts.outfit(
                    color: Colors.grey[600],
                    fontSize: 16,
                  ),
                ),
              ),
            )
          else
            ...attendanceHistory.map((record) => _buildEnhancedHistoryItem(record)),
=======
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                hours,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Task Management Screen
class TaskScreen extends StatefulWidget {
  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  List<Task> tasks = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeTasks();
  }

  void _initializeTasks() {
    try {
      if (MockData.tasks.isNotEmpty) {
        setState(() {
          tasks = List.from(MockData.tasks);
        });
      }
    } catch (e) {
      // If there's any error, use empty list
      setState(() {
        tasks = [];
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
                  'Task Management',
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
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black87,
          unselectedLabelColor: Colors.black54,
          indicatorColor: Colors.black87,
          tabs: [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'In Progress'),
            Tab(text: 'Completed'),
          ],
        ),
        actions: [
          IconButton(icon: Icon(Icons.add), onPressed: _showCreateTaskDialog),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTaskList(tasks),
          _buildTaskList(tasks.where((t) => t.status == 'Pending').toList()),
          _buildTaskList(
            tasks.where((t) => t.status == 'In Progress').toList(),
          ),
          _buildTaskList(tasks.where((t) => t.status == 'Completed').toList()),
        ],
      ),
      floatingActionButton: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        child: FloatingActionButton(
          onPressed: _showCreateTaskDialog,
          backgroundColor: Colors.transparent,
          elevation: 12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(Icons.add, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskList(List<Task> taskList) {
    if (taskList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task, size: 80, color: Colors.grey[400]),
            SizedBox(height: 20),
            Text(
              'No tasks found',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
>>>>>>> 3b9ce857a92dc199a5e3d88b6807ade16bfdb101
          ],
        ),
      );
    }

<<<<<<< HEAD
  Widget _buildStatsTab() {
    return Container(
      key: ValueKey('stats'),
      padding: EdgeInsets.all(25),
=======
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: taskList.length,
      itemBuilder: (context, index) {
        return _buildTaskCard(taskList[index]);
      },
    );
  }

  Widget _buildTaskCard(Task task) {
    Color priorityColor = _getPriorityColor(task.priority);
    Color statusColor = _getStatusColor(task.status);

    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.only(bottom: 20),
>>>>>>> 3b9ce857a92dc199a5e3d88b6807ade16bfdb101
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Color(0xFFf8f9fa)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
<<<<<<< HEAD
=======
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1), width: 1),
>>>>>>> 3b9ce857a92dc199a5e3d88b6807ade16bfdb101
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
<<<<<<< HEAD
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Text(
            'Weekly Statistics',
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              letterSpacing: 0.3,
            ),
          ),
          SizedBox(height: 20),
          
          // Stats Grid
            Row(
              children: [
                Expanded(
                child: _buildStatCard(
                  'Days Present',
                  '5',
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Total Hours',
                  '40.5',
                  Icons.timer,
                  Colors.blue,
                ),
              ),
            ],
=======
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) => _handleTaskAction(task, value),
                  itemBuilder: (context) => [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                    PopupMenuItem(
                      value: 'status',
                      child: Text('Change Status'),
                    ),
                  ],
                  child: Icon(Icons.more_vert, color: Colors.grey[600]),
                ),
              ],
            ),
            SizedBox(height: 8),
            if (task.description != null)
              Text(
                task.description!,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
>>>>>>> 3b9ce857a92dc199a5e3d88b6807ade16bfdb101
              ),
            SizedBox(height: 12),
            Row(
              children: [
<<<<<<< HEAD
              Expanded(
                child: _buildStatCard(
                  'Overtime',
                  '2.5h',
                  Icons.schedule,
                  Colors.orange,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Attendance %',
                  '95%',
                  Icons.trending_up,
                  Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedSummaryItem(
    String title,
    String value,
    IconData icon,
    Color color,
    bool isActive,
  ) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isActive ? color.withValues(alpha: 0.1) : Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? color.withValues(alpha: 0.3) : Colors.grey.withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      child: Column(
              children: [
          Icon(
            icon,
            color: isActive ? color : Colors.grey[600],
            size: 28,
          ),
        SizedBox(height: 8),
                Text(
          value,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isActive ? color : Colors.black87,
            ),
          ),
          SizedBox(height: 4),
                Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedHistoryItem(Map<String, dynamic> record) {
    final status = record['status'] as String;
    Color statusColor;
    switch (status) {
      case 'On Time':
        statusColor = Colors.green;
        break;
      case 'Late':
        statusColor = Colors.orange;
        break;
      case 'Absent':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }
    
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Status Indicator
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 16),
          
          // Date
          Expanded(
            flex: 2,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Text(
                  record['date'],
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '${record['checkIn']} - ${record['checkOut']}',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    color: Colors.grey[600],
=======
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: priorityColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    task.priority,
                    style: TextStyle(
                      color: priorityColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    task.status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
>>>>>>> 3b9ce857a92dc199a5e3d88b6807ade16bfdb101
                  ),
                ),
              ],
            ),
<<<<<<< HEAD
          ),
          
          // Hours and Status
          Expanded(
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                  '${record['hours']}h',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
                Text(
                  record['status'],
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
=======
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                SizedBox(width: 4),
                Text(
                  'Due: ${task.deadline}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                Spacer(),
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                SizedBox(width: 4),
                Text(
                  '${task.estimatedHours}h',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleTaskAction(Task task, String action) {
    switch (action) {
      case 'edit':
        _showEditTaskDialog(task);
      case 'delete':
        _showDeleteTaskDialog(task);
      case 'status':
        _showStatusChangeDialog(task);
    }
  }

  void _showCreateTaskDialog() {
    String title = '';
    String description = '';
    String priority = 'Medium';
    String deadline = '';
    int estimatedHours = 1;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Create New Task'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: 'Task Title',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => title = value,
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onChanged: (value) => description = value,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: priority,
                decoration: InputDecoration(
                  labelText: 'Priority',
                  border: OutlineInputBorder(),
                ),
                items: ['High', 'Medium', 'Low'].map((p) {
                  return DropdownMenuItem(value: p, child: Text(p));
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    priority = value;
                  }
                },
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Deadline (YYYY-MM-DD)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => deadline = value,
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Estimated Hours',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) => estimatedHours = int.tryParse(value) ?? 1,
>>>>>>> 3b9ce857a92dc199a5e3d88b6807ade16bfdb101
              ),
            ],
          ),
        ),
<<<<<<< HEAD
          
          // Overtime indicator
          if (record['overtime'] > 0) ...[
            SizedBox(width: 8),
              Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                '+${record['overtime']}h',
                style: GoogleFonts.outfit(
                    fontSize: 10,
                  color: Colors.orange,
                  fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  int _getWorkProgress() {
    if (!isCheckedIn) return 0;
    // Simple progress calculation - in real app, calculate based on actual work hours
    return 75; // 75% of work day completed
  }

  void _startBreak() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.coffee, color: Colors.orange, size: 28),
              SizedBox(width: 12),
              Text(
                'Start Break?',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to start your break? The work timer will pause and break timer will start.',
            style: GoogleFonts.outfit(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.outfit(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
          ),
          ElevatedButton(
            onPressed: () {
                Navigator.of(context).pop();
                _workTimerService.startBreak();
                // Break status will be updated by _onTimerChanged listener
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Break started! Enjoy your break â˜•'),
                    backgroundColor: Colors.orange,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Start Break',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _endBreak() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
              children: [
              Icon(Icons.work, color: Colors.green, size: 28),
              SizedBox(width: 12),
              Text(
                'End Break?',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to end your break? The work timer will resume.',
            style: GoogleFonts.outfit(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: GoogleFonts.outfit(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _workTimerService.endBreak();
                setState(() {
                  totalBreakMinutes += 15; // Add 15 minutes for this break
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Break ended! Back to work ðŸ’ª'),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'End Break',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w600,
                ),
              ),
=======
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (title.isNotEmpty && deadline.isNotEmpty) {
                Task newTask = Task(
                  id: 'TASK${(tasks.length + 1).toString().padLeft(3, '0')}',
                  title: title,
                  assignedTo: 'EMP001',
                  assignedBy: 'ADMIN',
                  deadline: deadline,
                  status: 'Pending',
                  priority: priority,
                  estimatedHours: estimatedHours,
                  description: description.isEmpty ? null : description,
                );

                setState(() {
                  tasks.add(newTask);
                });

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Task created successfully')),
                );
              }
            },
            child: Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showEditTaskDialog(Task task) {
    // Similar to create task dialog but with pre-filled values
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Edit task feature coming soon')));
  }

  void _showDeleteTaskDialog(Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                tasks.removeWhere((t) => t.id == task.id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Task deleted successfully')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showStatusChangeDialog(Task task) {
    String newStatus = task.status;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change Task Status'),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: newStatus == 'Pending'
                            ? Color(0xFF1976D2)
                            : Colors.grey,
                        width: 2,
                      ),
                      color: newStatus == 'Pending'
                          ? Color(0xFF1976D2)
                          : Colors.transparent,
                    ),
                    child: newStatus == 'Pending'
                        ? Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                  title: Text('Pending'),
                  onTap: () {
                    setDialogState(() {
                      newStatus = 'Pending';
                    });
                  },
                ),
                ListTile(
                  leading: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: newStatus == 'In Progress'
                            ? Color(0xFF1976D2)
                            : Colors.grey,
                        width: 2,
                      ),
                      color: newStatus == 'In Progress'
                          ? Color(0xFF1976D2)
                          : Colors.transparent,
                    ),
                    child: newStatus == 'In Progress'
                        ? Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                  title: Text('In Progress'),
                  onTap: () {
                    setDialogState(() {
                      newStatus = 'In Progress';
                    });
                  },
                ),
                ListTile(
                  leading: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: newStatus == 'Completed'
                            ? Color(0xFF1976D2)
                            : Colors.grey,
                        width: 2,
                      ),
                      color: newStatus == 'Completed'
                          ? Color(0xFF1976D2)
                          : Colors.transparent,
                    ),
                    child: newStatus == 'Completed'
                        ? Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                  title: Text('Completed'),
                  onTap: () {
                    setDialogState(() {
                      newStatus = 'Completed';
                    });
                  },
>>>>>>> 3b9ce857a92dc199a5e3d88b6807ade16bfdb101
                ),
              ],
            );
          },
<<<<<<< HEAD
    );
  }

=======
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                tasks = tasks.map((t) {
                  if (t.id == task.id) {
                    return Task(
                      id: t.id,
                      title: t.title,
                      assignedTo: t.assignedTo,
                      assignedBy: t.assignedBy,
                      deadline: t.deadline,
                      status: newStatus,
                      priority: t.priority,
                      estimatedHours: t.estimatedHours,
                      description: t.description,
                    );
                  }
                  return t;
                }).toList();
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Task status updated')));
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return Colors.green;
      case 'In Progress':
        return Colors.blue;
      case 'Pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
>>>>>>> 3b9ce857a92dc199a5e3d88b6807ade16bfdb101
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
<<<<<<< HEAD
  
  // Form state variables
  String? selectedLeaveType;
  DateTime? fromDate;
  DateTime? toDate;
  TextEditingController reasonController = TextEditingController();
  TextEditingController fromDateController = TextEditingController();
  TextEditingController toDateController = TextEditingController();
=======
>>>>>>> 3b9ce857a92dc199a5e3d88b6807ade16bfdb101

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeLeaveRequests();
  }

<<<<<<< HEAD
  @override
  void dispose() {
    _tabController.dispose();
    reasonController.dispose();
    fromDateController.dispose();
    toDateController.dispose();
    super.dispose();
  }

  void _initializeLeaveRequests() {
    setState(() {
      leaveRequests = List.from(DataManager.leaveRequests);
    });
=======
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
>>>>>>> 3b9ce857a92dc199a5e3d88b6807ade16bfdb101
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
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black87,
          unselectedLabelColor: Colors.black54,
          indicatorColor: Colors.black87,
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
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 400),
            width: double.infinity,
            padding: EdgeInsets.all(25),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Color(0xFFf8f9fa)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: Colors.grey.withValues(alpha: 0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Apply for Leave',
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    letterSpacing: 0.3,
                  ),
                ),
                SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Leave Type',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
<<<<<<< HEAD
                  value: selectedLeaveType,
                  items: [
=======
                  items:
                      [
>>>>>>> 3b9ce857a92dc199a5e3d88b6807ade16bfdb101
                        'Sick Leave',
                        'Casual Leave',
                        'Annual Leave',
                        'Emergency Leave',
                        'Maternity Leave',
                      ].map((type) {
                        return DropdownMenuItem(value: type, child: Text(type));
                      }).toList(),
<<<<<<< HEAD
                  onChanged: (value) {
                    setState(() {
                      selectedLeaveType = value;
                    });
                  },
                ),
                SizedBox(height: 16),
                TextField(
                  controller: fromDateController,
=======
                  onChanged: (value) {},
                ),
                SizedBox(height: 16),
                TextField(
>>>>>>> 3b9ce857a92dc199a5e3d88b6807ade16bfdb101
                  decoration: InputDecoration(
                    labelText: 'From Date',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
<<<<<<< HEAD
                  onTap: () => _selectFromDate(context),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: toDateController,
=======
                  onTap: () => _selectDate(context),
                ),
                SizedBox(height: 16),
                TextField(
>>>>>>> 3b9ce857a92dc199a5e3d88b6807ade16bfdb101
                  decoration: InputDecoration(
                    labelText: 'To Date',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
<<<<<<< HEAD
                  onTap: () => _selectToDate(context),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: reasonController,
=======
                  onTap: () => _selectDate(context),
                ),
                SizedBox(height: 16),
                TextField(
>>>>>>> 3b9ce857a92dc199a5e3d88b6807ade16bfdb101
                  decoration: InputDecoration(
                    labelText: 'Reason',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  maxLines: 4,
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _submitLeaveRequest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF1976D2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Submit Request',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyRequestsTab() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: leaveRequests.length,
      itemBuilder: (context, index) {
        return _buildLeaveRequestCard(leaveRequests[index]);
      },
    );
  }

  Widget _buildBalanceTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              children: [
                Text(
                  'Leave Balance 2024',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildBalanceItem('Total', '24', Colors.white),
                    _buildBalanceItem('Used', '8', Colors.white70),
                    _buildBalanceItem('Remaining', '16', Colors.white),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
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
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Leave Type Breakdown',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                _buildLeaveTypeBalance('Annual Leave', 12, 4, Colors.blue),
                _buildLeaveTypeBalance('Sick Leave', 8, 2, Colors.red),
                _buildLeaveTypeBalance('Casual Leave', 4, 2, Colors.orange),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveRequestCard(LeaveRequest request) {
    Color statusColor = _getLeaveStatusColor(request.status);

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    request.type,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    request.status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              'From: ${request.startDate}',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            Text(
              'To: ${request.endDate}',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            SizedBox(height: 8),
            Text(
              request.reason,
              style: TextStyle(color: Colors.grey[800], fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceItem(String title, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(title, style: TextStyle(color: color, fontSize: 14)),
      ],
    );
  }

  Widget _buildLeaveTypeBalance(String type, int total, int used, Color color) {
    double percentage = used / total;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                type,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
              Text(
                '$used/$total used',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
          SizedBox(height: 8),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: color.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }

  Color _getLeaveStatusColor(String status) {
    switch (status) {
      case 'Approved':
        return Colors.green;
      case 'Pending':
        return Colors.orange;
      case 'Rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

<<<<<<< HEAD
  void _selectFromDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fromDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null && picked != fromDate) {
      setState(() {
        fromDate = picked;
        fromDateController.text = '${picked.day}/${picked.month}/${picked.year}';
        // If to date is before from date, clear it
        if (toDate != null && toDate!.isBefore(fromDate!)) {
          toDate = null;
          toDateController.clear();
        }
      });
    }
  }

  void _selectToDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: toDate ?? (fromDate ?? DateTime.now()),
      firstDate: fromDate ?? DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null && picked != toDate) {
      setState(() {
        toDate = picked;
        toDateController.text = '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  void _submitLeaveRequest() {
    // Validate form
    if (selectedLeaveType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a leave type'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (fromDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a from date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (toDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a to date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    if (reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a reason'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Create leave request
    final leaveRequest = LeaveRequest(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      empId: 'EMP001',
      type: selectedLeaveType!,
      startDate: '${fromDate!.day}/${fromDate!.month}/${fromDate!.year}',
      endDate: '${toDate!.day}/${toDate!.month}/${toDate!.year}',
      reason: reasonController.text.trim(),
      status: 'Pending',
    );
    
    // Add to list
    DataManager.addLeaveRequest(leaveRequest);
    setState(() {
      leaveRequests.add(leaveRequest);
    });
    
    // Clear form
    setState(() {
      selectedLeaveType = null;
      fromDate = null;
      toDate = null;
      reasonController.clear();
      fromDateController.clear();
      toDateController.clear();
    });
    
=======
  void _selectDate(BuildContext context) async {
    await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    // Handle date selection
  }

  void _submitLeaveRequest() {
>>>>>>> 3b9ce857a92dc199a5e3d88b6807ade16bfdb101
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Leave request submitted successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

// Profile Screen
class ProfileScreen extends StatelessWidget {
  Employee get currentUser {
<<<<<<< HEAD
    return DataManager.currentUser ?? Employee(
      empId: 'EMP001',
      name: 'Current User',
      role: 'Employee',
      department: 'Development',
      shift: 'Morning',
      status: 'Active',
      hourlyRate: 200,
      location: Location(lat: 11.1085, lng: 77.3411),
    );
=======
    try {
      if (MockData.employees.isNotEmpty) {
        return MockData.employees.first;
      } else {
        // Fallback employee if list is empty
        return Employee(
          empId: 'EMP001',
          name: 'Sudhi Kumaran',
          role: 'Frontend & Backend Developer',
          department: 'Development',
          shift: 'Morning',
          status: 'Active',
          hourlyRate: 200,
          location: Location(lat: 11.1085, lng: 77.3411),
        );
      }
    } catch (e) {
      // If there's any error, return a fallback employee
      return Employee(
        empId: 'EMP001',
        name: 'Sudhi Kumaran',
        role: 'Frontend & Backend Developer',
        department: 'Development',
        shift: 'Morning',
        status: 'Active',
        hourlyRate: 200,
        location: Location(lat: 11.1085, lng: 77.3411),
      );
    }
>>>>>>> 3b9ce857a92dc199a5e3d88b6807ade16bfdb101
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Color(0xFF1976D2),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [IconButton(icon: Icon(Icons.edit), onPressed: () {})],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Text(
                      currentUser.name.substring(0, 2),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1976D2),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    currentUser.name,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    currentUser.role,
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      currentUser.empId,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Profile Information
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildInfoSection('Personal Information', [
                    _buildInfoItem(
                      'Department',
                      currentUser.department,
                      Icons.business,
                    ),
                    _buildInfoItem('Shift', currentUser.shift, Icons.schedule),
                    _buildInfoItem(
                      'Status',
                      currentUser.status,
                      Icons.verified_user,
                    ),
                    _buildInfoItem(
                      'Hourly Rate',
<<<<<<< HEAD
                      'â‚¹${currentUser.hourlyRate}',
=======
                      '₹${currentUser.hourlyRate}',
>>>>>>> 3b9ce857a92dc199a5e3d88b6807ade16bfdb101
                      Icons.attach_money,
                    ),
                  ]),
                  SizedBox(height: 20),
                  _buildInfoSection('Work Statistics', [
                    _buildInfoItem(
                      'Total Hours This Month',
                      '160 hrs',
                      Icons.timer,
                    ),
                    _buildInfoItem(
                      'Average Daily Hours',
                      '8.0 hrs',
                      Icons.schedule,
                    ),
                    _buildInfoItem('Tasks Completed', '15', Icons.task_alt),
                    _buildInfoItem('Attendance Rate', '95%', Icons.trending_up),
                  ]),
                  SizedBox(height: 20),
                  _buildInfoSection('Settings', [
                    _buildActionItem('Change Password', Icons.lock, () {}),
                    _buildActionItem(
                      'Notification Settings',
                      Icons.notifications,
                      () {},
                    ),
                    _buildActionItem(
                      'Privacy Settings',
                      Icons.privacy_tip,
                      () {},
                    ),
                    _buildActionItem('Help & Support', Icons.help, () {}),
                    _buildActionItem(
                      'Logout',
                      Icons.logout,
                      () => _showLogoutDialog(context),
                    ),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
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
          Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.black87,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: Colors.grey[600]),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
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
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// Additional utility classes and extensions
extension ColorExtension on Color {
  Color get withOpacity05 => withValues(alpha: 0.05);
}

// Custom widgets for common UI patterns
class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? borderRadius;

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius ?? 12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const StatusChip({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
