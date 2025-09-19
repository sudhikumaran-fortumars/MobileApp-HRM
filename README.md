<<<<<<< HEAD
# FortuMars HRM Platform

A comprehensive Human Resource Management (HRM) application built with Flutter, designed to streamline employee attendance, task management, and leave management processes.

## 🚀 Features

### ✨ Core Functionality

- **Employee Authentication**: Secure login system with employee ID and password
- **Dashboard**: Overview of work statistics, quick actions, and recent activities
- **Attendance Management**: Multiple check-in methods and attendance tracking
- **Task Management**: Create, assign, and track tasks with priority levels
- **Leave Management**: Apply for leave, track requests, and view leave balance
- **Profile Management**: Employee information and work statistics

### 🔐 Authentication

- Employee ID-based login system
- Secure password validation
- Session management
- Demo credentials included for testing

### 📊 Dashboard

- Welcome card with employee information
- **Real-time Timer Widget**: Track work hours with start/stop/pause functionality
- Quick statistics (hours today, tasks pending, monthly hours, leave balance)
- Quick action buttons for common tasks
- Recent activity timeline
- Timer status indicators and session tracking

### ⏰ Attendance System

- **Multiple Check-in Methods**:
  - Facial Recognition
  - QR Code Scanning
  - Geo-location Verification
  - Manual Entry
- Real-time attendance status
- **Automatic Timer Integration**: Timer starts/stops with check-in/check-out
- Daily summary with check-in/check-out times
- Attendance history tracking
- Real-time hours calculation using timer data

### 📋 Task Management

- **Task Categories**: All, Pending, In Progress, Completed
- **Priority Levels**: High, Medium, Low
- **Task Operations**: Create, Edit, Delete, Status Change
- Estimated hours tracking
- Deadline management
- Assignment tracking

### 📅 Leave Management

- **Leave Types**: Sick, Casual, Annual, Emergency, Maternity
- Leave application form
- Request tracking and status
- Leave balance overview
- Leave type breakdown with visual indicators

### 👤 Profile Management

- Personal information display
- Work statistics
- Department and shift details
- Settings and preferences
- Logout functionality

## 🛠️ Technical Details

### Built With

- **Flutter**: Cross-platform mobile app development framework
- **Dart**: Programming language
- **Material Design**: UI/UX design system

### Architecture

- **StatefulWidget**: For dynamic UI components
- **Provider Pattern**: For state management
- **MVC Architecture**: Model-View-Controller pattern
- **Responsive Design**: Adaptive to different screen sizes

### Key Components

- **SplashScreen**: Animated welcome screen
- **LoginScreen**: Authentication interface
- **MainScreen**: Bottom navigation container
- **DashboardScreen**: Main overview screen with timer widget
- **AttendanceScreen**: Attendance management with integrated timer
- **TaskScreen**: Task operations
- **LeaveScreen**: Leave management
- **ProfileScreen**: User profile and settings
- **TimerWidget**: Real-time work hour tracking component
- **TimerService**: Timer state management and persistence

## 📱 Screenshots

The application includes:

- Modern, clean UI design
- Intuitive navigation
- Responsive layouts
- Professional color scheme
- Interactive elements

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / VS Code
- Android Emulator or Physical Device

### Installation

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd flutter_application_1
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run
   ```

### Demo Credentials

- **Employee ID**: `EMP001`
- **Password**: `password`

## 📁 Project Structure

```
lib/
├── main.dart                 # Main application entry point
├── models/                   # Data models (if separated)
├── screens/                  # UI screens (if separated)
├── widgets/                  # Reusable UI components (if separated)
└── utils/                    # Utility functions (if separated)
```

## 🔧 Configuration

### Theme Configuration

- Primary Color: `#1976D2` (Blue)
- Font Family: SF Pro Display
- Material Design 3 compliance

### Mock Data

The application includes sample data for:

- 3 sample employees
- Sample attendance records
- Sample tasks
- Sample leave requests

## 📊 Data Models

### Employee

- Employee ID, Name, Role
- Department, Shift, Status
- Hourly Rate, Location

### AttendanceRecord

