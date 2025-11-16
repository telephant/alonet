import { AuthenticatedUser } from '../../src/types/auth';

export const mockUser: AuthenticatedUser = {
  id: 'test-user-id-123',
  email: 'test@example.com',
  fullName: 'Test User',
  avatarUrl: null,
  timezone: 'Asia/Dubai'
};

export const mockPartnerUser: AuthenticatedUser = {
  id: 'partner-user-id-456',
  email: 'partner@example.com', 
  fullName: 'Partner User',
  avatarUrl: null,
  timezone: 'Europe/London'
};

// Mock JWT tokens for testing
export const mockToken = 'mock-jwt-token-for-testing';
export const mockInvalidToken = 'invalid-mock-token';

// Mock middleware function that sets req.user
export const mockAuthMiddleware = (user: AuthenticatedUser = mockUser) => {
  return (req: any, res: any, next: any) => {
    req.user = user;
    next();
  };
};

// Mock auth middleware that simulates authentication failure
export const mockAuthFailureMiddleware = (errorMessage: string = 'No token provided') => {
  return (req: any, res: any, next: any) => {
    res.status(401).json({ error: { message: errorMessage } });
  };
};