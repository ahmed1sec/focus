# 🚀 FocusFlow - Complete Setup Guide

This guide will walk you through setting up and running the FocusFlow app on your local machine.

---

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

### Required Software

1. **Flutter SDK** (version 3.9.2 or higher)
   - Download from: https://flutter.dev/docs/get-started/install
   - Verify installation: `flutter --version`

2. **Dart SDK** (version 3.0 or higher)
   - Comes bundled with Flutter
   - Verify: `dart --version`

3. **Git**
   - Download from: https://git-scm.com/downloads
   - Verify: `git --version`

4. **IDE** (choose one):
   - **VS Code** (recommended) with Flutter extension
   - **Android Studio** with Flutter plugin

### Platform-Specific Requirements

#### For Android Development:
- **Android Studio** (for Android SDK and emulator)
- **Android SDK** (API level 21 or higher)
- **Java JDK** (version 11 or higher)
- Enable USB debugging on your Android device (optional)

#### For iOS Development (macOS only):
- **Xcode** (latest version)
- **CocoaPods** (`sudo gem install cocoapods`)
- iOS Simulator or physical iOS device

---

## 🔧 Installation Steps

### Step 1: Clone the Repository

```bash
git clone https://github.com/yourusername/focusflow.git
cd focusflow
```

### Step 2: Install Dependencies

```bash
flutter pub get
```

This will download all required packages:
- `shared_preferences` - Local data storage
- `flutter_local_notifications` - Push notifications
- `permission_handler` - App permissions
- `fl_chart` - Charts and graphs
- `intl` - Internationalization

### Step 3: Verify Flutter Setup

```bash
flutter doctor
```

This command checks your environment and displays a report. Fix any issues marked with ❌.

### Step 4: Check Available Devices

```bash
flutter devices
```

This lists all connected devices and emulators.

---

## 📱 Running the App

### Option 1: Run on Android Emulator

1. **Start Android Emulator**:
   ```bash
   # List available emulators
   flutter emulators
   
   # Launch an emulator
   flutter emulators --launch <emulator_id>
   ```

2. **Run the app**:
   ```bash
   flutter run
   ```

### Option 2: Run on Physical Android Device

1. **Enable Developer Options** on your Android device:
   - Go to Settings → About Phone
   - Tap "Build Number" 7 times
   - Go back to Settings → Developer Options
   - Enable "USB Debugging"

2. **Connect device via USB**

3. **Run the app**:
   ```bash
   flutter run
   ```

### Option 3: Run on iOS Simulator (macOS only)

1. **Open iOS Simulator**:
   ```bash
   open -a Simulator
   ```

2. **Run the app**:
   ```bash
   flutter run -d ios
   ```

### Option 4: Run on Physical iOS Device (macOS only)

1. **Connect your iPhone/iPad**

2. **Trust the computer** on your device

3. **Run the app**:
   ```bash
   flutter run -d <device_id>
   ```

---

## 🏗️ Building for Production

### Android APK (Debug)

```bash
flutter build apk --debug
```

Output: `build/app/outputs/flutter-apk/app-debug.apk`

### Android APK (Release)

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (for Google Play)

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

### iOS (Release)

```bash
flutter build ios --release
```

Then open `ios/Runner.xcworkspace` in Xcode to archive and distribute.

---

## 🐛 Troubleshooting

### Issue: "Flutter command not found"

**Solution**: Add Flutter to your PATH
```bash
export PATH="$PATH:`pwd`/flutter/bin"
```

### Issue: "Android licenses not accepted"

**Solution**: Accept Android licenses
```bash
flutter doctor --android-licenses
```

### Issue: "CocoaPods not installed" (iOS)

**Solution**: Install CocoaPods
```bash
sudo gem install cocoapods
pod setup
```

### Issue: "Gradle build failed" (Android)

**Solution**: 
1. Clean the build:
   ```bash
   flutter clean
   flutter pub get
   ```
2. Check your `android/app/build.gradle` file
3. Ensure you have the correct Android SDK installed

### Issue: "Module not found" errors

**Solution**: Reinstall dependencies
```bash
flutter clean
rm -rf pubspec.lock
flutter pub get
```

### Issue: App crashes on startup

**Solution**: Check logs
```bash
flutter logs
```

---

## 📝 Configuration

### Changing App Name

1. **Android**: Edit `android/app/src/main/AndroidManifest.xml`
   ```xml
   <application android:label="FocusFlow">
   ```

2. **iOS**: Edit `ios/Runner/Info.plist`
   ```xml
   <key>CFBundleName</key>
   <string>FocusFlow</string>
   ```

### Changing App Icon

1. Replace icon files in:
   - Android: `android/app/src/main/res/mipmap-*/ic_launcher.png`
   - iOS: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

2. Or use the `flutter_launcher_icons` package:
   ```bash
   flutter pub add flutter_launcher_icons
   ```

### Changing Package Name

Use the `change_app_package_name` package:
```bash
flutter pub add change_app_package_name
flutter pub run change_app_package_name:main com.yourcompany.focusflow
```

---

## 🧪 Testing

### Run All Tests

```bash
flutter test
```

### Run Specific Test File

```bash
flutter test test/widget_test.dart
```

### Run with Coverage

```bash
flutter test --coverage
```

---

## 📊 Performance Profiling

### Profile Mode

```bash
flutter run --profile
```

### Release Mode Performance

```bash
flutter run --release
```

### Analyze App Size

```bash
flutter build apk --analyze-size
```

---

## 🔄 Hot Reload & Hot Restart

While the app is running:
- **Hot Reload**: Press `r` in the terminal (preserves state)
- **Hot Restart**: Press `R` in the terminal (resets state)
- **Quit**: Press `q` in the terminal

---

## 📦 Dependencies Overview

| Package | Version | Purpose |
|---------|---------|---------|
| `shared_preferences` | ^2.2.2 | Store user settings locally |
| `flutter_local_notifications` | ^16.3.2 | Show notifications |
| `permission_handler` | ^11.2.0 | Request app permissions |
| `fl_chart` | ^0.66.2 | Display charts and graphs |
| `intl` | ^0.19.0 | Date/time formatting |

---

## 🎯 Next Steps

After successful setup:

1. ✅ Run the app and complete the onboarding
2. ✅ Test all four main features
3. ✅ Customize the app to your needs
4. ✅ Build for production
5. ✅ Deploy to app stores

---

## 📞 Support

If you encounter any issues:

1. Check the [Troubleshooting](#-troubleshooting) section
2. Review Flutter documentation: https://flutter.dev/docs
3. Open an issue on GitHub
4. Contact the development team

---

## 🎉 Success!

If you've made it this far, congratulations! Your FocusFlow app should be up and running. 

**Happy coding and stay focused! 🎯**

