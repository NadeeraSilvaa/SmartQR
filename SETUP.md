# Quick Setup Guide 🚀

## Prerequisites Check

1. **Flutter Installation**
   ```bash
   flutter --version
   # Should show Flutter 3.24+ and Dart 3.0+
   ```

2. **Android Setup**
   - Android Studio installed
   - Android SDK (API 21+)
   - Emulator or physical device connected

## Step-by-Step Setup

### 1. Install Dependencies
```bash
cd "/Users/nadeerasilva/Android Projects/NewApp"
flutter pub get
```

### 2. Run the App
```bash
flutter run
```

### 3. Build for Release
```bash
# APK
flutter build apk --release

# App Bundle (for Play Store)
flutter build appbundle --release
```

## Optional Configurations

### Enable AI Features (Optional)
1. Get OpenAI API key from https://platform.openai.com/
2. Edit `lib/services/ai_service.dart`
3. Replace `_apiKey = ''` with your API key

**Note:** App works offline without API key using fallback suggestions.

### Enable AdMob (Optional)
1. Create AdMob account at https://admob.google.com/
2. Get your App ID and Ad Unit IDs
3. Update `android/app/src/main/AndroidManifest.xml`
4. Uncomment AdMob code in `lib/widgets/admob_banner_widget.dart`

## Troubleshooting

### If you see "Package not found" errors:
```bash
flutter clean
flutter pub get
```

### If you see build errors:
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

### If camera doesn't work:
- Check AndroidManifest.xml has CAMERA permission
- Ensure device/emulator has camera access enabled
- Grant camera permission manually in device settings

## First Run

1. App will show splash screen (2 seconds)
2. First-time users see onboarding screens
3. Navigate using bottom navigation bar:
   - **Generate**: Create QR codes
   - **Scan**: Scan QR codes with camera
   - **History**: View all QR codes
   - **Settings**: App settings

## Testing Features

### Generate QR Code
1. Go to Generate tab
2. Enter any text/URL
3. Tap "Generate QR Code"
4. Customize colors and size
5. Save or share QR code

### Scan QR Code
1. Go to Scan tab
2. Point camera at QR code
3. QR code detected automatically
4. View details and take actions

### AI Assistant
1. In Generate tab, tap AI icon (top right)
2. Enter prompt (e.g., "Suggest text for business contact QR")
3. Get AI suggestion
4. Use suggestion to generate QR code

### History
1. All generated/scanned QR codes are saved automatically
2. Tap History tab to view
3. Mark favorites, delete items, or clear all

## App Structure

```
lib/
├── main.dart                    # Entry point
├── app.dart                     # App initialization
├── models/                      # Data models
├── screens/                     # App screens
├── services/                    # Business logic
├── providers/                  # State management
├── utils/                      # Utilities
└── widgets/                    # Reusable widgets
```

## Package Information

- **App ID**: `com.smartqrplus.app`
- **Version**: 1.0.0 (Build 1)
- **Min SDK**: Android 21 (Lollipop)
- **Target SDK**: Android 34

## Next Steps

1. Customize app icon (replace in `android/app/src/main/res/mipmap-*/`)
2. Add your OpenAI API key (optional)
3. Configure AdMob (optional)
4. Test on multiple devices
5. Build release bundle for Play Store

For detailed information, see [README.md](README.md)

