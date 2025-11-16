# Google OAuth Environment Setup

## Required Environment Variables

I've added the following Google OAuth configuration to your `.env` file:

```env
# Google OAuth Configuration
GOOGLE_CLIENT_ID=921607312077-stvu569k9fh4abmoj7f523mejqr62spq.apps.googleusercontent.com
GOOGLE_CLIENT_SECRET=your-google-client-secret-here

# Application URLs
API_URL=http://localhost:3000
FRONTEND_URL=http://localhost:3000
APP_URL=http://localhost:3000
```

## ⚠️ Important: Update GOOGLE_CLIENT_SECRET

You need to replace `your-google-client-secret-here` with your actual Google OAuth client secret.

### How to get your Google Client Secret:

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project
3. Navigate to **APIs & Services** > **Credentials**
4. Find your OAuth 2.0 Client ID (the one ending with `...stvu569k9fh4abmoj7f523mejqr62spq`)
5. Click on it to view details
6. Copy the **Client Secret**
7. Replace `your-google-client-secret-here` in the `.env` file

## Testing the Backend

After updating the client secret, run:

```bash
cd /Users/telephant/self/openthis-app/openthis_backend
pnpm run dev
```

The server should start without the `GOOGLE_CLIENT_ID environment variable is required` error.

## Security Notes

1. **Never commit `.env` file to Git** - It should be in `.gitignore`
2. **Keep your client secret secure** - Don't share it publicly
3. **Use different credentials for production** - Create separate OAuth credentials for production

## Backend Environment Variables Summary

Your backend now has:
- ✅ Supabase configuration
- ✅ JWT secret
- ✅ Google OAuth client ID
- ⚠️ Google OAuth client secret (needs real value)
- ✅ Application URLs

Once you add the real client secret, the backend will start successfully!