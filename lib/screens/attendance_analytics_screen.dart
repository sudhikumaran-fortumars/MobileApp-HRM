import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';

// Attendance Analytics Screen
class AttendanceAnalyticsScreen extends StatefulWidget {
  @override
  State<AttendanceAnalyticsScreen> createState() => _AttendanceAnalyticsScreenState();
}

class _AttendanceAnalyticsScreenState extends State<AttendanceAnalyticsScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  DateTime _selectedDate = DateTime.now();
  String _selectedFilter = 'All';
  List<Map<String, dynamic>> _attendanceData = [];
  Map<String, dynamic> _analyticsSummary = {};
  DateTime? _calendarSelectedDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadAttendanceData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadAttendanceData() {
    // Load real-time attendance data from DataManager
    _attendanceData = DataManager.attendanceHistory.map((record) => {
      'date': record['date'],
      'employee': 'Current User',
      'status': record['status'],
      'checkIn': record['checkIn'],
      'checkOut': record['checkOut'],
      'hours': record['hours'] ?? 0.0,
      'late': record['status'] == 'Late',
    }).toList();

    _calculateAnalytics();
  }

  void _calculateAnalytics() {
    int totalDays = _attendanceData.length;
    int onTimeDays = _attendanceData.where((record) => record['status'] == 'On Time').length;
    int lateDays = _attendanceData.where((record) => record['status'] == 'Late').length;
    int absentDays = _attendanceData.where((record) => record['status'] == 'Absent').length;
    int presentDays = onTimeDays + lateDays; // Total present days (on time + late)
    
    // Calculate streak
    int currentStreak = 0;
    for (int i = _attendanceData.length - 1; i >= 0; i--) {
      if (_attendanceData[i]['status'] == 'On Time' || _attendanceData[i]['status'] == 'Late') {
        currentStreak++;
      } else {
        break;
      }
    }

    _analyticsSummary = {
      'totalDays': totalDays,
      'onTimeDays': onTimeDays,
      'presentDays': presentDays,
      'lateDays': lateDays,
      'absentDays': absentDays,
      'attendanceRate': totalDays > 0 ? (presentDays / totalDays * 100).round() : 0,
      'currentStreak': currentStreak,
      'averageHours': _attendanceData.isNotEmpty 
          ? (() {
              final hoursList = _attendanceData.where((r) => r['hours'] > 0).map((r) => r['hours']).toList();
              return hoursList.isNotEmpty 
                  ? (hoursList.reduce((a, b) => a + b) / hoursList.length).toStringAsFixed(1)
                  : '0.0';
            })()
          : '0.0',
    };
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
                  'Attendance Analytics',
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
            SizedBox(width: 90),
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
            Tab(text: 'Overview'),
            Tab(text: 'Reports'),
            Tab(text: 'Trends'),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: _showDatePicker,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildReportsTab(),
          _buildTrendsTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary Cards
          Row(
            children: [
              Expanded(child: _buildSummaryCard('Attendance Rate', '${_analyticsSummary['attendanceRate']}%', Colors.green, Icons.check_circle)),
              SizedBox(width: 12),
              Expanded(child: _buildSummaryCard('Current Streak', '${_analyticsSummary['currentStreak']} days', Colors.blue, Icons.local_fire_department)),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildSummaryCard('On Time Days', '${_analyticsSummary['onTimeDays']}', Colors.green, Icons.check_circle)),
              SizedBox(width: 12),
              Expanded(child: _buildSummaryCard('Late Days', '${_analyticsSummary['lateDays']}', Colors.orange, Icons.schedule)),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildSummaryCard('Absent Days', '${_analyticsSummary['absentDays']}', Colors.red, Icons.cancel)),
              SizedBox(width: 12),
              Expanded(child: _buildSummaryCard('Avg Hours', '${_analyticsSummary['averageHours']}h', Colors.purple, Icons.access_time)),
            ],
          ),
          SizedBox(height: 24),
          
          // Recent Activity
          Text(
            'Recent Activity',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          _buildRecentActivityList(),
        ],
      ),
    );
  }

  Widget _buildReportsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Bar
          Container(
            padding: EdgeInsets.all(16),
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
            child: Row(
              children: [
                Icon(Icons.filter_list, color: Colors.grey[600]),
                SizedBox(width: 8),
                Text('Filter: ', style: GoogleFonts.outfit(fontWeight: FontWeight.w500)),
                DropdownButton<String>(
                  value: _selectedFilter,
                  onChanged: (value) {
                    setState(() {
                      _selectedFilter = value!;
                    });
                  },
                  items: ['All', 'Present', 'Late', 'Absent'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                Spacer(),
                Text('Date: ${_formatDate(_selectedDate)}', style: GoogleFonts.outfit(color: Colors.grey[600])),
              ],
            ),
          ),
          SizedBox(height: 16),
          
          // Attendance Records
          _buildAttendanceRecordsList(),
        ],
      ),
    );
  }

  Widget _buildTrendsTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Today's Summary Card
          _buildTodaysSummaryCard(),
          SizedBox(height: 24),
          
          // Calendar Filter
          _buildCalendarFilter(),
          SizedBox(height: 24),
          
          // Selected Date Summary
          if (_calendarSelectedDate != null) ...[
            _buildSelectedDateSummary(),
            SizedBox(height: 24),
          ],
          
          // Weekly Chart Placeholder
          Container(
            height: 200,
            padding: EdgeInsets.all(16),
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
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart, size: 48, color: Colors.grey[400]),
                  SizedBox(height: 8),
                  Text(
                    'Weekly Attendance Chart',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    'Chart visualization would go here',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          
          // Monthly Summary
          _buildMonthlySummary(),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16),
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
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityList() {
    if (_attendanceData.isEmpty) {
      return Container(
        padding: EdgeInsets.all(20),
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
        child: Center(
          child: Text(
            'No attendance records yet',
            style: GoogleFonts.outfit(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return Container(
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
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: _attendanceData.take(5).length,
        itemBuilder: (context, index) {
          final record = _attendanceData[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(record['status']).withValues(alpha: 0.1),
              child: Icon(
                _getStatusIcon(record['status']),
                color: _getStatusColor(record['status']),
              ),
            ),
            title: Text(
              record['date'],
              style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
            ),
            subtitle: Text('${record['checkIn'] ?? 'N/A'} - ${record['checkOut'] ?? 'N/A'}'),
            trailing: _buildStatusChip(record['status']),
          );
        },
      ),
    );
  }

  Widget _buildAttendanceRecordsList() {
    List<Map<String, dynamic>> filteredData = _attendanceData;
    if (_selectedFilter != 'All') {
      filteredData = _attendanceData.where((record) => record['status'] == _selectedFilter).toList();
    }

    if (filteredData.isEmpty) {
      return Container(
        padding: EdgeInsets.all(20),
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
        child: Center(
          child: Text(
            _attendanceData.isEmpty 
                ? 'No attendance records yet'
                : 'No records found for selected filter',
            style: GoogleFonts.outfit(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return Container(
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
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: filteredData.length,
        itemBuilder: (context, index) {
          final record = filteredData[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: _getStatusColor(record['status']).withValues(alpha: 0.1),
              child: Icon(
                _getStatusIcon(record['status']),
                color: _getStatusColor(record['status']),
              ),
            ),
            title: Text(
              record['date'],
              style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${record['checkIn'] ?? 'N/A'} - ${record['checkOut'] ?? 'N/A'}'),
                if (record['hours'] > 0) Text('${record['hours']} hours worked'),
              ],
            ),
            trailing: _buildStatusChip(record['status']),
          );
        },
      ),
    );
  }

  Widget _buildMonthlySummary() {
    return Container(
      padding: EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This Month Summary',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMonthlyStat('Present', '${_analyticsSummary['presentDays']}', Colors.green),
              _buildMonthlyStat('Late', '${_analyticsSummary['lateDays']}', Colors.orange),
              _buildMonthlyStat('Absent', '${_analyticsSummary['absentDays']}', Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color color = _getStatusColor(status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: GoogleFonts.outfit(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'On Time':
        return Colors.green;
      case 'Late':
        return Colors.orange;
      case 'Absent':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'On Time':
        return Icons.check_circle;
      case 'Late':
        return Icons.schedule;
      case 'Absent':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${date.day}/${months[date.month - 1]}/${date.year}';
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Filter Options'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('All Records'),
              leading: Icon(
                _selectedFilter == 'All' ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: _selectedFilter == 'All' ? Theme.of(context).primaryColor : Colors.grey,
              ),
              onTap: () {
                setState(() {
                  _selectedFilter = 'All';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('On Time Only'),
              leading: Icon(
                _selectedFilter == 'On Time' ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: _selectedFilter == 'On Time' ? Theme.of(context).primaryColor : Colors.grey,
              ),
              onTap: () {
                setState(() {
                  _selectedFilter = 'On Time';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Late Only'),
              leading: Icon(
                _selectedFilter == 'Late' ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: _selectedFilter == 'Late' ? Theme.of(context).primaryColor : Colors.grey,
              ),
              onTap: () {
                setState(() {
                  _selectedFilter = 'Late';
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Absent Only'),
              leading: Icon(
                _selectedFilter == 'Absent' ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: _selectedFilter == 'Absent' ? Theme.of(context).primaryColor : Colors.grey,
              ),
              onTap: () {
                setState(() {
                  _selectedFilter = 'Absent';
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDatePicker() {
    showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2024, 1, 1),
      lastDate: DateTime.now(),
    ).then((date) {
      if (date != null) {
        setState(() {
          _selectedDate = date;
        });
      }
    });
  }

  Widget _buildTodaysSummaryCard() {
    final today = DateTime.now();
    final todayRecord = _attendanceData.firstWhere(
      (record) => record['date'] == _formatDate(today),
      orElse: () => {},
    );

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.today, color: Colors.white, size: 24),
              SizedBox(width: 8),
              Text(
                'Today\'s Summary',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          if (todayRecord.isNotEmpty) ...[
            _buildTodaysDetailRow('Check-in Time', todayRecord['checkIn'] ?? 'Not checked in', Icons.login),
            _buildTodaysDetailRow('Check-out Time', todayRecord['checkOut'] ?? 'Not checked out', Icons.logout),
            _buildTodaysDetailRow('Hours Worked', '${todayRecord['hours']?.toStringAsFixed(1) ?? '0.0'} hours', Icons.access_time),
            _buildTodaysDetailRow('Break Taken', '${todayRecord['breaks'] ?? 0} minutes', Icons.coffee),
            _buildTodaysDetailRow('Status', todayRecord['status'] ?? 'Not checked in', 
                todayRecord['status'] == 'On Time' ? Icons.check_circle : 
                todayRecord['status'] == 'Late' ? Icons.schedule : Icons.cancel),
          ] else ...[
            Center(
              child: Column(
                children: [
                  Icon(Icons.no_accounts, color: Colors.white70, size: 48),
                  SizedBox(height: 8),
                  Text(
                    'No attendance record for today',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTodaysDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 16),
          SizedBox(width: 12),
          Text(
            '$label: ',
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarFilter() {
    return Container(
      padding: EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.blue, size: 20),
              SizedBox(width: 8),
              Text(
                'Select Date to View Details',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          GestureDetector(
            onTap: _showCalendarPicker,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_month, color: Colors.grey[600]),
                  SizedBox(width: 8),
                  Text(
                    _calendarSelectedDate != null 
                        ? _formatDate(_calendarSelectedDate!)
                        : 'Tap to select date',
                    style: GoogleFonts.outfit(
                      color: _calendarSelectedDate != null ? Colors.black87 : Colors.grey[600],
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedDateSummary() {
    final selectedRecord = _attendanceData.firstWhere(
      (record) => record['date'] == _formatDate(_calendarSelectedDate!),
      orElse: () => {},
    );

    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.blue, size: 24),
              SizedBox(width: 8),
              Text(
                'Details for ${_formatDate(_calendarSelectedDate!)}',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          if (selectedRecord.isNotEmpty) ...[
            _buildSelectedDateDetailRow('Check-in Time', selectedRecord['checkIn'] ?? 'Not checked in', Icons.login),
            _buildSelectedDateDetailRow('Check-out Time', selectedRecord['checkOut'] ?? 'Not checked out', Icons.logout),
            _buildSelectedDateDetailRow('Hours Worked', '${selectedRecord['hours']?.toStringAsFixed(1) ?? '0.0'} hours', Icons.access_time),
            _buildSelectedDateDetailRow('Break Taken', '${selectedRecord['breaks'] ?? 0} minutes', Icons.coffee),
            _buildSelectedDateDetailRow('Overtime', '${selectedRecord['overtime']?.toStringAsFixed(1) ?? '0.0'} hours', Icons.timer),
            _buildSelectedDateDetailRow('Status', selectedRecord['status'] ?? 'Not checked in', 
                selectedRecord['status'] == 'On Time' ? Icons.check_circle : 
                selectedRecord['status'] == 'Late' ? Icons.schedule : Icons.cancel),
          ] else ...[
            Center(
              child: Column(
                children: [
                  Icon(Icons.no_accounts, color: Colors.grey[400], size: 48),
                  SizedBox(height: 8),
                  Text(
                    'No attendance record for this date',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSelectedDateDetailRow(String label, String value, IconData icon) {
    Color iconColor = Colors.blue;
    if (label == 'Status') {
      if (value.contains('On Time')) {
        iconColor = Colors.green;
      } else if (value.contains('Late')) {
        iconColor = Colors.orange;
      } else if (value.contains('Absent')) {
        iconColor = Colors.red;
      }
    }

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 18),
          SizedBox(width: 12),
          Text(
            '$label: ',
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCalendarPicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _calendarSelectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _calendarSelectedDate) {
      setState(() {
        _calendarSelectedDate = picked;
      });
    }
  }
}
