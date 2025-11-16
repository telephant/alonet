import { Router } from 'express';
import { authenticate } from '../middleware/auth';
import {
  getRealtimeStatus,
  getRealtimeStats
} from '../controllers/realtimeController';

export const router: Router = Router();

// Get current user's real-time connection status
router.get('/status', authenticate, getRealtimeStatus);

// Get overall real-time server statistics
router.get('/stats', getRealtimeStats);

export default router;