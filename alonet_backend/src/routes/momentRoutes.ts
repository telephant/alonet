import { Router } from 'express';
import { authenticate } from '../middleware/auth';
import {
  createMoment,
  getMoments,
  getMomentsForDate,
  updateMoment,
  deleteMoment,
  reactToMoment,
  getMomentStats
} from '../controllers/momentController';

export const router: Router = Router();

// All moment routes require authentication
router.use(authenticate);

// Create a new moment
router.post('/', createMoment);

// Get moments with optional filters
router.get('/', getMoments);

// Get moments for a specific date
router.get('/date/:date', getMomentsForDate);

// Get moment statistics
router.get('/stats', getMomentStats);

// Update a specific moment
router.put('/:momentId', updateMoment);

// Delete a specific moment
router.delete('/:momentId', deleteMoment);

// React to a moment
router.patch('/:momentId/react', reactToMoment);

export default router;