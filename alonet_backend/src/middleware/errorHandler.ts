import { Request, Response, NextFunction } from 'express';
import { config } from '../config/app';

export interface CustomError extends Error {
  statusCode?: number;
  isOperational?: boolean;
}

export const errorHandler = (
  err: CustomError,
  req: Request,
  res: Response,
  _next: NextFunction
): void => {
  const statusCode = err.statusCode || 500;
  const message = err.message || 'Internal Server Error';

  // Log error
  // eslint-disable-next-line no-console
  console.error({
    error: {
      message: err.message,
      stack: err.stack,
      statusCode,
    },
    request: {
      method: req.method,
      url: req.url,
      params: req.params,
      query: req.query,
    },
  });

  // Send error response
  res.status(statusCode).json({
    error: {
      message,
      ...(config.isDevelopment && { stack: err.stack }),
    },
  });
};
