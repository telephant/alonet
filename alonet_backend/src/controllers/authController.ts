import { Request, Response } from 'express';
import { supabase } from '../config/supabase';
import { googleAuthService } from '../services/googleAuth';

export const authController = {
  // Sign up new user
  signUp: async (req: Request, res: Response): Promise<void> => {
    try {
      const { email, password, fullName } = req.body;

      const { data, error } = await supabase.auth.signUp({
        email,
        password,
        options: {
          data: {
            full_name: fullName,
          },
        },
      });

      if (error) {
        res.status(400).json({ error: { message: error.message } });
        return;
      }

      res.status(201).json({
        message: 'User created successfully',
        user: data.user,
        session: data.session,
      });
    } catch {
      res.status(500).json({ error: { message: 'Internal server error' } });
    }
  },

  // Sign in user
  signIn: async (req: Request, res: Response): Promise<void> => {
    try {
      const { email, password } = req.body;

      const { data, error } = await supabase.auth.signInWithPassword({
        email,
        password,
      });

      if (error) {
        res.status(401).json({ error: { message: 'Invalid credentials' } });
        return;
      }

      res.json({
        message: 'Sign in successful',
        user: data.user,
        session: data.session,
      });
    } catch {
      res.status(500).json({ error: { message: 'Internal server error' } });
    }
  },

  // Sign out user
  signOut: async (_req: Request, res: Response): Promise<void> => {
    try {
      const { error } = await supabase.auth.signOut();

      if (error) {
        res.status(400).json({ error: { message: error.message } });
        return;
      }

      res.json({ message: 'Sign out successful' });
    } catch {
      res.status(500).json({ error: { message: 'Internal server error' } });
    }
  },

  // Refresh access token
  refreshToken: async (req: Request, res: Response): Promise<void> => {
    try {
      const { refreshToken } = req.body;

      if (!refreshToken) {
        res.status(400).json({ error: { message: 'Refresh token required' } });
        return;
      }

      const { data, error } = await supabase.auth.refreshSession({
        refresh_token: refreshToken,
      });

      if (error) {
        res.status(401).json({ error: { message: 'Invalid refresh token' } });
        return;
      }

      res.json({
        message: 'Token refreshed successfully',
        session: data.session,
      });
    } catch {
      res.status(500).json({ error: { message: 'Internal server error' } });
    }
  },

  // Request password reset
  forgotPassword: async (req: Request, res: Response): Promise<void> => {
    try {
      const { email } = req.body;

      const { error } = await supabase.auth.resetPasswordForEmail(email, {
        redirectTo: `${process.env.APP_URL}/reset-password`,
      });

      if (error) {
        res.status(400).json({ error: { message: error.message } });
        return;
      }

      res.json({ message: 'Password reset email sent' });
    } catch {
      res.status(500).json({ error: { message: 'Internal server error' } });
    }
  },

  // Reset password
  resetPassword: async (req: Request, res: Response): Promise<void> => {
    try {
      const { password } = req.body;
      const token = req.headers.authorization?.replace('Bearer ', '');

      if (!token) {
        res.status(400).json({ error: { message: 'Token required' } });
        return;
      }

      const { error } = await supabase.auth.updateUser({
        password,
      });

      if (error) {
        res.status(400).json({ error: { message: error.message } });
        return;
      }

      res.json({ message: 'Password reset successful' });
    } catch {
      res.status(500).json({ error: { message: 'Internal server error' } });
    }
  },

  // Google OAuth sign-in for mobile
  googleSignIn: async (req: Request, res: Response): Promise<void> => {
    try {
      const { idToken, flow } = req.body;

      // Handle different OAuth flows
      if (flow === 'url') {
        // Return OAuth URL for mobile app to handle
        const { data, error } = await supabase.auth.signInWithOAuth({
          provider: 'google',
          options: {
            queryParams: {
              access_type: 'offline',
              prompt: 'consent',
            },
            redirectTo: `${process.env.API_URL}/auth/google/callback`,
            skipBrowserRedirect: true,
          },
        });

        if (error) {
          console.error('Supabase OAuth error:', error);
          res.status(500).json({ 
            error: { message: 'Failed to initiate Google OAuth flow' } 
          });
          return;
        }

        res.json({
          message: 'Google OAuth URL generated',
          auth_url: data.url,
          provider: 'google',
        });
        return;
      }

      // Default flow: Handle ID token from mobile app
      if (!idToken) {
        res.status(400).json({ error: { message: 'Google ID token is required' } });
        return;
      }

      // Verify Google ID token
      const googleUser = await googleAuthService.verifyIdToken(idToken);
      if (!googleUser || !googleUser.email_verified) {
        res.status(401).json({
          error: { message: 'Invalid Google token or email not verified' },
        });
        return;
      }

      // Simplified mobile OAuth approach:
      // 1. Verify Google ID token (already done above)
      // 2. Create or find user in your own system  
      // 3. Return user info and let mobile app handle session
      
      // For mobile apps, we often don't need full Supabase auth session
      // Instead, return user data and let mobile app create local session
      
      const userData = {
        id: `google_${googleUser.sub}`, // Use Google's user ID
        email: googleUser.email,
        name: googleUser.name,
        picture: googleUser.picture,
        provider: 'google',
        email_verified: googleUser.email_verified,
        google_id: googleUser.sub,
      };

      // Optional: Store user in your database (profiles table)
      try {
        await supabase
          .from('profiles')
          .upsert({
            id: userData.id,
            email: userData.email,
            full_name: userData.name,
            avatar_url: userData.picture,
            provider: 'google',
            google_id: googleUser.sub,
            updated_at: new Date().toISOString(),
          });
      } catch (dbError) {
        console.log('Database upsert warning (table might not exist):', dbError);
        // Continue anyway - profile storage is optional
      }

      const data = {
        user: userData,
        session: {
          // Create a custom session token or use JWT
          access_token: `mobile_google_${Date.now()}`, // In production, use proper JWT
          expires_at: Date.now() + (24 * 60 * 60 * 1000), // 24 hours
          provider: 'google',
        },
      };

      res.json({
        message: 'Google sign-in successful',
        user: data.user,
        session: data.session,
        user_metadata: {
          provider: 'google',
          name: googleUser.name,
          picture: googleUser.picture,
          email: googleUser.email,
        },
      });

    } catch (error) {
      console.error('Google sign-in error:', error);
      res.status(500).json({ error: { message: 'Internal server error' } });
    }
  },

  // Google OAuth callback for web (future use)
  googleCallback: async (req: Request, res: Response): Promise<void> => {
    try {
      const { code } = req.query;

      if (!code || typeof code !== 'string') {
        res
          .status(400)
          .json({ error: { message: 'Authorization code required' } });
        return;
      }

      const redirectUri = `${process.env.API_URL}/auth/google/callback`;
      const googleUser = await googleAuthService.exchangeCodeForTokens(
        code,
        redirectUri
      );

      if (!googleUser) {
        res
          .status(401)
          .json({ error: { message: 'Invalid authorization code' } });
        return;
      }

      // Handle the OAuth flow similar to mobile, but redirect to frontend
      const frontendUrl = process.env.FRONTEND_URL || 'http://localhost:3000';
      res.redirect(`${frontendUrl}/auth/callback?success=true`);
    } catch (error) {
      console.error('Google callback error:', error);
      const frontendUrl = process.env.FRONTEND_URL || 'http://localhost:3000';
      res.redirect(`${frontendUrl}/auth/callback?error=oauth_failed`);
    }
  },
};
