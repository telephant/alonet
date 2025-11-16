import { Request, Response } from 'express';
import { AuthenticatedUser } from '../types/auth';
import { websocketService } from '../services/websocketService';
import { realtimeService } from '../services/realtimeService';

/**
 * Real-time and WebSocket status controller
 */

/**
 * Get real-time connection status
 */
export const getRealtimeStatus = async (req: Request, res: Response) => {
  try {
    const userId = (req.user as AuthenticatedUser).id;

    const isConnected = websocketService.isUserConnected(userId);
    const connectedUsersCount = websocketService.getConnectedUsersCount();
    const activeChannelsCount = realtimeService.getActiveChannelsCount();
    const activeChannels = realtimeService.getActiveChannels();

    return res.json({
      user_id: userId,
      is_connected: isConnected,
      connected_users_total: connectedUsersCount,
      active_channels_count: activeChannelsCount,
      active_channels: activeChannels.filter(channel => channel.includes(userId)),
      server_status: 'healthy',
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.error('Error in getRealtimeStatus:', error);
    return res.status(500).json({ error: 'Internal server error' });
  }
};

/**
 * Get overall real-time server statistics (admin endpoint)
 */
export const getRealtimeStats = async (_req: Request, res: Response) => {
  try {
    const connectedUsers = websocketService.getConnectedUserIds();
    const connectedUsersCount = websocketService.getConnectedUsersCount();
    const activeChannelsCount = realtimeService.getActiveChannelsCount();
    const activeChannels = realtimeService.getActiveChannels();

    return res.json({
      server_status: 'healthy',
      connected_users_count: connectedUsersCount,
      connected_users: connectedUsers,
      active_channels_count: activeChannelsCount,
      active_channels: activeChannels,
      uptime: process.uptime(),
      memory_usage: process.memoryUsage(),
      timestamp: new Date().toISOString()
    });
  } catch (error) {
    console.error('Error in getRealtimeStats:', error);
    return res.status(500).json({ error: 'Internal server error' });
  }
};