# Break Time Management System

## Overview
The HRM mobile app now includes a comprehensive break time management system that automatically tracks break times and excludes them from work time calculations.

## Features

### 1. Automatic Break Time Notifications
- **Morning Break**: Notification appears 2 hours 40 minutes after check-in (around 11:40 AM)
- **Lunch Break**: Notification appears 5 hours 20 minutes after check-in (around 2:20 PM)
- Notifications are only shown once per break type per day

### 2. Break Time Tracking
- **Morning Break**: 20 minutes duration
- **Lunch Break**: 40 minutes duration
- Break times are automatically tracked and stored
- Break time is excluded from total work time calculations

### 3. Break Time UI Components
- **Break Time Card**: Shows when user is on break with countdown timer
- **Break Action Button**: Appears when it's time for a break
- **End Break Button**: Allows user to end break early or on time

### 4. Work Time Calculation
- Total work time automatically excludes break time
- Real-time calculation of actual work hours
- Break time is tracked separately for reporting

## How It Works

### Break Time Schedule (9 AM to 6 PM Shift)
1. **Check-in**: 9:00 AM
2. **Morning Break**: 11:40 AM - 12:00 PM (20 minutes)
3. **Lunch Break**: 2:20 PM - 3:00 PM (40 minutes)
4. **Check-out**: 6:00 PM

### Notification System
- Local notifications are sent when break time arrives
- Warning notifications 5 minutes before break ends
- Exceeded break time notifications if break goes over allocated time

### Break Time Tracking
- Each break is recorded with start time, end time, and duration
- Break times are stored per day
- System prevents duplicate break notifications

## Technical Implementation

### Dependencies Added
```yaml
flutter_local_notifications: ^17.2.3
timezone: ^0.9.4
```

### Key Files
- `lib/services/break_time_service.dart` - Break time management service
- `lib/main.dart` - Integration with main app and UI components

### Key Methods
- `BreakTimeService.initialize()` - Initialize notification system
- `BreakTimeService.startBreak(breakType)` - Start a break
- `BreakTimeService.endBreak()` - End current break
- `BreakTimeService.getTotalBreakTimeMinutes()` - Get total break time for today

## Usage

### For Employees
1. Check in normally at 9:00 AM
2. Wait for break notification (appears at 11:40 AM and 2:20 PM)
3. Tap "Start Break" when notification appears
4. Break timer will countdown remaining time
5. Tap "End Break" when ready to return to work
6. Break time is automatically excluded from work hours

### For Administrators
- Break times are tracked and can be viewed in reports
- Work time calculations exclude break time automatically
- System prevents abuse by limiting break notifications to once per day

## Benefits
- **Accurate Time Tracking**: Work hours exclude break time
- **Compliance**: Ensures proper break time management
- **User Experience**: Clear notifications and intuitive UI
- **Reporting**: Detailed break time tracking for management

## Future Enhancements
- Configurable break times per employee
- Break time approval workflow
- Integration with payroll systems
- Break time analytics and reporting
