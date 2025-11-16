import express, { Application } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import compression from 'compression';
import { config } from './config/app';
import { errorHandler } from './middleware/errorHandler';
import { notFoundHandler } from './middleware/notFoundHandler';
import { requestLogger } from './middleware/logger';
import { healthRouter } from './routes/health';
import { authRouter } from './routes/auth';
import { userRouter } from './routes/user';
import { router as partnerRouter } from './routes/partnerRoutes';
import { router as momentRouter } from './routes/momentRoutes';
import { router as realtimeRouter } from './routes/realtimeRoutes';

// Create Express application
export const createApp = (): Application => {
  const app = express();

  // Security middleware
  app.use(helmet());
  app.use(cors(config.cors));

  // Request parsing middleware
  app.use(express.json());
  app.use(express.urlencoded({ extended: true }));
  app.use(compression());

  // Logging middleware
  if (config.isDevelopment) {
    // Use our custom logger in development for better visibility
    app.use(requestLogger);
  } else {
    app.use(morgan('combined'));
  }

  // Routes
  app.use('/api/health', healthRouter);
  app.use('/api/auth', authRouter);
  app.use('/api/users', userRouter);
  app.use('/api/partners', partnerRouter);
  app.use('/api/moments', momentRouter);
  app.use('/api/realtime', realtimeRouter);

  // Error handling
  app.use(notFoundHandler);
  app.use(errorHandler);

  return app;
};