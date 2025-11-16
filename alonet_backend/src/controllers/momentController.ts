import { Request, Response } from 'express';
import { supabase } from '../config/supabase';
import { NewMoment } from '../types/database';
import { AuthenticatedUser } from '../types/auth';

/**
 * Moment management controller
 */

/**
 * Create a new moment
 */
export const createMoment = async (req: Request, res: Response) => {
  try {
    const userId = (req.user as AuthenticatedUser).id;

    const { event, note, moment_time, timezone } = req.body;

    if (!event || !moment_time || !timezone) {
      return res.status(400).json({ 
        error: 'Event, moment_time, and timezone are required' 
      });
    }

    const newMoment: NewMoment = {
      user_id: userId,
      event,
      note: note || null,
      moment_time,
      timezone
    };

    const { data: moment, error } = await supabase
      .from('moments')
      .insert(newMoment)
      .select()
      .single();

    if (error) {
      console.error('Error creating moment:', error);
      return res.status(500).json({ error: 'Failed to create moment' });
    }

    return res.status(201).json(moment);
  } catch (error) {
    console.error('Error in createMoment:', error);
    return res.status(500).json({ error: 'Internal server error' });
  }
};

/**
 * Get moments for the current user and their partner
 */
export const getMoments = async (req: Request, res: Response) => {
  try {
    const userId = (req.user as AuthenticatedUser).id;

    const { start_date, end_date, limit } = req.query;

    let query = supabase
      .from('moments')
      .select('*')
      .order('moment_time', { ascending: true });

    // Apply date filters if provided
    if (start_date) {
      query = query.gte('moment_time', start_date as string);
    }
    if (end_date) {
      query = query.lte('moment_time', end_date as string);
    }

    // Apply limit if provided
    if (limit && !isNaN(Number(limit))) {
      query = query.limit(Number(limit));
    }

    const { data: moments, error } = await query;

    if (error) {
      console.error('Error fetching moments:', error);
      return res.status(500).json({ error: 'Failed to fetch moments' });
    }

    // Separate user's moments and partner's moments
    const userMoments = moments?.filter(moment => moment.user_id === userId) || [];
    const partnerMoments = moments?.filter(moment => moment.user_id !== userId) || [];

    return res.json({
      user_moments: userMoments,
      partner_moments: partnerMoments,
      total: moments?.length || 0
    });
  } catch (error) {
    console.error('Error in getMoments:', error);
    return res.status(500).json({ error: 'Internal server error' });
  }
};

/**
 * Get moments for a specific date
 */
export const getMomentsForDate = async (req: Request, res: Response) => {
  try {
    const userId = (req.user as AuthenticatedUser).id;

    const { date } = req.params;

    if (!date) {
      return res.status(400).json({ error: 'Date parameter is required' });
    }

    // Parse the date and create start/end of day
    const startOfDay = new Date(date);
    startOfDay.setHours(0, 0, 0, 0);
    
    const endOfDay = new Date(date);
    endOfDay.setHours(23, 59, 59, 999);

    const { data: moments, error } = await supabase
      .from('moments')
      .select('*')
      .gte('moment_time', startOfDay.toISOString())
      .lte('moment_time', endOfDay.toISOString())
      .order('moment_time', { ascending: true });

    if (error) {
      console.error('Error fetching moments for date:', error);
      return res.status(500).json({ error: 'Failed to fetch moments' });
    }

    // Separate user's moments and partner's moments
    const userMoments = moments?.filter(moment => moment.user_id === userId) || [];
    const partnerMoments = moments?.filter(moment => moment.user_id !== userId) || [];

    return res.json({
      date,
      user_moments: userMoments,
      partner_moments: partnerMoments,
      total: moments?.length || 0
    });
  } catch (error) {
    console.error('Error in getMomentsForDate:', error);
    return res.status(500).json({ error: 'Internal server error' });
  }
};

/**
 * Update a moment (only for the owner)
 */
export const updateMoment = async (req: Request, res: Response) => {
  try {
    const userId = (req.user as AuthenticatedUser).id;

    const { momentId } = req.params;
    const { event, note, moment_time, timezone } = req.body;

    if (!momentId) {
      return res.status(400).json({ error: 'Moment ID is required' });
    }

    // Build update object with only provided fields
    const updateData: Partial<NewMoment> = {};
    if (event !== undefined) updateData.event = event;
    if (note !== undefined) updateData.note = note;
    if (moment_time !== undefined) updateData.moment_time = moment_time;
    if (timezone !== undefined) updateData.timezone = timezone;

    const { data: moment, error } = await supabase
      .from('moments')
      .update(updateData)
      .eq('id', momentId)
      .eq('user_id', userId) // Ensure user can only update their own moments
      .select()
      .single();

    if (error) {
      console.error('Error updating moment:', error);
      return res.status(500).json({ error: 'Failed to update moment' });
    }

    if (!moment) {
      return res.status(404).json({ error: 'Moment not found or unauthorized' });
    }

    return res.json(moment);
  } catch (error) {
    console.error('Error in updateMoment:', error);
    return res.status(500).json({ error: 'Internal server error' });
  }
};

