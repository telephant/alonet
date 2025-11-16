import { Request, Response } from 'express';
import { supabase } from '../config/supabase';
import { AuthenticatedUser } from '../types/auth';

/**
 * Partner relationship management controller
 */

/**
 * Send partner invitation
 * Creates a pending partnership with an invitation code
 */
export const sendInvitation = async (req: Request, res: Response) => {
  try {
    const userId = (req.user as AuthenticatedUser).id;

    // Check if user already has a partnership
    const { data: existingRelationships } = await supabase
      .from('partner_relationships')
      .select('*')
      .or(`user_id.eq.${userId},partner_id.eq.${userId}`)
      .eq('status', 'accepted')
      .single();

    if (existingRelationships) {
      return res.status(400).json({ 
        error: 'You already have an active partner relationship' 
      });
    }

    // Check for pending invitations from this user
    const { data: pendingInvitation, error: pendingError } = await supabase
      .from('partner_relationships')
      .select('*')
      .eq('user_id', userId)
      .eq('status', 'pending')
      .single();

    if (pendingInvitation && !pendingError) {
      // Return existing invitation code
      return res.json({
        invitation_code: pendingInvitation.invitation_code,
        status: pendingInvitation.status,
        created_at: pendingInvitation.created_at
      });
    }

    // Create new invitation
    const { data: newInvitation, error: createError } = await supabase
      .from('partner_relationships')
      .insert({
        user_id: userId,
        partner_id: userId // Temporary, will be updated when accepted
      })
      .select()
      .single();

    if (createError) {
      console.error('Error creating invitation:', createError);
      return res.status(500).json({ error: 'Failed to create invitation' });
    }

    return res.status(201).json({
      invitation_code: newInvitation.invitation_code,
      status: newInvitation.status,
      created_at: newInvitation.created_at
    });
  } catch (error) {
    console.error('Error in sendInvitation:', error);
    return res.status(500).json({ error: 'Internal server error' });
  }
};

/**
 * Accept partner invitation using invitation code
 */
export const acceptInvitation = async (req: Request, res: Response) => {
  try {
    const userId = req.user?.id;
    const { invitation_code } = req.body;

    if (!userId) {
      return res.status(401).json({ error: 'Unauthorized' });
    }

    if (!invitation_code || typeof invitation_code !== 'string') {
      return res.status(400).json({ error: 'Invalid invitation code' });
    }

    // Check if accepting user already has a partnership
    const { data: existingRelationships, error: checkError } = await supabase
      .from('partner_relationships')
      .select('*')
      .or(`user_id.eq.${userId},partner_id.eq.${userId}`)
      .eq('status', 'accepted')
      .single();

    if (existingRelationships && !checkError) {
      return res.status(400).json({ 
        error: 'You already have an active partner relationship' 
      });
    }

    // Find the invitation
    const { data: invitation, error: findError } = await supabase
      .from('partner_relationships')
      .select('*')
      .eq('invitation_code', invitation_code.toUpperCase())
      .eq('status', 'pending')
      .single();

    if (findError || !invitation) {
      return res.status(404).json({ error: 'Invalid or expired invitation code' });
    }

    // Prevent self-partnership
    if (invitation.user_id === userId) {
      return res.status(400).json({ error: 'Cannot accept your own invitation' });
    }

    // Update the invitation to accepted
    const { data: updatedRelationship, error: updateError } = await supabase
      .from('partner_relationships')
      .update({
        partner_id: userId,
        status: 'accepted',
        accepted_at: new Date().toISOString()
      })
      .eq('id', invitation.id)
      .select()
      .single();

    if (updateError) {
      console.error('Error accepting invitation:', updateError);
      return res.status(500).json({ error: 'Failed to accept invitation' });
    }

    // Get partner's profile information
    const { data: partnerProfile } = await supabase
      .from('profiles')
      .select('*')
      .eq('id', invitation.user_id)
      .single();

    return res.json({
      message: 'Partnership established successfully',
      partner: partnerProfile,
      relationship: updatedRelationship
    });
  } catch (error) {
    console.error('Error in acceptInvitation:', error);
    return res.status(500).json({ error: 'Internal server error' });
  }
};

