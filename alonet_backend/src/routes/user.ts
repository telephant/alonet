import { Router } from 'express';
import { userController } from '../controllers/userController';
import { authenticate } from '../middleware/auth';

export const userRouter: Router = Router();

// All user routes require authentication
userRouter.use(authenticate);

// Get current user profile
userRouter.get('/profile', userController.getProfile);

// Update user profile
userRouter.put('/profile', userController.updateProfile);

// Upload user avatar
userRouter.post('/avatar', userController.uploadAvatar);

// Delete user account
userRouter.delete('/account', userController.deleteAccount);
