# Logo Setup Guide for FortuMars HRM

## 📁 Required Logo Images

To complete the logo setup, you need to add the following images to the `assets/images/` folder:

### 1. `fortumars_logo_dark.png`

- **Use for**: Dark backgrounds (like the login screen blue container)
- **Description**: Logo with white outlines and text on dark/black background
- **Size**: Recommended 200x200px or higher for quality

### 2. `fortumars_logo_white.png`

- **Use for**: Light/white backgrounds (like the splash screen white container)
- **Description**: Logo with blue/orange colors on white background
- **Size**: Recommended 200x200px or higher for quality

### 3. `fortumars_logo_small.png` (Optional)

- **Use for**: Small sizes and icons
- **Description**: Simplified version for small displays
- **Size**: Recommended 64x64px or 128x128px

## 📂 File Structure

```
assets/
└── images/
    ├── fortumars_logo_dark.png
    ├── fortumars_logo_white.png
    └── fortumars_logo_small.png (optional)
```

## 🔧 Implementation Details

The app now automatically selects the appropriate logo based on:

- **Background color**: Dark vs light
- **Size requirements**: Large vs small displays
- **Context**: Splash screen, login, profile, etc.

## ✅ What's Already Updated

1. ✅ `pubspec.yaml` - Assets folder configured
2. ✅ Logo helper function created
3. ✅ Splash screen logo updated
4. ✅ Login screen logo updated
5. ✅ Profile section icons updated

## 🚀 Next Steps

1. Add your logo images to the `assets/images/` folder
2. Run `flutter pub get` to update dependencies
3. Test the app to see your logos in action!

## 🎨 Logo Usage Examples

- **Splash Screen**: Uses white logo on white container
- **Login Screen**: Uses dark logo on blue container
- **Profile Section**: Uses appropriate icons for each section
- **Small Displays**: Automatically scales logos appropriately
