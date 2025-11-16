import { AuthenticatedUser } from './auth';

/**
 * Express type declarations using module augmentation
 * This extends the Express Request interface without using namespaces
 */
declare module 'express-serve-static-core' {
  interface Request {
    user?: AuthenticatedUser;
  }
}