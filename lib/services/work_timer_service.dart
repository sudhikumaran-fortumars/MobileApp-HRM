import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorkTimerService extends ChangeNotifier {
  static WorkTimerService? _instance;
  
  factory WorkTimerService() {
    _instance ??= WorkTimerService._internal();
    return _instance!;
  }
  
  WorkTimerService._internal() {
    // Initialize with default values
    _elapsed = Duration.zero;
    _breakElapsed = Duration.zero;
    _isRunning = false;
    _isOnBreak = false;
  }

  Timer? _timer;
  DateTime? _startTime;
  late Duration _elapsed;
  late bool _isRunning;
  late bool _isOnBreak;
  DateTime? _breakStartTime;
  late Duration _breakElapsed;

  // Getters
  Duration get elapsed => _elapsed;
  bool get isRunning => _isRunning;
  DateTime? get startTime => _startTime;
  bool get isOnBreak => _isOnBreak;
  Duration get breakElapsed => _breakElapsed;

  String get formattedTime {
    try {
      final duration = _isOnBreak ? _breakElapsed : _elapsed;
      final hours = duration.inHours;
      final minutes = duration.inMinutes.remainder(60);
      final seconds = duration.inSeconds.remainder(60);
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } catch (e) {
      if (kDebugMode) {
        print('Error formatting time: $e');
      }
      return '00:00:00';
    }
  }

  String get formattedTimeShort {
    final hours = _elapsed.inHours;
    final minutes = _elapsed.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }

  double get hoursWorked {
    return _elapsed.inMinutes / 60.0;
  }

  // Start the timer
  void startTimer() {
    try {
      if (_isRunning) return;
      
      _startTime = DateTime.now();
      _isRunning = true;
      
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        try {
          if (_startTime != null) {
            _elapsed = DateTime.now().difference(_startTime!);
            notifyListeners();
          }
        } catch (e) {
          if (kDebugMode) {
            print('Error in timer callback: $e');
          }
        }
      });
      
      _saveTimerState();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error starting timer: $e');
      }
    }
  }

  // Stop the timer
  void stopTimer() {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    _startTime = null;
    _elapsed = Duration.zero;
    _clearTimerState();
    notifyListeners();
  }

  // Pause the timer
  void pauseTimer() {
    if (!_isRunning) return;
    
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    _saveTimerState();
    notifyListeners();
  }

  // Resume the timer
  void resumeTimer() {
    if (_isRunning || _startTime == null) return;
    
    _isRunning = true;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_startTime != null) {
        _elapsed = DateTime.now().difference(_startTime!);
        notifyListeners();
      }
    });
    
    _saveTimerState();
    notifyListeners();
  }

  // Start break timer
  void startBreak() {
    if (_isOnBreak || !_isRunning) return;
    
    _isOnBreak = true;
    _breakStartTime = DateTime.now();
    _breakElapsed = Duration.zero;
    
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_breakStartTime != null) {
        _breakElapsed = DateTime.now().difference(_breakStartTime!);
        notifyListeners();
      }
    });
    
    _saveTimerState();
    notifyListeners();
  }

  // End break timer
  void endBreak() {
    if (!_isOnBreak) return;
    
    _isOnBreak = false;
    _breakStartTime = null;
    _breakElapsed = Duration.zero;
    
    // Resume work timer
    if (_startTime != null) {
      _timer?.cancel();
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (_startTime != null) {
          _elapsed = DateTime.now().difference(_startTime!);
          notifyListeners();
        }
      });
    }
    
    _saveTimerState();
    notifyListeners();
  }

  // Load timer state from SharedPreferences
  Future<void> loadTimerState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final startTimeString = prefs.getString('work_timer_start_time');
      final isRunning = prefs.getBool('work_timer_is_running') ?? false;
      final isOnBreak = prefs.getBool('work_timer_is_on_break') ?? false;
      final breakStartTimeString = prefs.getString('work_timer_break_start_time');
      
      if (startTimeString != null && isRunning) {
        _startTime = DateTime.parse(startTimeString);
        _isRunning = true;
        _elapsed = DateTime.now().difference(_startTime!);
        
        if (isOnBreak && breakStartTimeString != null) {
          _isOnBreak = true;
          _breakStartTime = DateTime.parse(breakStartTimeString);
          _breakElapsed = DateTime.now().difference(_breakStartTime!);
          
          _timer = Timer.periodic(Duration(seconds: 1), (timer) {
            if (_breakStartTime != null) {
              _breakElapsed = DateTime.now().difference(_breakStartTime!);
              notifyListeners();
            }
          });
        } else {
          _timer = Timer.periodic(Duration(seconds: 1), (timer) {
            if (_startTime != null) {
              _elapsed = DateTime.now().difference(_startTime!);
              notifyListeners();
            }
          });
        }
        
        notifyListeners();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading timer state: $e');
      }
    }
  }

  // Save timer state to SharedPreferences
  Future<void> _saveTimerState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_startTime != null) {
        await prefs.setString('work_timer_start_time', _startTime!.toIso8601String());
      }
      await prefs.setBool('work_timer_is_running', _isRunning);
      await prefs.setBool('work_timer_is_on_break', _isOnBreak);
      
      if (_breakStartTime != null) {
        await prefs.setString('work_timer_break_start_time', _breakStartTime!.toIso8601String());
      } else {
        await prefs.remove('work_timer_break_start_time');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving timer state: $e');
      }
    }
  }

  // Clear timer state from SharedPreferences
  Future<void> _clearTimerState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('work_timer_start_time');
      await prefs.remove('work_timer_is_running');
      await prefs.remove('work_timer_is_on_break');
      await prefs.remove('work_timer_break_start_time');
    } catch (e) {
      if (kDebugMode) {
        print('Error clearing timer state: $e');
      }
    }
  }

  // Reset instance (useful for testing or web hot reload)
  static void resetInstance() {
    _instance?.dispose();
    _instance = null;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
