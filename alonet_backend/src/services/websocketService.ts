import { Server as SocketIOServer } from 'socket.io';
import { Server as HTTPServer } from 'http';
import { supabase } from '../config/supabase';
import { realtimeService } from './realtimeService';

/**
 * WebSocket service for handling real-time connections with clients
 */
export class WebSocketService {
  private io: SocketIOServer | null = null;
  private connectedUsers: Map<string, string> = new Map(); // userId -> socketId

  /**
   * Initialize Socket.IO server
   */
  init(httpServer: HTTPServer): void {
    this.io = new SocketIOServer(httpServer, {
      cors: {
        origin: process.env.FRONTEND_URL || "*",
        methods: ["GET", "POST"]
      }
    });

    this.setupConnectionHandlers();
  }

  /**
   * Setup connection event handlers
   */
  private setupConnectionHandlers(): void {
    if (!this.io) return;

    this.io.on('connection', (socket) => {
      console.log(`Client connected: ${socket.id}`);

      // Handle user authentication and setup
      socket.on('authenticate', async (data) => {
        try {
          const { token, userId } = data;
          
          // Verify the token with Supabase
          const { data: user, error } = await supabase.auth.getUser(token);
          
          if (error || !user?.user || user.user.id !== userId) {
            socket.emit('auth_error', { error: 'Invalid authentication' });
            return;
          }

          // Store user connection
          this.connectedUsers.set(userId, socket.id);
          socket.data.userId = userId;
          
          // Join user to their personal room
          socket.join(`user_${userId}`);
          
          // Setup real-time subscriptions
          this.setupUserSubscriptions(userId, socket);
          
          socket.emit('authenticated', { userId });
          console.log(`User ${userId} authenticated on socket ${socket.id}`);
          
        } catch (error) {
          console.error('Authentication error:', error);
          socket.emit('auth_error', { error: 'Authentication failed' });
        }
      });

      // Handle disconnection
      socket.on('disconnect', () => {
        const userId = socket.data.userId;
        if (userId) {
          this.connectedUsers.delete(userId);
          realtimeService.unsubscribeAll(userId);
          console.log(`User ${userId} disconnected`);
        }
        console.log(`Client disconnected: ${socket.id}`);
      });

      // Handle typing indicators for moments
      socket.on('typing_moment', (data) => {
        const userId = socket.data.userId;
        if (userId) {
          socket.broadcast.to(`user_${userId}`).emit('partner_typing_moment', {
            userId,
            isTyping: data.isTyping
          });
        }
      });
    });
  }

  /**
   * Setup real-time subscriptions for a user
   */
  private setupUserSubscriptions(userId: string, socket: any): void {
    // Subscribe to moments changes
    realtimeService.subscribeToMoments(userId, (payload) => {
      // Emit to user's socket
      socket.emit('moment_change', {
        type: payload.eventType,
        moment: payload.new || payload.old,
        timestamp: new Date().toISOString()
      });

      // Also emit to partner if they're connected
      this.notifyPartner(userId, 'moment_change', {
        type: payload.eventType,
        moment: payload.new || payload.old,
        timestamp: new Date().toISOString()
      });
    });

    // Subscribe to partner relationship changes
    realtimeService.subscribeToPartnerChanges(userId, (payload) => {
      socket.emit('partner_change', {
        type: payload.eventType,
        relationship: payload.new || payload.old,
        timestamp: new Date().toISOString()
      });
    });

    // Subscribe to presence
    realtimeService.subscribeToPresence(userId, {
      socket_id: socket.id
    }, (payload) => {
      socket.emit('presence_change', payload);
    });
  }

  /**
   * Notify a user's partner about an event
   */
  private async notifyPartner(userId: string, event: string, data: any): Promise<void> {
    try {
      // Get user's partner
      const { data: relationship, error } = await supabase
        .from('partner_relationships')
        .select('*')
        .or(`user_id.eq.${userId},partner_id.eq.${userId}`)
        .eq('status', 'accepted')
        .single();

      if (!relationship || error) return;

      // Determine partner ID
      const partnerId = relationship.user_id === userId 
        ? relationship.partner_id 
        : relationship.user_id;

      // Get partner's socket
      const partnerSocketId = this.connectedUsers.get(partnerId);
      if (partnerSocketId && this.io) {
        this.io.to(partnerSocketId).emit(event, data);
      }
    } catch (error) {
      console.error('Error notifying partner:', error);
    }
  }

  /**
   * Broadcast a message to a specific user
   */
  emitToUser(userId: string, event: string, data: any): void {
    const socketId = this.connectedUsers.get(userId);
    if (socketId && this.io) {
      this.io.to(socketId).emit(event, data);
    }
  }

  /**
   * Broadcast a message to all users
   */
  broadcast(event: string, data: any): void {
    if (this.io) {
      this.io.emit(event, data);
    }
  }

  /**
   * Get connected users count
   */
  getConnectedUsersCount(): number {
    return this.connectedUsers.size;
  }

  /**
   * Get connected user IDs
   */
  getConnectedUserIds(): string[] {
    return Array.from(this.connectedUsers.keys());
  }

  /**
   * Check if a user is connected
   */
  isUserConnected(userId: string): boolean {
    return this.connectedUsers.has(userId);
  }

  /**
   * Cleanup
   */
  cleanup(): void {
    if (this.io) {
      this.io.close();
    }
    this.connectedUsers.clear();
    realtimeService.cleanup();
  }
}

// Export singleton instance
export const websocketService = new WebSocketService();