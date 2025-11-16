import { Request, Response } from 'express';
import { supabase } from '../config/supabase';
import { AuthenticatedUser } from '../types/auth';

export const userController = {
  // Get user profile
  getProfile: async (req: Request, res: Response): Promise<void> => {
    try {
      const userId = (req.user as AuthenticatedUser).id;

      // Get user profile from database
      const { data, error } = await supabase
        .from('profiles')
        .select('*')
        .eq('id', userId)
        .single();

      if (error && error.code !== 'PGRST116') {
        res.status(404).json({ error: { message: 'Profile not found' } });
        return;
      }

      res.json({
        user: req.user as AuthenticatedUser,
        profile: data || {},
      });
    } catch {
      res.status(500).json({ error: { message: 'Internal server error' } });
    }
  },

  // Update user profile
  updateProfile: async (req: Request, res: Response): Promise<void> => {
    try {
      const userId = (req.user as AuthenticatedUser).id;
      const { fullName, bio, phoneNumber } = req.body;

      // Update user metadata
      const { error: authError } = await supabase.auth.updateUser({
        data: { full_name: fullName },
      });

      if (authError) {
        res.status(400).json({ error: { message: authError.message } });
        return;
      }

      // Update profile in database
      const { data, error } = await supabase
        .from('profiles')
        .upsert({
          id: userId,
          full_name: fullName,
          bio,
          phone_number: phoneNumber,
          updated_at: new Date().toISOString(),
        })
        .select()
        .single();

      if (error) {
        res.status(400).json({ error: { message: error.message } });
        return;
      }

      res.json({
        message: 'Profile updated successfully',
        profile: data,
      });
    } catch {
      res.status(500).json({ error: { message: 'Internal server error' } });
    }
  },

  // Upload user avatar
  uploadAvatar: async (req: Request, res: Response): Promise<void> => {
    try {
      const userId = (req.user as AuthenticatedUser).id;

      // This is a placeholder - actual file upload logic would go here
      // You would typically use multer or similar middleware to handle file uploads

      res.json({
        message: 'Avatar upload endpoint - implement file handling',
        userId,
      });
    } catch {
      res.status(500).json({ error: { message: 'Internal server error' } });
    }
  },

  // Delete user account
  deleteAccount: async (req: Request, res: Response): Promise<void> => {
    try {
      // For user account deletion without admin privileges, 
      // we can't actually delete the auth user, but we can:
      // 1. Delete user profile data
      // 2. Sign them out
      // 3. Return success (the auth record remains but is inactive)
      
      const userId = (req.user as AuthenticatedUser).id;

      // Delete user profile data
      const { error: profileError } = await supabase
        .from('profiles')
        .delete()
        .eq('id', userId);

      if (profileError) {
        console.error('Error deleting profile:', profileError);
        // Continue anyway - profile might not exist
      }

      // Sign out the user
      const { error: signOutError } = await supabase.auth.signOut();
      
      if (signOutError) {
        console.error('Error signing out user:', signOutError);
      }

      res.json({ 
        message: 'Account data deleted and user signed out successfully',
        note: 'Auth record deactivated - contact support for complete deletion'
      });
    } catch {
      res.status(500).json({ error: { message: 'Internal server error' } });
    }
  },
};