/**
 * Get current partner information
 */
export const getCurrentPartner = async (req: Request, res: Response) => {
  try {
    const userId = (req.user as AuthenticatedUser).id;

    // Find active partnership
    const { data: relationship, error: relationshipError } = await supabase
      .from('partner_relationships')
      .select('*')
      .or(`user_id.eq.${userId},partner_id.eq.${userId}`)
      .eq('status', 'accepted')
      .single();

    if (relationshipError || !relationship) {
      return res.status(404).json({ error: 'No active partnership found' });
    }

    // Determine partner ID
    const partnerId = relationship.user_id === userId 
      ? relationship.partner_id 
      : relationship.user_id;

    // Get partner's profile
    const { data: partnerProfile, error: profileError } = await supabase
      .from('profiles')
      .select('*')
      .eq('id', partnerId)
      .single();

    if (profileError || !partnerProfile) {
      return res.status(404).json({ error: 'Partner profile not found' });
    }

    return res.json({
      partner: partnerProfile,
      relationship: {
        id: relationship.id,
        status: relationship.status,
        created_at: relationship.created_at,
        accepted_at: relationship.accepted_at
      }
    });
  } catch (error) {
    console.error('Error in getCurrentPartner:', error);
    return res.status(500).json({ error: 'Internal server error' });
  }
};

/**
 * Remove partner relationship
 */
export const removePartner = async (req: Request, res: Response) => {
  try {
    const userId = (req.user as AuthenticatedUser).id;

    // Find and delete active partnership
    const { data: relationship, error: findError } = await supabase
      .from('partner_relationships')
      .select('*')
      .or(`user_id.eq.${userId},partner_id.eq.${userId}`)
      .eq('status', 'accepted')
      .single();

    if (findError || !relationship) {
      return res.status(404).json({ error: 'No active partnership found' });
    }

    // Delete the relationship
    const { error: deleteError } = await supabase
      .from('partner_relationships')
      .delete()
      .eq('id', relationship.id);

    if (deleteError) {
      console.error('Error removing partner:', deleteError);
      return res.status(500).json({ error: 'Failed to remove partnership' });
    }

    return res.json({ message: 'Partnership removed successfully' });
  } catch (error) {
    console.error('Error in removePartner:', error);
    return res.status(500).json({ error: 'Internal server error' });
  }
};

/**
 * Get pending invitations (both sent and received)
 */
export const getPendingInvitations = async (req: Request, res: Response) => {
  try {
    const userId = (req.user as AuthenticatedUser).id;

    // Get sent invitations
    const { data: sentInvitations } = await supabase
      .from('partner_relationships')
      .select('*')
      .eq('user_id', userId)
      .eq('status', 'pending');

    // Get received invitations (where current user could be the partner)
    const { data: receivedInvitations } = await supabase
      .from('partner_relationships')
      .select(`
        *,
        inviter:profiles!user_id(*)
      `)
      .neq('user_id', userId)
      .eq('status', 'pending');

    return res.json({
      sent: sentInvitations || [],
      received: receivedInvitations || []
    });
  } catch (error) {
    console.error('Error in getPendingInvitations:', error);
    return res.status(500).json({ error: 'Internal server error' });
  }
};

/**
 * Cancel a pending invitation
 */
export const cancelInvitation = async (req: Request, res: Response) => {
  try {
    const userId = (req.user as AuthenticatedUser).id;

    // Delete pending invitation created by this user
    const { error: deleteError } = await supabase
      .from('partner_relationships')
      .delete()
      .eq('user_id', userId)
      .eq('status', 'pending');

    if (deleteError) {
      console.error('Error canceling invitation:', deleteError);
      return res.status(500).json({ error: 'Failed to cancel invitation' });
    }

    return res.json({ message: 'Invitation canceled successfully' });
  } catch (error) {
    console.error('Error in cancelInvitation:', error);
    return res.status(500).json({ error: 'Internal server error' });
  }
};