/**
 * Delete a moment (only for the owner)
 */
export const deleteMoment = async (req: Request, res: Response) => {
  try {
    const userId = (req.user as AuthenticatedUser).id;

    const { momentId } = req.params;

    if (!momentId) {
      return res.status(400).json({ error: 'Moment ID is required' });
    }

    const { error } = await supabase
      .from('moments')
      .delete()
      .eq('id', momentId)
      .eq('user_id', userId); // Ensure user can only delete their own moments

    if (error) {
      console.error('Error deleting moment:', error);
      return res.status(500).json({ error: 'Failed to delete moment' });
    }

    return res.json({ message: 'Moment deleted successfully' });
  } catch (error) {
    console.error('Error in deleteMoment:', error);
    return res.status(500).json({ error: 'Internal server error' });
  }
};

/**
 * Add or update a reaction to a partner's moment
 */
export const reactToMoment = async (req: Request, res: Response) => {
  try {
    const userId = (req.user as AuthenticatedUser).id;

    const { momentId } = req.params;
    const { reaction } = req.body;

    if (!momentId) {
      return res.status(400).json({ error: 'Moment ID is required' });
    }

    // Reaction can be null (to remove reaction) or a string
    if (reaction !== null && typeof reaction !== 'string') {
      return res.status(400).json({ error: 'Reaction must be a string or null' });
    }

    // Check if the moment exists and user is authorized to react
    const { data: moment, error: findError } = await supabase
      .from('moments')
      .select('*')
      .eq('id', momentId)
      .single();

    if (findError || !moment) {
      return res.status(404).json({ error: 'Moment not found' });
    }

    // Users cannot react to their own moments
    if (moment.user_id === userId) {
      return res.status(400).json({ error: 'Cannot react to your own moment' });
    }

    // Update the reaction
    const updateData = {
      reaction: reaction,
      reacted_at: reaction ? new Date().toISOString() : null
    };

    const { data: updatedMoment, error: updateError } = await supabase
      .from('moments')
      .update(updateData)
      .eq('id', momentId)
      .select()
      .single();

    if (updateError) {
      console.error('Error updating reaction:', updateError);
      return res.status(500).json({ error: 'Failed to update reaction' });
    }

    return res.json(updatedMoment);
  } catch (error) {
    console.error('Error in reactToMoment:', error);
    return res.status(500).json({ error: 'Internal server error' });
  }
};

/**
 * Get moment statistics (count by day, week, etc.)
 */
export const getMomentStats = async (req: Request, res: Response) => {
  try {
    const userId = (req.user as AuthenticatedUser).id;

    const { period = 'week' } = req.query;

    let startDate: Date;
    const endDate = new Date();

    // Calculate start date based on period
    switch (period) {
      case 'day':
        startDate = new Date();
        startDate.setHours(0, 0, 0, 0);
        break;
      case 'week':
        startDate = new Date();
        startDate.setDate(startDate.getDate() - 7);
        break;
      case 'month':
        startDate = new Date();
        startDate.setMonth(startDate.getMonth() - 1);
        break;
      default:
        startDate = new Date();
        startDate.setDate(startDate.getDate() - 7);
    }

    const { data: moments, error } = await supabase
      .from('moments')
      .select('*')
      .gte('moment_time', startDate.toISOString())
      .lte('moment_time', endDate.toISOString());

    if (error) {
      console.error('Error fetching moment stats:', error);
      return res.status(500).json({ error: 'Failed to fetch moment statistics' });
    }

    const userMoments = moments?.filter(moment => moment.user_id === userId) || [];
    const partnerMoments = moments?.filter(moment => moment.user_id !== userId) || [];

    const stats = {
      period,
      start_date: startDate.toISOString(),
      end_date: endDate.toISOString(),
      user_moments_count: userMoments.length,
      partner_moments_count: partnerMoments.length,
      total_moments: moments?.length || 0,
      reacted_moments: userMoments.filter(m => m.reaction).length
    };

    return res.json(stats);
  } catch (error) {
    console.error('Error in getMomentStats:', error);
    return res.status(500).json({ error: 'Internal server error' });
  }
};