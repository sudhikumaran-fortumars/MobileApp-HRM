import 'package:flutter/material.dart';
import 'dart:async';

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
  final DateTime appliedDate;

  LeaveRequest({
    required this.id,
    required this.empId,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.status,
    required this.appliedDate,
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
  static Employee? _currentEmployee;
  static Timer? _updateTimer;
  static List<VoidCallback> _listeners = [];
  
  static bool get isCheckedIn => _isCheckedIn;
  static String? get checkInTime => _checkInTime;
  static String? get checkInMethod => _checkInMethod;
  static Employee? get currentEmployee => _currentEmployee;
  
  static void setCheckInStatus(bool isCheckedIn, String? checkInTime, String? method) {
    _isCheckedIn = isCheckedIn;
    _checkInTime = checkInTime;
    _checkInMethod = method;
    _notifyListeners();
  }
  
  static set isCheckedIn(bool value) {
    _isCheckedIn = value;
    _notifyListeners();
  }
  
  static set checkInTime(String? value) {
    _checkInTime = value;
    _notifyListeners();
  }
  
  static set checkInMethod(String? value) {
    _checkInMethod = value;
    _notifyListeners();
  }
  
  static set currentEmployee(Employee? value) {
    _currentEmployee = value;
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

