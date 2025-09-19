import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/work_timer_service.dart';

class WorkTimerWidget extends StatefulWidget {
  final bool isCompact;
  final bool showLabel;

  const WorkTimerWidget({
    super.key,
    this.isCompact = false,
    this.showLabel = true,
  });

  @override
  State<WorkTimerWidget> createState() => _WorkTimerWidgetState();
}

class _WorkTimerWidgetState extends State<WorkTimerWidget> {
  final WorkTimerService _timerService = WorkTimerService();

  @override
  void initState() {
    super.initState();
    _timerService.addListener(_onTimerChanged);
  }

  @override
  void dispose() {
    _timerService.removeListener(_onTimerChanged);
    super.dispose();
  }

  void _onTimerChanged() {
    try {
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in WorkTimerWidget: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isCompact) {
      return _buildCompactTimer();
    } else {
      return _buildFullTimer();
    }
  }

  Widget _buildCompactTimer() {
    final isActive = _timerService.isRunning;
    final isOnBreak = _timerService.isOnBreak;
    final color = isOnBreak ? Colors.orange : (isActive ? Colors.green : Colors.grey);
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOnBreak ? Icons.coffee : Icons.timer,
            color: color,
            size: 16,
          ),
          SizedBox(width: 6),
          Text(
            _timerService.formattedTime,
            style: GoogleFonts.outfit(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullTimer() {
    final isActive = _timerService.isRunning;
    final isOnBreak = _timerService.isOnBreak;
    final colors = isOnBreak 
        ? [Color(0xFFFF9800), Color(0xFFFFB74D)]
        : (isActive 
            ? [Color(0xFF4CAF50), Color(0xFF8BC34A)]
            : [Color(0xFF9E9E9E), Color(0xFFBDBDBD)]);
    
    return Container(
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
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.showLabel) ...[
            Text(
              isOnBreak ? 'Break Timer' : 'Work Timer',
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isOnBreak ? Icons.coffee : Icons.timer,
                color: Colors.white,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                _timerService.formattedTime,
                style: GoogleFonts.outfit(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          if (isActive) ...[
            SizedBox(height: 8),
            Text(
              isOnBreak 
                  ? 'On Break'
                  : '${_timerService.hoursWorked.toStringAsFixed(1)} hours worked',
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
