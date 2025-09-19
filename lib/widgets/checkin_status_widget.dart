import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/work_timer_service.dart';

class CheckInStatusWidget extends StatefulWidget {
  final bool isCheckedIn;
  final String? checkInTime;

  const CheckInStatusWidget({
    super.key,
    required this.isCheckedIn,
    this.checkInTime,
  });

  @override
  State<CheckInStatusWidget> createState() => _CheckInStatusWidgetState();
}

class _CheckInStatusWidgetState extends State<CheckInStatusWidget> {
  final WorkTimerService _workTimerService = WorkTimerService();

  @override
  void initState() {
    super.initState();
    _workTimerService.addListener(_onTimerChanged);
  }

  @override
  void dispose() {
    _workTimerService.removeListener(_onTimerChanged);
    super.dispose();
  }

  void _onTimerChanged() {
    try {
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in CheckInStatusWidget: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOnBreak = _workTimerService.isOnBreak;
    final colors = isOnBreak 
        ? [Color(0xFFFF9800), Color(0xFFFFB74D)]
        : (widget.isCheckedIn
            ? [Color(0xFF4CAF50), Color(0xFF8BC34A)]
            : [Color(0xFF9E9E9E), Color(0xFFBDBDBD)]);
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colors[0].withValues(alpha: 0.3),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Status Icon
          Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isOnBreak ? Icons.coffee : (widget.isCheckedIn ? Icons.check_circle : Icons.access_time),
              color: Colors.white,
              size: 40,
            ),
          ),
          SizedBox(height: 15),
          
          // Status Text
          Text(
            isOnBreak ? 'On Break' : (widget.isCheckedIn ? 'Checked In' : 'Not Checked In'),
            style: GoogleFonts.outfit(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          // Timer or Check-in Time
          if (widget.isCheckedIn) ...[
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isOnBreak ? Icons.coffee : Icons.timer,
                  color: Colors.white,
                  size: 18,
                ),
                SizedBox(width: 6),
                Text(
                  _workTimerService.isRunning ? _workTimerService.formattedTime : '00:00:00',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4),
            Text(
              isOnBreak ? 'Break started' : 'Since ${widget.checkInTime ?? 'Unknown'}',
              style: GoogleFonts.outfit(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (_workTimerService.isRunning && !isOnBreak) ...[
              SizedBox(height: 4),
              Text(
                '${_workTimerService.hoursWorked.toStringAsFixed(1)} hours worked',
                style: GoogleFonts.outfit(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ] else ...[
            SizedBox(height: 8),
            Text(
              'Go to Attendance to check in',
              style: GoogleFonts.outfit(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
