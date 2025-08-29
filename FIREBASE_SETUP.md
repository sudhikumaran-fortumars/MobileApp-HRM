# 🔥 Firebase Setup Guide for FortuMars HRM App

## 📋 Prerequisites

- Flutter SDK installed
- Firebase project created
- Android Studio / Xcode (for platform-specific setup)

## 🚀 Step-by-Step Setup

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project"
3. Enter project name: `fortumars-hrm-app`
4. Enable Google Analytics (optional)
5. Click "Create project"

### 2. Add Android App

1. In Firebase Console, click "Android" icon
2. Package name: `com.example.fortumars_hrm_app`
3. App nickname: `FortuMars HRM Android`
4. Click "Register app"
5. Download `google-services.json`
6. Replace the placeholder file in `android/app/google-services.json`

### 3. Add iOS App

1. In Firebase Console, click "iOS" icon
2. Bundle ID: `com.example.fortumarsHrmApp`
3. App nickname: `FortuMars HRM iOS`
4. Click "Register app"
5. Download `GoogleService-Info.plist`
6. Replace the placeholder file in `ios/Runner/GoogleService-Info.plist`

### 4. Add Web App

1. In Firebase Console, click "Web" icon
2. App nickname: `FortuMars HRM Web`
3. Click "Register app"
4. Copy the config object
5. Update `lib/firebase_options.dart` with your actual values

### 5. Enable Authentication

1. In Firebase Console, go to "Authentication"
2. Click "Get started"
3. Enable "Email/Password" sign-in method
4. Click "Save"

### 6. Enable Firestore Database

1. In Firebase Console, go to "Firestore Database"
2. Click "Create database"
3. Choose "Start in test mode"
4. Select location closest to your users
5. Click "Done"

### 7. Enable Storage

1. In Firebase Console, go to "Storage"
2. Click "Get started"
3. Choose "Start in test mode"
4. Select location closest to your users
5. Click "Done"

### 8. Update Configuration Files

#### Update `lib/firebase_options.dart`

Replace all placeholder values with your actual Firebase configuration:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'your-actual-web-api-key',
  appId: 'your-actual-web-app-id',
  messagingSenderId: 'your-actual-sender-id',
  projectId: 'your-actual-project-id',
  authDomain: 'your-actual-project-id.firebaseapp.com',
  storageBucket: 'your-actual-project-id.appspot.com',
  measurementId: 'your-actual-measurement-id',
);
```

#### Update `android/app/google-services.json`

Replace with your actual downloaded file.

#### Update `ios/Runner/GoogleService-Info.plist`

Replace with your actual downloaded file.

### 9. Test Firebase Connection

1. Run `flutter pub get`
2. Run `flutter run -d chrome` (or your preferred device)
3. Check console for Firebase initialization success

## 🔧 Troubleshooting

### Common Issues:

1. **"No Firebase App '[DEFAULT]' has been created"**

   - Ensure Firebase.initializeApp() is called before runApp()
   - Check firebase_options.dart configuration

2. **"Permission denied" errors**

   - Check Firestore Security Rules
   - Ensure Storage Rules allow read/write

3. **Build errors**
   - Clean and rebuild: `flutter clean && flutter pub get`
   - Check Android/iOS specific configurations

## 📱 Platform-Specific Notes

### Android

- Ensure `google-services.json` is in `android/app/`
- Check `build.gradle.kts` has Firebase plugin
- Minimum SDK: 21 (Firebase requirement)

### iOS

- Ensure `GoogleService-Info.plist` is in `ios/Runner/`
- Check Bundle ID matches Firebase configuration
- Add to Xcode project if needed

### Web

- Update `firebase_options.dart` with web configuration
- Check browser console for errors

## 🎯 Next Steps

After successful setup:

1. Test authentication flow
2. Test Firestore read/write operations
3. Test file uploads to Storage
4. Implement your HRM business logic
5. Set up proper security rules for production

## 📞 Support

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/)

---

**Note**: Keep your Firebase configuration files secure and never commit them to public repositories!