- Date, Check-in/Check-out times
- Status, Hours worked
- Location, Method used

### Task

- ID, Title, Description
- Assigned to/by, Deadline
- Status, Priority, Estimated hours

### LeaveRequest

- ID, Employee ID, Type
- Start/End dates, Reason
- Status

## 🎯 Usage Guide

### 1. Getting Started

1. Launch the application
2. Wait for the splash screen animation
3. Login with demo credentials

### 2. Dashboard Navigation

- Use bottom navigation to switch between screens
- Dashboard provides quick access to all features
- Quick action buttons for common tasks

### 3. Attendance Management

1. Navigate to Attendance tab
2. Choose check-in method
3. Complete verification process
4. View attendance history

### 4. Task Management

1. Go to Tasks tab
2. Create new tasks with required details
3. Manage task status and priority
4. Track progress and deadlines

### 5. Leave Management

1. Access Leave tab
2. Apply for leave with type and dates
3. View leave balance and history
4. Track request status

## 🔒 Security Features

- Employee ID validation
- Password protection
- Session management
- Secure navigation

## 📱 Platform Support

- **Android**: Full support
- **iOS**: Full support (with iOS-specific adjustments)
- **Web**: Responsive web interface
- **Desktop**: Windows, macOS, Linux support

## 🚧 Future Enhancements

- **Real-time Sync**: Cloud database integration
- **Push Notifications**: Task reminders and updates
- **Biometric Authentication**: Fingerprint/Face ID support
- **Offline Mode**: Local data storage
- **Multi-language Support**: Internationalization
- **Advanced Analytics**: Detailed reporting and insights
- **API Integration**: Backend service connectivity

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👨‍💻 Development Team

- **Abdul Rahman** - Frontend & Backend Developer
- **Akash Kumar** - Frontend & Backend Developer
- **BalaMurugan** - Frontend Developer

## 📞 Support

For support and questions:

- Create an issue in the repository
- Contact the development team
- Check the documentation

## 🔄 Version History

- **v1.0.0** - Initial release with core HRM features
- Basic authentication and navigation
- Attendance, task, and leave management
- Responsive UI design

---

**Note**: This is a demo application with mock data. For production use, integrate with real backend services and implement proper security measures.
=======
# FortuMars HRM Platform

A comprehensive Human Resource Management (HRM) application built with Flutter, designed to streamline employee attendance, task management, and leave management processes.

## 🚀 Features

### ✨ Core Functionality

- **Employee Authentication**: Secure login system with employee ID and password
- **Dashboard**: Overview of work statistics, quick actions, and recent activities
- **Attendance Management**: Multiple check-in methods and attendance tracking
- **Task Management**: Create, assign, and track tasks with priority levels
- **Leave Management**: Apply for leave, track requests, and view leave balance
- **Profile Management**: Employee information and work statistics

### 🔐 Authentication

- Employee ID-based login system
- Secure password validation
- Session management
- Demo credentials included for testing

### 📊 Dashboard

- Welcome card with employee information
- Quick statistics (hours today, tasks pending, monthly hours, leave balance)
- Quick action buttons for common tasks
- Recent activity timeline

### ⏰ Attendance System

- **Multiple Check-in Methods**:
  - Facial Recognition
  - QR Code Scanning
  - Geo-location Verification
  - Manual Entry
- Real-time attendance status
- Daily summary with check-in/check-out times
- Attendance history tracking
- Hours calculation

### 📋 Task Management

- **Task Categories**: All, Pending, In Progress, Completed
- **Priority Levels**: High, Medium, Low
- **Task Operations**: Create, Edit, Delete, Status Change
- Estimated hours tracking
- Deadline management
- Assignment tracking

### 📅 Leave Management

- **Leave Types**: Sick, Casual, Annual, Emergency, Maternity
- Leave application form
- Request tracking and status
- Leave balance overview
- Leave type breakdown with visual indicators

### 👤 Profile Management

- Personal information display
- Work statistics
- Department and shift details
- Settings and preferences
- Logout functionality

## 🛠️ Technical Details

### Built With

