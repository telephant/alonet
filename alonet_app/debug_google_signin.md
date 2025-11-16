# Google Sign-In Debug Guide

## Changes Made to Fix the Crash

### 1. **Updated iOS Configuration** ✅
- **Fixed**: `ios/Runner/GoogleService-Info.plist` with correct CLIENT_ID: `921607312077-stvu569k9fh4abmoj7f523mejqr62spq.apps.googleusercontent.com`
- **Fixed**: `ios/Runner/Info.plist` URL scheme with correct REVERSED_CLIENT_ID

### 2. **Updated Android Configuration** ✅
- **Fixed**: `android/app/google-services.json` with correct client_id in oauth_client sections

### 3. **Enhanced Error Handling** ✅
- **Added**: Detailed debug logging throughout the sign-in process
- **Added**: Specific error handling for PlatformException and network errors
- **Added**: Stack trace logging for better debugging

## Testing Steps

### 1. Run with Debug Logging
```bash
# Clean and rebuild
flutter clean
flutter pub get

# Run with debug output
flutter run --debug --verbose
```

### 2. Monitor Debug Output
When you tap the "Continue with Google" button, look for these debug messages:
- `🚀 Starting Google Sign-In process...`
- `🚀 About to call _googleSignIn.signIn()...`
- `🚀 ===== googleAccount: [account info]`

### 3. Check for Common Issues

**If you see "PlatformException":**
- This usually means configuration mismatch
- Verify bundle ID matches between Xcode project and GoogleService-Info.plist
- Ensure certificate hash matches (for Android)

**If you see "network" errors:**
- Check internet connection
- Verify Google OAuth credentials are valid and enabled

**If the app still crashes:**
- Look at the full crash log in Xcode or Android Studio
- Check if Google Play Services are available (Android)

### 4. Verify Configuration

**iOS Bundle ID Check:**
- Xcode project: `com.example.alonetApp`
- GoogleService-Info.plist: `com.example.alonetApp` ✅

**Android Package Name Check:**
- build.gradle.kts: `com.example.alonet_app`
- google-services.json: `com.example.alonet_app` ✅

## Expected Behavior After Fix

1. **Before**: App crashes immediately when tapping Google Sign-In
2. **After**: App shows Google Sign-In dialog or proper error message (not crash)

## If Still Crashing

1. **Check iOS Simulator/Device Logs:**
```bash
# For iOS Simulator
xcrun simctl spawn booted log show --predicate 'process == "Runner"' --info --debug
```

2. **Check Android Logs:**
```bash
flutter logs
# or
adb logcat | grep flutter
```

3. **Test with Minimal Code:**
The current implementation returns `false` after successful sign-in to isolate the Google Sign-In process from backend calls.

4. **Common Configuration Issues:**
- Certificate hash mismatch (Android)
- Bundle ID mismatch (iOS)
- Client ID not enabled for the platform
- Google Services not properly configured

## Next Steps if Working

Once Google Sign-In works without crashing:
1. Uncomment the authentication token retrieval code
2. Test the backend integration
3. Handle the full OAuth flow

The configuration should now match your client ID across all platforms. Try running the app and let me know what debug messages you see!