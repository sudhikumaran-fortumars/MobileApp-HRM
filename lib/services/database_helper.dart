import 'dart:async';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
<<<<<<< HEAD
import '../models.dart';
=======
import '../main.dart';
>>>>>>> a742dec7e33608d0613a6ff532b1ca2f9228ab93

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Initialize database factory for web
    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    } else {
      databaseFactory = databaseFactoryFfi;
    }
    
    String path = join(await getDatabasesPath(), 'hrm_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Employees table
    await db.execute('''
      CREATE TABLE employees(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        employeeId TEXT UNIQUE NOT NULL,
        name TEXT NOT NULL,
        email TEXT,
        phone TEXT,
        department TEXT,
        position TEXT,
        profilePictureUrl TEXT,
        username TEXT UNIQUE,
        password TEXT,
        isActive INTEGER DEFAULT 1,
        createdAt TEXT,
        updatedAt TEXT,
        lastSyncAt TEXT
      )
    ''');

    // Attendance records table
    await db.execute('''
      CREATE TABLE attendance_records(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        employeeId TEXT NOT NULL,
        checkInTime TEXT,
        checkOutTime TEXT,
        checkInMethod TEXT,
        checkOutMethod TEXT,
        checkInLocation TEXT,
        checkOutLocation TEXT,
        checkInPhoto TEXT,
        checkOutPhoto TEXT,
        workHours REAL,
        breakTimeMinutes INTEGER DEFAULT 0,
        date TEXT NOT NULL,
        isSynced INTEGER DEFAULT 0,
        createdAt TEXT,
        updatedAt TEXT,
        FOREIGN KEY (employeeId) REFERENCES employees (employeeId)
      )
    ''');

    // Leave requests table
    await db.execute('''
      CREATE TABLE leave_requests(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        employeeId TEXT NOT NULL,
        leaveType TEXT NOT NULL,
        startDate TEXT NOT NULL,
        endDate TEXT NOT NULL,
        reason TEXT,
        status TEXT DEFAULT 'pending',
        appliedDate TEXT,
        approvedBy TEXT,
        approvedDate TEXT,
        isSynced INTEGER DEFAULT 0,
        createdAt TEXT,
        updatedAt TEXT,
        FOREIGN KEY (employeeId) REFERENCES employees (employeeId)
      )
    ''');

    // Break time records table
    await db.execute('''
      CREATE TABLE break_records(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        employeeId TEXT NOT NULL,
        attendanceId INTEGER,
        breakStartTime TEXT,
        breakEndTime TEXT,
        breakDuration INTEGER,
        breakType TEXT DEFAULT 'regular',
        isActive INTEGER DEFAULT 0,
        isSynced INTEGER DEFAULT 0,
        createdAt TEXT,
        updatedAt TEXT,
        FOREIGN KEY (employeeId) REFERENCES employees (employeeId),
        FOREIGN KEY (attendanceId) REFERENCES attendance_records (id)
      )
    ''');

    // Sync status table
    await db.execute('''
      CREATE TABLE sync_status(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tableName TEXT UNIQUE NOT NULL,
        lastSyncAt TEXT,
        isPending INTEGER DEFAULT 0
      )
    ''');
  }

  // ==================== EMPLOYEE OPERATIONS ====================

  Future<int> insertEmployee(Employee employee) async {
    final db = await database;
    return await db.insert('employees', _employeeToMap(employee));
  }

  Future<List<Employee>> getAllEmployees() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('employees');
    return List.generate(maps.length, (i) => _mapToEmployee(maps[i]));
  }

  Future<Employee?> getEmployeeById(String employeeId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'employees',
      where: 'employeeId = ?',
      whereArgs: [employeeId],
    );
    if (maps.isNotEmpty) {
      return _mapToEmployee(maps.first);
    }
    return null;
  }

  Future<Employee?> getEmployeeByUsername(String username) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'employees',
      where: 'username = ?',
      whereArgs: [username],
    );
    if (maps.isNotEmpty) {
      return _mapToEmployee(maps.first);
    }
    return null;
  }

  Future<int> updateEmployee(Employee employee) async {
    final db = await database;
    return await db.update(
      'employees',
      _employeeToMap(employee),
      where: 'employeeId = ?',
      whereArgs: [employee.empId],
    );
  }

  Future<int> deleteEmployee(String employeeId) async {
    final db = await database;
    return await db.delete(
      'employees',
      where: 'employeeId = ?',
      whereArgs: [employeeId],
    );
  }

  // ==================== ATTENDANCE OPERATIONS ====================

  Future<int> insertAttendanceRecord(AttendanceRecord record) async {
    final db = await database;
    return await db.insert('attendance_records', _attendanceToMap(record));
  }

  Future<List<AttendanceRecord>> getAttendanceRecords(String employeeId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'attendance_records',
      where: 'employeeId = ?',
      whereArgs: [employeeId],
      orderBy: 'date DESC',
    );
    return List.generate(maps.length, (i) => _mapToAttendance(maps[i]));
  }

  Future<AttendanceRecord?> getTodayAttendance(String employeeId) async {
    final db = await database;
    final today = DateTime.now().toIso8601String().split('T')[0];
    final List<Map<String, dynamic>> maps = await db.query(
      'attendance_records',
      where: 'employeeId = ? AND date = ?',
      whereArgs: [employeeId, today],
    );
    if (maps.isNotEmpty) {
      return _mapToAttendance(maps.first);
    }
    return null;
  }

  Future<int> updateAttendanceRecord(AttendanceRecord record) async {
    final db = await database;
    return await db.update(
      'attendance_records',
      _attendanceToMap(record),
      where: 'date = ?',
      whereArgs: [record.date],
    );
  }

  // ==================== LEAVE REQUEST OPERATIONS ====================

  Future<int> insertLeaveRequest(LeaveRequest request) async {
    final db = await database;
    return await db.insert('leave_requests', _leaveRequestToMap(request));
  }

  Future<List<LeaveRequest>> getLeaveRequests(String employeeId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'leave_requests',
      where: 'employeeId = ?',
      whereArgs: [employeeId],
      orderBy: 'appliedDate DESC',
    );
    return List.generate(maps.length, (i) => _mapToLeaveRequest(maps[i]));
  }

  Future<int> updateLeaveRequest(LeaveRequest request) async {
    final db = await database;
    return await db.update(
      'leave_requests',
      _leaveRequestToMap(request),
      where: 'id = ?',
      whereArgs: [request.id],
    );
  }

  // ==================== BREAK RECORD OPERATIONS ====================

  Future<int> insertBreakRecord(BreakRecord record) async {
    final db = await database;
    return await db.insert('break_records', _breakRecordToMap(record));
  }

  Future<List<BreakRecord>> getBreakRecords(String employeeId, int? attendanceId) async {
    final db = await database;
    String whereClause = 'employeeId = ?';
    List<dynamic> whereArgs = [employeeId];
    
    if (attendanceId != null) {
      whereClause += ' AND attendanceId = ?';
      whereArgs.add(attendanceId);
    }
    
    final List<Map<String, dynamic>> maps = await db.query(
      'break_records',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'createdAt DESC',
    );
    return List.generate(maps.length, (i) => _mapToBreakRecord(maps[i]));
  }

  Future<int> updateBreakRecord(BreakRecord record) async {
    final db = await database;
    return await db.update(
      'break_records',
      _breakRecordToMap(record),
      where: 'id = ?',
      whereArgs: [record.id],
    );
  }

  // ==================== SYNC OPERATIONS ====================

  Future<List<Map<String, dynamic>>> getUnsyncedRecords(String tableName) async {
    final db = await database;
    return await db.query(
      tableName,
      where: 'isSynced = ?',
      whereArgs: [0],
    );
  }

  Future<void> markAsSynced(String tableName, int recordId) async {
    final db = await database;
    await db.update(
      tableName,
      {'isSynced': 1, 'updatedAt': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [recordId],
    );
  }

  Future<void> updateSyncStatus(String tableName, DateTime lastSyncAt) async {
    final db = await database;
    await db.insert(
      'sync_status',
      {
        'tableName': tableName,
        'lastSyncAt': lastSyncAt.toIso8601String(),
        'isPending': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // ==================== DATA CONVERSION METHODS ====================

  Map<String, dynamic> _employeeToMap(Employee employee) {
    return {
      'employeeId': employee.empId,
      'name': employee.name,
      'email': employee.email,
      'phone': employee.phone,
      'department': employee.department,
      'role': employee.role,
      'profilePictureUrl': employee.profileImagePath,
      'username': '', // Will be set separately
      'password': '', // Will be set separately
      'isActive': employee.status == 'Active' ? 1 : 0,
      'createdAt': employee.joinDate.toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'lastSyncAt': DateTime.now().toIso8601String(),
    };
  }

  Employee _mapToEmployee(Map<String, dynamic> map) {
    return Employee(
      empId: map['employeeId'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? '',
      department: map['department'] ?? '',
      shift: 'Morning', // Default value
      status: map['isActive'] == 1 ? 'Active' : 'Inactive',
      hourlyRate: 200.0, // Default value
      location: Location(lat: 0.0, lng: 0.0), // Default location
      hasRegisteredFace: false,
      faceData: null,
      faceImagePath: null,
      profileImagePath: map['profilePictureUrl'],
      faceRegistrationDate: null,
      joinDate: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
      address: '', // Default value
      emergencyContact: '', // Default value
      emergencyPhone: '', // Default value
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

  Map<String, dynamic> _attendanceToMap(AttendanceRecord record) {
    return {
      'id': 0, // Auto-generated
      'employeeId': '', // Will be set when saving
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
      'isSynced': 0,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  AttendanceRecord _mapToAttendance(Map<String, dynamic> map) {
    return AttendanceRecord(
      date: map['date'] ?? '',
      checkIn: map['checkInTime'],
      checkOut: map['checkOutTime'],
      status: map['checkOutTime'] != null ? 'Completed' : 'In Progress',
      hours: map['workHours']?.toDouble() ?? 0.0,
      location: map['checkInLocation'] ?? '',
      method: map['checkInMethod'] ?? '',
    );
  }

  Map<String, dynamic> _leaveRequestToMap(LeaveRequest request) {
    return {
      'id': int.tryParse(request.id) ?? 0,
      'employeeId': request.empId,
      'leaveType': request.type,
      'startDate': request.startDate,
      'endDate': request.endDate,
      'reason': request.reason,
      'status': request.status,
      'appliedDate': request.appliedDate.toIso8601String(),
      'approvedBy': null,
      'approvedDate': null,
      'isSynced': 0,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  LeaveRequest _mapToLeaveRequest(Map<String, dynamic> map) {
    return LeaveRequest(
      id: map['id'].toString(),
      empId: map['employeeId'] ?? '',
      type: map['leaveType'] ?? '',
      startDate: map['startDate'] ?? '',
      endDate: map['endDate'] ?? '',
      reason: map['reason'] ?? '',
      status: map['status'] ?? 'pending',
      appliedDate: map['appliedDate'] != null ? DateTime.parse(map['appliedDate']) : DateTime.now(),
    );
  }

  Map<String, dynamic> _breakRecordToMap(BreakRecord record) {
    return {
      'id': 0, // Auto-generated
      'employeeId': record.employeeId,
      'attendanceId': record.attendanceId,
      'breakStartTime': record.breakStartTime?.toIso8601String(),
      'breakEndTime': record.breakEndTime?.toIso8601String(),
      'breakDuration': record.breakDuration,
      'breakType': record.breakType,
      'isActive': record.isActive ? 1 : 0,
      'isSynced': record.isSynced ? 1 : 0,
      'createdAt': record.createdAt?.toIso8601String(),
      'updatedAt': record.updatedAt?.toIso8601String(),
    };
  }

  BreakRecord _mapToBreakRecord(Map<String, dynamic> map) {
    return BreakRecord(
      id: map['id'],
      employeeId: map['employeeId'],
      attendanceId: map['attendanceId'],
      breakStartTime: map['breakStartTime'] != null ? DateTime.parse(map['breakStartTime']) : null,
      breakEndTime: map['breakEndTime'] != null ? DateTime.parse(map['breakEndTime']) : null,
      breakDuration: map['breakDuration'] ?? 0,
      breakType: map['breakType'] ?? 'regular',
      isActive: map['isActive'] == 1,
      isSynced: map['isSynced'] == 1,
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }

  // ==================== UTILITY METHODS ====================

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('break_records');
    await db.delete('leave_requests');
    await db.delete('attendance_records');
    await db.delete('employees');
    await db.delete('sync_status');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}

// Break Record model
class BreakRecord {
  final int? id;
  final String employeeId;
  final int? attendanceId;
  final DateTime? breakStartTime;
  final DateTime? breakEndTime;
  final int breakDuration; // in minutes
  final String breakType; // 'regular', 'lunch', 'coffee'
  final bool isActive;
  final bool isSynced;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BreakRecord({
    this.id,
    required this.employeeId,
    this.attendanceId,
    this.breakStartTime,
    this.breakEndTime,
    this.breakDuration = 0,
    this.breakType = 'regular',
    this.isActive = false,
    this.isSynced = false,
    this.createdAt,
    this.updatedAt,
  });

  BreakRecord copyWith({
    int? id,
    String? employeeId,
    int? attendanceId,
    DateTime? breakStartTime,
    DateTime? breakEndTime,
    int? breakDuration,
    String? breakType,
    bool? isActive,
    bool? isSynced,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BreakRecord(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      attendanceId: attendanceId ?? this.attendanceId,
      breakStartTime: breakStartTime ?? this.breakStartTime,
      breakEndTime: breakEndTime ?? this.breakEndTime,
      breakDuration: breakDuration ?? this.breakDuration,
      breakType: breakType ?? this.breakType,
      isActive: isActive ?? this.isActive,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
