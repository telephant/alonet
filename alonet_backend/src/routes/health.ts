import { Router } from 'express';
import { healthController } from '../controllers/healthController';

export const healthRouter: Router = Router();

// Health check endpoint
healthRouter.get('/', healthController.checkHealth);

// Detailed health check endpoint
healthRouter.get('/detailed', healthController.checkHealthDetailed);
