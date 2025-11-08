# 🚀 FocusFlow - Deployment Guide

Complete guide for deploying FocusFlow to production environments.

---

## 📱 Android Deployment

### Prerequisites
- ✅ Android Studio installed
- ✅ Android SDK configured
- ✅ Keystore file for signing
- ✅ Google Play Console account

### Step 1: Generate Keystore

```bash
keytool -genkey -v -keystore ~/focusflow-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias focusflow
```

**Save these details:**
- Keystore password
- Key alias
- Key password

### Step 2: Configure Signing

Create `android/key.properties`:
```properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=focusflow
storeFile=/path/to/focusflow-key.jks
```

Update `android/app/build.gradle`:
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    ...
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

### Step 3: Update App Configuration

**android/app/src/main/AndroidManifest.xml:**
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.yourcompany.focusflow">
    
    <application
        android:label="FocusFlow"
        android:icon="@mipmap/ic_launcher">
        ...
    </application>
</manifest>
```

**android/app/build.gradle:**
```gradle
android {
    defaultConfig {
        applicationId "com.yourcompany.focusflow"
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }
}
```

### Step 4: Build Release APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### Step 5: Build App Bundle (Recommended)

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

### Step 6: Test Release Build

```bash
flutter install --release
```

### Step 7: Upload to Google Play

1. Go to [Google Play Console](https://play.google.com/console)
2. Create new app
3. Fill in app details
4. Upload app bundle
5. Complete store listing
6. Submit for review

---

## 🍎 iOS Deployment

### Prerequisites
- ✅ macOS with Xcode
- ✅ Apple Developer account ($99/year)
- ✅ iOS device for testing
- ✅ App Store Connect access

### Step 1: Configure Xcode Project

```bash
open ios/Runner.xcworkspace
```

**Update in Xcode:**
1. Select Runner target
2. General tab:
   - Display Name: FocusFlow
   - Bundle Identifier: com.yourcompany.focusflow
   - Version: 1.0.0
   - Build: 1
3. Signing & Capabilities:
   - Team: Select your team
   - Signing Certificate: Automatic

### Step 2: Update Info.plist

**ios/Runner/Info.plist:**
```xml
<key>CFBundleName</key>
<string>FocusFlow</string>
<key>CFBundleDisplayName</key>
<string>FocusFlow</string>
<key>CFBundleShortVersionString</key>
<string>1.0.0</string>
```

### Step 3: Add App Icons

Replace icons in:
```
ios/Runner/Assets.xcassets/AppIcon.appiconset/
```

Required sizes:
- 20x20 @2x, @3x
- 29x29 @2x, @3x
- 40x40 @2x, @3x
- 60x60 @2x, @3x
- 1024x1024 (App Store)

### Step 4: Build Release

```bash
flutter build ios --release
```

### Step 5: Archive in Xcode

1. Open Xcode
2. Product → Archive
3. Wait for archive to complete
4. Organizer window opens

### Step 6: Upload to App Store

1. In Organizer, select archive
2. Click "Distribute App"
3. Select "App Store Connect"
4. Upload
5. Wait for processing

### Step 7: Submit for Review

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Select your app
3. Fill in app information
4. Add screenshots
5. Submit for review

---

## 🌐 Web Deployment (Optional)

### Build for Web

```bash
flutter build web --release
```

Output: `build/web/`

### Deploy to Firebase Hosting

```bash
npm install -g firebase-tools
firebase login
firebase init hosting
firebase deploy
```

### Deploy to Netlify

```bash
npm install -g netlify-cli
netlify deploy --prod --dir=build/web
```

### Deploy to Vercel

```bash
npm install -g vercel
vercel --prod
```

---

## 🖥️ Desktop Deployment (Optional)

### Windows

```bash
flutter build windows --release
```

Output: `build/windows/runner/Release/`

### macOS

```bash
flutter build macos --release
```

Output: `build/macos/Build/Products/Release/`

### Linux

```bash
flutter build linux --release
```

Output: `build/linux/x64/release/bundle/`

---

## 📊 Pre-Deployment Checklist

### Code Quality
- [ ] Run `flutter analyze` (no errors)
- [ ] Run `flutter test` (all tests pass)
- [ ] Code reviewed and approved
- [ ] No debug code or console logs

### App Configuration
- [ ] App name updated
- [ ] Package name/Bundle ID set
- [ ] Version number updated
- [ ] App icons added
- [ ] Splash screen configured

### Legal & Compliance
- [ ] Privacy policy created
- [ ] Terms of service written
- [ ] GDPR compliance checked
- [ ] Age rating determined
- [ ] Content rating completed

### Store Listing
- [ ] App description written
- [ ] Screenshots prepared (5-8 per device)
- [ ] Feature graphic created
- [ ] Promotional video (optional)
- [ ] Keywords researched

### Testing
- [ ] Tested on multiple devices
- [ ] Tested on different OS versions
- [ ] Performance tested
- [ ] Battery usage checked
- [ ] Network conditions tested

---

## 📸 Screenshot Requirements

### Android (Google Play)
- **Phone**: 1080x1920 (minimum)
- **7-inch Tablet**: 1200x1920
- **10-inch Tablet**: 1600x2560
- **Feature Graphic**: 1024x500

### iOS (App Store)
- **iPhone 6.7"**: 1290x2796
- **iPhone 6.5"**: 1242x2688
- **iPhone 5.5"**: 1242x2208
- **iPad Pro 12.9"**: 2048x2732

---

## 🔐 Security Best Practices

### Before Release
1. **Remove debug code**
   ```dart
   // Remove all print() statements
   // Remove debugPrint()
   // Remove assert() in production
   ```

2. **Obfuscate code**
   ```bash
   flutter build apk --release --obfuscate --split-debug-info=build/debug-info
   ```

3. **Enable ProGuard** (Android)
   ```gradle
   buildTypes {
       release {
           minifyEnabled true
           shrinkResources true
           proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
       }
   }
   ```

4. **Secure API keys**
   - Use environment variables
   - Never commit keys to Git
   - Use Flutter dotenv package

---

## 📈 Post-Deployment

### Monitoring
- [ ] Set up Firebase Analytics
- [ ] Configure Crashlytics
- [ ] Monitor app performance
- [ ] Track user engagement

### Updates
- [ ] Plan update schedule
- [ ] Collect user feedback
- [ ] Fix critical bugs quickly
- [ ] Add new features gradually

### Marketing
- [ ] Create landing page
- [ ] Social media presence
- [ ] App Store Optimization (ASO)
- [ ] User reviews management

---

## 🐛 Troubleshooting

### Build Fails
```bash
flutter clean
flutter pub get
flutter build apk --release
```

### Signing Issues (Android)
- Verify keystore path
- Check passwords
- Ensure key.properties exists

### Xcode Build Fails (iOS)
```bash
cd ios
pod install
cd ..
flutter clean
flutter build ios
```

### App Rejected
- Read rejection reason carefully
- Fix issues mentioned
- Resubmit with explanation

---

## 📞 Support Resources

- **Flutter Docs**: https://flutter.dev/docs/deployment
- **Google Play Console**: https://play.google.com/console
- **App Store Connect**: https://appstoreconnect.apple.com
- **Firebase**: https://console.firebase.google.com

---

## 🎉 Congratulations!

Your FocusFlow app is now deployed and available to users worldwide!

**Next Steps:**
1. Monitor app performance
2. Respond to user reviews
3. Plan feature updates
4. Grow your user base

**Good luck! 🚀**