- **Flutter**: Cross-platform mobile app development framework
- **Dart**: Programming language
- **Material Design**: UI/UX design system

### Architecture

- **StatefulWidget**: For dynamic UI components
- **Provider Pattern**: For state management
- **MVC Architecture**: Model-View-Controller pattern
- **Responsive Design**: Adaptive to different screen sizes

### Key Components

- **SplashScreen**: Animated welcome screen
- **LoginScreen**: Authentication interface
- **MainScreen**: Bottom navigation container
- **DashboardScreen**: Main overview screen
- **AttendanceScreen**: Attendance management
- **TaskScreen**: Task operations
- **LeaveScreen**: Leave management
- **ProfileScreen**: User profile and settings

## 📱 Screenshots

The application includes:

- Modern, clean UI design
- Intuitive navigation
- Responsive layouts
- Professional color scheme
- Interactive elements

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / VS Code
- Android Emulator or Physical Device

### Installation

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd flutter_application_1
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run
   ```

### Demo Credentials

- **Employee ID**: `EMP001`
- **Password**: `password`

## 📁 Project Structure

```
lib/
├── main.dart                 # Main application entry point
├── models/                   # Data models (if separated)
├── screens/                  # UI screens (if separated)
├── widgets/                  # Reusable UI components (if separated)
└── utils/                    # Utility functions (if separated)
```

## 🔧 Configuration

### Theme Configuration

- Primary Color: `#1976D2` (Blue)
- Font Family: SF Pro Display
- Material Design 3 compliance

### Mock Data

The application includes sample data for:

- 3 sample employees
- Sample attendance records
- Sample tasks
- Sample leave requests

## 📊 Data Models

### Employee

- Employee ID, Name, Role
- Department, Shift, Status
- Hourly Rate, Location

### AttendanceRecord

- Date, Check-in/Check-out times
- Status, Hours worked
- Location, Method used

### Task

- ID, Title, Description
- Assigned to/by, Deadline
- Status, Priority, Estimated hours

### LeaveRequest

- ID, Employee ID, Type
- Start/End dates, Reason
- Status

## 🎯 Usage Guide

### 1. Getting Started

1. Launch the application
2. Wait for the splash screen animation
3. Login with demo credentials

### 2. Dashboard Navigation

- Use bottom navigation to switch between screens
- Dashboard provides quick access to all features
- Quick action buttons for common tasks

### 3. Attendance Management

1. Navigate to Attendance tab
2. Choose check-in method
3. Complete verification process
4. View attendance history

### 4. Task Management

1. Go to Tasks tab
2. Create new tasks with required details
3. Manage task status and priority
4. Track progress and deadlines

### 5. Leave Management

1. Access Leave tab
2. Apply for leave with type and dates
3. View leave balance and history
4. Track request status

## 🔒 Security Features

- Employee ID validation
- Password protection
- Session management
- Secure navigation

## 📱 Platform Support

- **Android**: Full support
- **iOS**: Full support (with iOS-specific adjustments)
- **Web**: Responsive web interface
- **Desktop**: Windows, macOS, Linux support

## 🚧 Future Enhancements

- **Real-time Sync**: Cloud database integration
- **Push Notifications**: Task reminders and updates
- **Biometric Authentication**: Fingerprint/Face ID support
- **Offline Mode**: Local data storage
- **Multi-language Support**: Internationalization
- **Advanced Analytics**: Detailed reporting and insights
- **API Integration**: Backend service connectivity

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👨‍💻 Development Team

- **Abdul Rahman** - Frontend & Backend Developer
- **Akash Kumar** - Frontend & Backend Developer
- **BalaMurugan** - Frontend Developer

## 📞 Support

For support and questions:

- Create an issue in the repository
- Contact the development team
- Check the documentation

## 🔄 Version History

- **v1.0.0** - Initial release with core HRM features
- Basic authentication and navigation
- Attendance, task, and leave management
- Responsive UI design

---

**Note**: This is a demo application with mock data. For production use, integrate with real backend services and implement proper security measures.
>>>>>>> 3b9ce857a92dc199a5e3d88b6807ade16bfdb101
