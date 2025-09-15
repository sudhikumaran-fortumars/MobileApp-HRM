import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;

class BreakTimeService {
  static final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();
  
  static Timer? _breakTimer;
  static Timer? _breakEndWarningTimer;
  static DateTime? _breakStartTime;
  static Duration _breakDuration = Duration.zero;
  static bool _isOnBreak = false;
  static String? _currentBreakType;
  static List<Map<String, dynamic>> _breakTimes = []; // Track all break times for the day
  
  // Break time configurations
  static const Duration morningBreakDuration = Duration(minutes: 20); // 11:40-12:00
  static const Duration lunchBreakDuration = Duration(minutes: 40); // 2:20-3:00
  static const Duration breakEndWarningTime = Duration(minutes: 5); // Warning 5 minutes before break ends
  
  // Break time slots (9 AM to 6 PM shift)
  static const int morningBreakStartHour = 11;
  static const int morningBreakStartMinute = 40;
  static const int lunchBreakStartHour = 14; // 2 PM
  static const int lunchBreakStartMinute = 20;
  
  static bool get isOnBreak => _isOnBreak;
  static Duration get breakDuration => _breakDuration;
  static String? get currentBreakType => _currentBreakType;
  static DateTime? get breakStartTime => _breakStartTime;
  
  static Future<void> initialize() async {
    // Initialize timezone
    tz.initializeTimeZones();
    
    // Initialize notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
    
    // Request notification permissions
    await _requestPermissions();
  }
  
  static Future<void> _requestPermissions() async {
    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }
  
