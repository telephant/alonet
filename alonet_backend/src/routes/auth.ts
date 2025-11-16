import { Router } from 'express';
import { authController } from '../controllers/authController';
import {
  validateSignUp,
  validateSignIn,
  validateGoogleSignIn,
} from '../utils/validators';

export const authRouter: Router = Router();

// Sign up with email and password
authRouter.post('/signup', validateSignUp, authController.signUp);

// Sign in with email and password
authRouter.post('/signin', validateSignIn, authController.signIn);

// Sign out
authRouter.post('/signout', authController.signOut);

// Refresh token
authRouter.post('/refresh', authController.refreshToken);

// Request password reset
authRouter.post('/forgot-password', authController.forgotPassword);

// Reset password
authRouter.post('/reset-password', authController.resetPassword);

// Google OAuth routes
authRouter.post('/google', validateGoogleSignIn, authController.googleSignIn);
authRouter.get('/google/callback', authController.googleCallback);
