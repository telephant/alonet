import { Request } from 'express';
import { User } from '@supabase/supabase-js';

/**
 * Auth-related type definitions
 */

/**
 * Authenticated user type from Supabase
 */
export interface AuthenticatedUser extends User {
  id: string;
  email?: string;
}

/**
 * Request type for authenticated routes
 * Uses intersection type for better Express compatibility
 */
export type AuthenticatedRequest = Request & {
  user: AuthenticatedUser;
};

/**
 * Optional authenticated request (for routes that may or may not require auth)
 */
export type OptionalAuthRequest = Request & {
  user?: AuthenticatedUser;
};