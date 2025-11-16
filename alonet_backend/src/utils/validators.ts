import { Request, Response, NextFunction } from 'express';

// Email validation regex
const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

// Password validation (min 8 chars, at least one letter and one number)
const PASSWORD_REGEX = /^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d@$!%*?&]{8,}$/;

export const validateSignUp = (
  req: Request,
  res: Response,
  next: NextFunction
): void => {
  const { email, password, fullName } = req.body;

  const errors: string[] = [];

  if (!email || !EMAIL_REGEX.test(email)) {
    errors.push('Valid email is required');
  }

  if (!password || !PASSWORD_REGEX.test(password)) {
    errors.push(
      'Password must be at least 8 characters with letters and numbers'
    );
  }

  if (!fullName || fullName.trim().length < 2) {
    errors.push('Full name must be at least 2 characters');
  }

  if (errors.length > 0) {
    res.status(400).json({ error: { message: errors.join(', ') } });
    return;
  }

  next();
};

export const validateSignIn = (
  req: Request,
  res: Response,
  next: NextFunction
): void => {
  const { email, password } = req.body;

  const errors: string[] = [];

  if (!email || !EMAIL_REGEX.test(email)) {
    errors.push('Valid email is required');
  }

  if (!password) {
    errors.push('Password is required');
  }

  if (errors.length > 0) {
    res.status(400).json({ error: { message: errors.join(', ') } });
    return;
  }

  next();
};

export const validateGoogleSignIn = (
  req: Request,
  res: Response,
  next: NextFunction
): void => {
  const { idToken } = req.body;

  if (!idToken || typeof idToken !== 'string') {
    res.status(400).json({ error: { message: 'Google ID token is required' } });
    return;
  }

  next();
};
