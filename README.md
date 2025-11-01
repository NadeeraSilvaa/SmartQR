# SmartQR+ 📱

A modern, production-ready Flutter app for generating and scanning QR codes with AI-enhanced features.

![Flutter](https://img.shields.io/badge/Flutter-3.24+-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?logo=dart)
![License](https://img.shields.io/badge/License-MIT-green)

## ✨ Features

### 🎨 QR Code Generator
- Generate QR codes from text, URLs, phone numbers, Wi-Fi credentials, and more
- Customize QR code colors, background, and size
- Save QR codes as images to gallery
- Share QR codes via social apps
- Real-time preview

### 📷 QR Code Scanner
- Scan QR codes using device camera
- Auto-detect QR code types (URL, contact, Wi-Fi, etc.)
- Quick actions: Copy, Open URL, Call, Email
- Camera flashlight toggle
- Front/back camera switching

### 🤖 AI Text Assistant
- Get AI-powered suggestions for QR code content
- Smart text formatting
- Offline fallback suggestions when API is unavailable
- Support for business cards, events, contacts, and more

### 📚 History & Favorites
- Store all generated and scanned QR codes locally
- Mark favorites for quick access
- Search and filter history
- Delete individual items or clear all history
- Separate tabs for All and Favorites

### 🎨 Modern UI Design
- Material 3 design principles
- Glassmorphism effects
- Smooth animations and transitions
- Dark/Light theme support
- Gradient-based color schemes
- Responsive layout for phones and tablets

### ⚙️ Settings
- Theme toggle (Light/Dark mode)
- Clear history option
- App version information
- Privacy policy
- About section

### 💰 Monetization Ready
- AdMob integration placeholder (disabled by default)
- Easy activation when ready
- Banner and interstitial ad support

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** (3.24 or higher)
  ```bash
  flutter --version
  ```
- **Dart SDK** (3.0 or higher)
- **Android Studio** or **VS Code** with Flutter extensions
- **Android SDK** (API level 21 or higher)
- **Kotlin** (for Android builds)

## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/NadeeraSilvaa/SmartQR.git
cd NewApp
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure Android

The Android configuration is already set up. The app ID is `com.smartqrplus.app`. To change it, edit:
- `android/app/build.gradle` - Update `applicationId`
- `android/app/src/main/AndroidManifest.xml` - Update package name

### 4. Run the App

```bash
# For debug mode
flutter run

# For release mode
flutter run --release
```

## 🏗️ Build Instructions

### Android APK

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# App Bundle (for Play Store)
flutter build appbundle --release
```

### Android App Bundle (AAB) for Play Store

```bash
flutter build appbundle --release
```

The generated AAB file will be located at:
```
build/app/outputs/bundle/release/app-release.aab
```

## 📦 Project Structure

```
lib/
├── main.dart                 # App entry point
├── app.dart                  # App initialization & splash screen
├── models/                   # Data models
│   └── qr_history_model.dart
├── providers/                # State management
│   └── theme_provider.dart
├── screens/                  # App screens
│   ├── home/
│   │   └── home_screen.dart
│   ├── generator/
│   │   ├── generator_screen.dart
│   │   └── widgets/
│   │       ├── ai_assistant_dialog.dart
│   │       └── customization_panel.dart
│   ├── scanner/
│   │   └── scanner_screen.dart
│   ├── history/
│   │   └── history_screen.dart
│   ├── settings/
│   │   └── settings_screen.dart
│   └── onboarding/
│       └── onboarding_screen.dart
├── services/                 # Business logic
│   ├── storage_service.dart
│   └── ai_service.dart
├── utils/                    # Utilities
│   └── app_colors.dart
└── widgets/                  # Reusable widgets
    └── admob_banner_widget.dart
```

## 🔧 Configuration

### AI Assistant Setup

To enable AI features with OpenAI:

1. Get your OpenAI API key from [OpenAI Platform](https://platform.openai.com/)
2. Open `lib/services/ai_service.dart`
3. Replace the empty `_apiKey` constant:
   ```dart
   static const String _apiKey = 'your-api-key-here';
   ```

**Note:** The app works offline with fallback suggestions if no API key is provided.

### AdMob Setup

To enable Google AdMob monetization:

1. Create an AdMob account at [Google AdMob](https://admob.google.com/)
2. Create an app and get your App ID and Ad Unit IDs
3. Update `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <meta-data
       android:name="com.google.android.gms.ads.APPLICATION_ID"
       android:value="ca-app-pub-XXXXXXXXXXXXXXXX~XXXXXXXXXX"/>
   ```
4. Uncomment AdMob code in `lib/widgets/admob_banner_widget.dart`
5. Replace test IDs with your actual Ad Unit IDs

### App Icon & Splash Screen

1. **App Icon:**
   - Generate app icons using [Flutter Launcher Icons](https://pub.dev/packages/flutter_launcher_icons)
   - Or manually replace icons in `android/app/src/main/res/mipmap-*/`

2. **Splash Screen:**
   - The splash screen is implemented in `lib/app.dart`
   - Customize colors and logo in the `SplashScreen` widget

## 📱 Permissions

The app requires the following permissions:

- **Internet** - For AI features and URL launching
- **Camera** - For QR code scanning
- **Storage** - For saving QR code images
- **Network State** - For connectivity checks

All permissions are declared in `android/app/src/main/AndroidManifest.xml`.

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/your_test_file.dart
```

## 📝 Play Store Checklist

Before publishing to Google Play Store:

- [ ] Update app version in `pubspec.yaml`
- [ ] Replace placeholder app icon with actual design
- [ ] Update AdMob App ID in `AndroidManifest.xml` (if using ads)
- [ ] Add your OpenAI API key (optional)
- [ ] Update privacy policy URL in Settings screen
- [ ] Test on multiple devices and screen sizes
- [ ] Generate signed release bundle: `flutter build appbundle --release`
- [ ] Prepare screenshots and app description
- [ ] Review Google Play Console requirements

## 🛠️ Troubleshooting

### Common Issues

**Issue: Hive adapter registration error**
- Solution: Make sure `QRHistoryModelAdapter` is registered before opening boxes in `main.dart`

**Issue: Camera permission denied**
- Solution: Ensure `CAMERA` permission is declared in `AndroidManifest.xml` and request runtime permission on Android 6.0+

**Issue: Build errors**
- Solution: Run `flutter clean` and `flutter pub get`

**Issue: QR code not generating**
- Solution: Ensure input text is not empty and `qr_flutter` package is properly installed

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- **Flutter Team** - For the amazing framework
- **Package Maintainers** - For the excellent packages used in this project
- **Material Design** - For design guidelines

## 📞 Support

For issues, questions, or contributions:
- Open an issue on [GitHub](https://github.com/NadeeraSilvaa/SmartQR/issues)
- Contact: nadeerasilva01@gmail.com

## 🚀 Future Enhancements

- [ ] iOS support
- [ ] QR code batch generation
- [ ] QR code templates
- [ ] Cloud sync
- [ ] Widget support
- [ ] More QR code formats (vCard, calendar events, etc.)

---

Made with ❤️ using Flutter

