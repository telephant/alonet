# Supabase Integration Guide

## Overview

This project uses Supabase for:
- Authentication
- PostgreSQL Database
- File Storage
- Real-time subscriptions (future feature)

## Setup

### 1. Create a Supabase Project
1. Go to [Supabase](https://supabase.com)
2. Create a new project
3. Save your project URL and keys

### 2. Database Schema

Run these SQL commands in the Supabase SQL editor:

```sql
-- Create profiles table
CREATE TABLE profiles (
  id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
  full_name TEXT,
  bio TEXT,
  phone_number TEXT,
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- Enable Row Level Security (RLS)
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Create function to handle new user creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name)
  VALUES (new.id, new.raw_user_meta_data->>'full_name');
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger for new user creation
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Create updated_at trigger
CREATE OR REPLACE FUNCTION public.set_current_timestamp_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = TIMEZONE('utc'::text, NOW());
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION set_current_timestamp_updated_at();
```

### 3. Storage Buckets

Create storage buckets for user avatars:

```sql
-- Create avatars bucket
INSERT INTO storage.buckets (id, name, public)
VALUES ('avatars', 'avatars', true);

-- Create storage policies
CREATE POLICY "Avatar images are publicly accessible"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'avatars');

CREATE POLICY "Users can upload own avatar"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Users can update own avatar"
  ON storage.objects FOR UPDATE
  USING (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Users can delete own avatar"
  ON storage.objects FOR DELETE
  USING (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);
```

## Environment Variables

```env
# Supabase Configuration
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
```

## Authentication Flow

1. **Sign Up**: Creates user in auth.users and triggers profile creation
2. **Sign In**: Returns JWT tokens for authentication
3. **Token Refresh**: Use refresh token to get new access token
4. **Sign Out**: Invalidates the current session

## Security Best Practices

1. **Never expose service role key**: Only use in server-side code
2. **Use RLS policies**: Always enable Row Level Security
3. **Validate inputs**: Validate all user inputs before database operations
4. **Use prepared statements**: Supabase client handles this automatically

## Common Operations

### Authenticated Requests
```typescript
// Get authenticated user
const { data: { user }, error } = await supabase.auth.getUser(token);

// Database query with auth context
const { data, error } = await supabase
  .from('profiles')
  .select('*')
  .eq('id', user.id)
  .single();
```

### File Upload
```typescript
// Upload avatar
const { data, error } = await supabase.storage
  .from('avatars')
  .upload(`${user.id}/avatar.png`, file, {
    cacheControl: '3600',
    upsert: true
  });
```

### Real-time Subscriptions (Future)
```typescript
// Subscribe to profile changes
const subscription = supabase
  .channel('profile-changes')
  .on('postgres_changes', 
    { event: '*', schema: 'public', table: 'profiles' },
    (payload) => console.log('Change received!', payload)
  )
  .subscribe();
```

## Troubleshooting

### Common Issues

1. **"relation does not exist"**: Ensure all SQL migrations have been run
2. **"JWT expired"**: Implement token refresh logic
3. **"permission denied"**: Check RLS policies
4. **"invalid API key"**: Verify environment variables are set correctly

### Debug Tips

1. Check Supabase dashboard logs
2. Use SQL editor to test queries
3. Verify RLS policies with different user contexts
4. Test API endpoints with Supabase client libraries