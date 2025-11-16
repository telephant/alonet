import { Response, NextFunction } from 'express';
import { supabase } from '../config/supabase';
import { AuthenticatedUser, OptionalAuthRequest } from '../types/auth';

// Re-export types for convenience
export { AuthenticatedRequest, OptionalAuthRequest, AuthenticatedUser } from '../types/auth';

export const authenticate = async (
  req: OptionalAuthRequest,
  res: Response,
  next: NextFunction
): Promise<void> => {
  try {
    const token = req.headers.authorization?.replace('Bearer ', '');

    if (!token) {
      res.status(401).json({ error: { message: 'No token provided' } });
      return;
    }

    // Verify token with Supabase
    const {
      data: { user },
      error,
    } = await supabase.auth.getUser(token);

    if (error || !user) {
      res.status(401).json({ error: { message: 'Invalid token' } });
      return;
    }

    // Attach user to request with proper typing
    req.user = user as AuthenticatedUser;
    next();
  } catch {
    res.status(500).json({ error: { message: 'Authentication error' } });
  }
};
