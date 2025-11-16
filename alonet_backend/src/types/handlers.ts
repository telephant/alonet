import { Request, Response, RequestHandler } from 'express';
import { AuthenticatedUser } from './auth';

/**
 * Handler type definitions that work with Express Router
 */

/**
 * Authenticated handler type that preserves Express compatibility
 * while providing type safety for authenticated routes
 */
export type AuthenticatedHandler = (
  req: Request & { user: AuthenticatedUser },
  res: Response
) => Promise<Response | void> | Response | void;

/**
 * Convert an authenticated handler to work with Express Router
 */
export const authenticatedHandler = (handler: AuthenticatedHandler): RequestHandler => {
  return async (req: Request, res: Response, next) => {
    try {
      // Type assertion - user is guaranteed to exist by auth middleware
      const authenticatedReq = req as Request & { user: AuthenticatedUser };
      const result = await handler(authenticatedReq, res);
      
      // Only call next if handler didn't send a response
      if (result === undefined && !res.headersSent) {
        next();
      }
    } catch (error) {
      next(error);
    }
  };
};