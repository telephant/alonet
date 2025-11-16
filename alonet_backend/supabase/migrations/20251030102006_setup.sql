-- ============================================================================
-- Complete Supabase Database Setup for OpenThis Backend
-- Run this entire script in Supabase SQL Editor or via `supabase db push`
-- ============================================================================

-- ============================================================================
-- STEP 1: Create profiles table and basic setup
-- ============================================================================

CREATE TABLE profiles (
  id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
  full_name TEXT,
  bio TEXT,
  phone_number TEXT,
  avatar_url TEXT,
  provider TEXT DEFAULT 'email',
  provider_id TEXT,
  avatar_url_external TEXT,
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

-- ============================================================================
-- STEP 2: Create functions and triggers
-- ============================================================================

-- Function to handle new user creation (with OAuth support)
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (
    id, 
    full_name, 
    provider,
    provider_id,
    avatar_url_external
  )
  VALUES (
    new.id, 
    COALESCE(
      new.raw_user_meta_data->>'full_name',
      new.raw_user_meta_data->>'name',
      split_part(new.email, '@', 1)
    ),
    COALESCE(new.raw_app_meta_data->>'provider', 'email'),
    new.raw_app_meta_data->>'sub',
    new.raw_user_meta_data->>'avatar_url'
  );
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger for new user creation
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Function to auto-update updated_at column
CREATE OR REPLACE FUNCTION public.set_current_timestamp_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = TIMEZONE('utc'::text, NOW());
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to update updated_at automatically
CREATE TRIGGER set_profiles_updated_at
  BEFORE UPDATE ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION set_current_timestamp_updated_at();

-- ============================================================================
-- STEP 3: Create indexes and constraints for OAuth
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_profiles_provider ON profiles(provider);
CREATE INDEX IF NOT EXISTS idx_profiles_provider_id ON profiles(provider, provider_id);

ALTER TABLE profiles 
ADD CONSTRAINT profiles_provider_id_unique 
UNIQUE (provider, provider_id);

-- ============================================================================
-- STEP 4: Create OAuth users view
-- ============================================================================

CREATE OR REPLACE VIEW oauth_users AS
SELECT 
  p.*,
  u.email,
  u.created_at AS auth_created_at,
  u.last_sign_in_at,
  CASE 
    WHEN p.provider = 'email' THEN false 
    ELSE true 
  END AS is_oauth_user
FROM profiles p
JOIN auth.users u ON p.id = u.id;

GRANT SELECT ON oauth_users TO authenticated;

-- ============================================================================
-- STEP 5: Create health check table
-- ============================================================================

CREATE TABLE _health_check (
  id SERIAL PRIMARY KEY,
  status TEXT DEFAULT 'healthy',
  checked_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

INSERT INTO _health_check (status) VALUES ('healthy');

-- ============================================================================
-- STEP 6: Create avatar storage bucket and policies
-- ============================================================================

-- Create avatars bucket if not exists
INSERT INTO storage.buckets (id, name, public)
VALUES ('avatars', 'avatars', true)
ON CONFLICT (id) DO NOTHING;

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

-- ============================================================================
-- Setup Complete! 
-- Your backend should now work with all required tables and functions.
-- ============================================================================
