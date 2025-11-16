# Google OAuth Setup Guide

This guide explains how to set up Google OAuth authentication for both the backend API and Flutter mobile app.

## Prerequisites

- Google Cloud Console account
- Supabase project with authentication enabled
- Backend API running on Node.js/Express
- Flutter mobile app

## 1. Google Cloud Console Setup

### Create OAuth 2.0 Credentials

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select an existing one
3. Enable the **Google+ API** and **Google Identity API**
4. Navigate to **APIs & Services** > **Credentials**
5. Click **Create Credentials** > **OAuth 2.0 Client IDs**

### Configure OAuth Consent Screen

1. Go to **OAuth consent screen**
2. Choose **External** for user type
3. Fill in required fields:
   - App name: `OpenThis App`
   - User support email: your email
   - Developer contact information: your email
4. Add scopes: `email`, `profile`
5. Save and continue

### Create Credentials

Create **three** OAuth 2.0 client IDs:

#### 1. Web Application (for Backend)
- Application type: **Web application**
- Name: `OpenThis Backend`
- Authorized redirect URIs: `http://localhost:3000/api/auth/google/callback`
- Save the **Client ID** and **Client Secret**

#### 2. Android Application
- Application type: **Android**
- Name: `OpenThis Android`
- Package name: `com.example.openthis_app` (or your actual package name)
- SHA-1 certificate fingerprint: 
  - For debug: Run `keytool -keystore ~/.android/debug.keystore -list -v`
  - Use the SHA1 fingerprint from the output

#### 3. iOS Application
- Application type: **iOS**
- Name: `OpenThis iOS`
- Bundle ID: `com.example.openthisApp` (or your actual bundle ID)

## 2. Backend Configuration

### Environment Variables

Add to your `.env` file:

```env
# Google OAuth Configuration
GOOGLE_CLIENT_ID=your-web-client-id-here
GOOGLE_CLIENT_SECRET=your-client-secret-here

# Application URLs
API_URL=http://localhost:3000
FRONTEND_URL=http://localhost:3000
APP_URL=http://localhost:3000
```

### Database Migration

Run the OAuth migration to extend your database schema:

```bash
# Apply the database migration in Supabase SQL Editor
# Copy and paste the contents of docs/OAUTH_MIGRATION.sql
```

### Install Dependencies

The backend already includes the necessary dependency:

```bash
pnpm install google-auth-library
```

## 3. Flutter App Configuration

### Dependencies

Add to `pubspec.yaml`:

```yaml
dependencies:
  google_sign_in: ^6.2.2
  http: ^1.2.2
  flutter_secure_storage: ^9.2.2
  provider: ^6.1.2
```

### Android Configuration

1. Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<application>
    <!-- ... other configurations ... -->
    
    <!-- Google Sign-In -->
    <meta-data
        android:name="com.google.android.gms.version"
        android:value="@integer/google_play_services_version" />
</application>
```

2. Create `android/app/google-services.json`:
   - Download from Google Cloud Console > Your Android App > Download Config
   - Place in `android/app/` directory

### iOS Configuration

1. Create `ios/Runner/GoogleService-Info.plist`:
   - Download from Google Cloud Console > Your iOS App > Download Config
   - Add to Xcode project in `Runner` folder

2. Add to `ios/Runner/Info.plist`:

```xml
<dict>
    <!-- ... other configurations ... -->
    
    <!-- Google Sign-In -->
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleURLName</key>
            <string>REVERSE_CLIENT_ID</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>YOUR_REVERSE_CLIENT_ID_HERE</string>
            </array>
        </dict>
    </array>
</dict>
```

Replace `YOUR_REVERSE_CLIENT_ID_HERE` with the `REVERSED_CLIENT_ID` from `GoogleService-Info.plist`.

## 4. Testing the Implementation

### Backend Testing

1. Start the backend server:
```bash
cd openthis_backend
npm run dev
```

2. Test the Google OAuth endpoint:
```bash
curl -X POST http://localhost:3000/api/auth/google \
  -H "Content-Type: application/json" \
  -d '{"idToken": "test-token-from-google"}'
```

### Flutter Testing

1. Run the Flutter app:
```bash
cd openthis_app
flutter run
```

2. Test the authentication flow:
   - Tap "Continue with Google"
   - Complete Google sign-in
   - Verify user profile displays correctly

### End-to-End Testing

1. Sign in with Google on mobile
2. Verify user is created in Supabase
3. Check that profile data includes OAuth provider information
4. Test sign-out functionality
5. Test existing email/password authentication still works

## 5. Production Considerations

### Security

1. **Environment Variables**: Use secure environment variable management
2. **HTTPS**: Enable HTTPS for all OAuth redirects in production
3. **Domain Verification**: Update redirect URIs for production domains
4. **Token Storage**: Flutter app uses secure storage for tokens

### Supabase Configuration

1. **Auth Providers**: Enable Google OAuth in Supabase dashboard:
   - Go to Authentication > Providers
   - Enable Google provider
   - Add your Google Client ID and Secret

2. **RLS Policies**: The migration includes Row Level Security policies
3. **User Metadata**: OAuth users will have provider information in metadata

### Production URLs

Update environment variables for production:

```env
# Production URLs
API_URL=https://api.yourapp.com
FRONTEND_URL=https://yourapp.com
APP_URL=https://yourapp.com

# Google OAuth redirect URIs in production
# https://api.yourapp.com/auth/google/callback
```

## 6. Troubleshooting

### Common Issues

1. **"Invalid Client ID"**: Check Google Cloud Console credentials
2. **"Redirect URI mismatch"**: Verify redirect URIs in Google Console
3. **"Package name mismatch"**: Ensure Android package name matches
4. **"Bundle ID mismatch"**: Ensure iOS bundle ID matches
5. **"Invalid SHA1"**: Verify Android SHA1 certificate fingerprint

### Debug Steps

1. Check backend logs for OAuth errors
2. Verify Google Console configuration
3. Test with simple OAuth flow first
4. Check Supabase auth logs
5. Verify database schema was properly updated

### Support

- Google OAuth documentation: https://developers.google.com/identity/protocols/oauth2
- Supabase Auth documentation: https://supabase.com/docs/guides/auth
- Flutter Google Sign-In: https://pub.dev/packages/google_sign_in