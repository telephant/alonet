import { Router } from 'express';
import { authenticate } from '../middleware/auth';
import {
  sendInvitation,
  acceptInvitation,
  getCurrentPartner,
  removePartner,
  getPendingInvitations,
  cancelInvitation
} from '../controllers/partnerController';

export const router: Router = Router();

// All partner routes require authentication
router.use(authenticate);

// Send a new partner invitation
router.post('/invite', sendInvitation);

// Accept a partner invitation
router.post('/accept', acceptInvitation);

// Get current partner information
router.get('/current', getCurrentPartner);

// Remove current partner
router.delete('/current', removePartner);

// Get all pending invitations
router.get('/invitations', getPendingInvitations);

// Cancel a pending invitation
router.delete('/invite', cancelInvitation);

export default router;