  static void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    print('Notification tapped: ${response.payload}');
  }
  
  // Check if it's time for a break based on check-in time
  static bool shouldShowBreakNotification(DateTime checkInTime) {
    final now = DateTime.now();
    final timeSinceCheckIn = now.difference(checkInTime);
    final totalMinutesSinceCheckIn = timeSinceCheckIn.inMinutes;
    
    // Check if we've already taken the morning break today
    final today = now.toIso8601String().split('T')[0];
    final todayBreaks = _breakTimes.where((breakTime) => 
        breakTime['date'] == today && breakTime['type'] == 'morning').toList();
    final hasTakenMorningBreak = todayBreaks.isNotEmpty;
    
    // Check if we've already taken the lunch break today
    final lunchBreaks = _breakTimes.where((breakTime) => 
        breakTime['date'] == today && breakTime['type'] == 'lunch').toList();
    final hasTakenLunchBreak = lunchBreaks.isNotEmpty;
    
    // Morning break: 2 hours 40 minutes after check-in (11:40 AM)
    if (totalMinutesSinceCheckIn >= 160 && 
        totalMinutesSinceCheckIn < 200 && 
        !_isOnBreak &&
        !hasTakenMorningBreak) {
      return true;
    }
    
    // Lunch break: 5 hours 20 minutes after check-in (2:20 PM)
    if (totalMinutesSinceCheckIn >= 320 && 
        totalMinutesSinceCheckIn < 360 && 
        !_isOnBreak &&
        !hasTakenLunchBreak) {
      return true;
    }
    
    return false;
  }
  
  // Get the appropriate break type based on time
  static String? getBreakType(DateTime checkInTime) {
    final now = DateTime.now();
    final timeSinceCheckIn = now.difference(checkInTime);
    final totalMinutesSinceCheckIn = timeSinceCheckIn.inMinutes;
    
    // Check if we've already taken the morning break today
    final today = now.toIso8601String().split('T')[0];
    final todayBreaks = _breakTimes.where((breakTime) => 
        breakTime['date'] == today && breakTime['type'] == 'morning').toList();
    final hasTakenMorningBreak = todayBreaks.isNotEmpty;
    
    // Check if we've already taken the lunch break today
    final lunchBreaks = _breakTimes.where((breakTime) => 
        breakTime['date'] == today && breakTime['type'] == 'lunch').toList();
    final hasTakenLunchBreak = lunchBreaks.isNotEmpty;
    
    // Morning break: 2 hours 40 minutes after check-in
    if (totalMinutesSinceCheckIn >= 160 && 
        totalMinutesSinceCheckIn < 200 && 
        !hasTakenMorningBreak) {
      return 'morning';
    }
    
    // Lunch break: 5 hours 20 minutes after check-in
    if (totalMinutesSinceCheckIn >= 320 && 
        totalMinutesSinceCheckIn < 360 && 
        !hasTakenLunchBreak) {
      return 'lunch';
    }
    
    return null;
  }
  
  // Show break notification
  static Future<void> showBreakNotification(String breakType) async {
    final breakDuration = breakType == 'morning' ? morningBreakDuration : lunchBreakDuration;
    final breakName = breakType == 'morning' ? 'Morning Break' : 'Lunch Break';
    
    const androidDetails = AndroidNotificationDetails(
      'break_notifications',
      'Break Time Notifications',
      channelDescription: 'Notifications for break time reminders',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notifications.show(
      1,
      'Break Time!',
      'Time for your $breakName (${breakDuration.inMinutes} minutes)',
      details,
      payload: 'break_start_$breakType',
    );
  }
  
  // Start break timer
  static void startBreak(String breakType) {
    if (_isOnBreak) return;
    
    _isOnBreak = true;
    _currentBreakType = breakType;
    _breakStartTime = DateTime.now();
    _breakDuration = breakType == 'morning' ? morningBreakDuration : lunchBreakDuration;
    
    // Start the break timer
    _breakTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      final elapsed = DateTime.now().difference(_breakStartTime!);
      _breakDuration = elapsed;
      
      // Check if break time is over
      final maxBreakDuration = breakType == 'morning' ? morningBreakDuration : lunchBreakDuration;
      if (elapsed >= maxBreakDuration) {
        // Break time exceeded - show warning
        _showBreakExceededNotification(breakType);
      }
    });
    
    // Set warning timer (5 minutes before break ends)
    final warningTime = (breakType == 'morning' ? morningBreakDuration : lunchBreakDuration) - breakEndWarningTime;
    _breakEndWarningTimer = Timer(warningTime, () {
      _showBreakEndWarningNotification(breakType);
    });
  }
  
  // End break
  static void endBreak() {
    if (!_isOnBreak) return;
    
    // Record the break time
    if (_breakStartTime != null) {
      final breakEndTime = DateTime.now();
      final breakDuration = breakEndTime.difference(_breakStartTime!);
      
      _breakTimes.add({
        'type': _currentBreakType,
        'startTime': _breakStartTime,
        'endTime': breakEndTime,
        'duration': breakDuration,
        'date': DateTime.now().toIso8601String().split('T')[0], // YYYY-MM-DD
      });
    }
    
    _isOnBreak = false;
    _currentBreakType = null;
    _breakStartTime = null;
    _breakDuration = Duration.zero;
    
    _breakTimer?.cancel();
    _breakEndWarningTimer?.cancel();
    _breakTimer = null;
    _breakEndWarningTimer = null;
  }
  
  // Show break end warning notification
  static Future<void> _showBreakEndWarningNotification(String breakType) async {
    final breakName = breakType == 'morning' ? 'Morning Break' : 'Lunch Break';
    
    const androidDetails = AndroidNotificationDetails(
      'break_notifications',
      'Break Time Notifications',
      channelDescription: 'Notifications for break time reminders',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notifications.show(
      2,
      'Break Ending Soon!',
      'Your $breakName will end in 5 minutes. Please prepare to return to work.',
      details,
      payload: 'break_warning_$breakType',
    );
  }
  
  // Show break exceeded notification
  static Future<void> _showBreakExceededNotification(String breakType) async {
    final breakName = breakType == 'morning' ? 'Morning Break' : 'Lunch Break';
    
    const androidDetails = AndroidNotificationDetails(
      'break_notifications',
      'Break Time Notifications',
      channelDescription: 'Notifications for break time reminders',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notifications.show(
      3,
      'Break Time Exceeded!',
      'Your $breakName time has ended. Please return to work immediately.',
      details,
      payload: 'break_exceeded_$breakType',
    );
  }
  
  // Get remaining break time
  static Duration getRemainingBreakTime() {
    if (!_isOnBreak || _breakStartTime == null) return Duration.zero;
    
    final elapsed = DateTime.now().difference(_breakStartTime!);
    final maxBreakDuration = _currentBreakType == 'morning' ? morningBreakDuration : lunchBreakDuration;
    final remaining = maxBreakDuration - elapsed;
    
    return remaining.isNegative ? Duration.zero : remaining;
  }
  
  // Check if break time should be excluded from work time
  static bool shouldExcludeFromWorkTime() {
    return _isOnBreak;
  }
  
  // Get break time statistics for the day
  static Map<String, dynamic> getBreakTimeStats() {
    return {
      'isOnBreak': _isOnBreak,
      'currentBreakType': _currentBreakType,
      'breakStartTime': _breakStartTime,
      'breakDuration': _breakDuration,
      'remainingTime': getRemainingBreakTime(),
    };
  }
  
  // Get total break time for today in minutes
  static int getTotalBreakTimeMinutes() {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final todayBreaks = _breakTimes.where((breakTime) => breakTime['date'] == today).toList();
    
    int totalMinutes = 0;
    for (var breakTime in todayBreaks) {
      totalMinutes += (breakTime['duration'] as Duration).inMinutes;
    }
    
    return totalMinutes;
  }
  
  // Get break times for today
  static List<Map<String, dynamic>> getTodayBreakTimes() {
    final today = DateTime.now().toIso8601String().split('T')[0];
    return _breakTimes.where((breakTime) => breakTime['date'] == today).toList();
  }
  
  // Reset break time service (call this at the start of a new day)
  static void reset() {
    endBreak();
    _breakTimes.clear();
  }
  
  // Reset break times for a new day
  static void resetForNewDay() {
    final today = DateTime.now().toIso8601String().split('T')[0];
    _breakTimes.removeWhere((breakTime) => breakTime['date'] != today);
  }
}
