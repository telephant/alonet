import { supabase } from '../config/supabase';
import { RealtimeChannel } from '@supabase/supabase-js';

/**
 * Real-time service for managing Supabase subscriptions
 */
export class RealtimeService {
  private channels: Map<string, RealtimeChannel> = new Map();

  /**
   * Subscribe to moments changes for a user and their partner
   */
  subscribeToMoments(userId: string, callback: (payload: any) => void): string {
    const channelName = `moments_${userId}`;
    
    // Remove existing channel if it exists
    this.unsubscribe(channelName);

    const channel = supabase
      .channel(channelName)
      .on(
        'postgres_changes',
        {
          event: '*', // Listen to all changes (INSERT, UPDATE, DELETE)
          schema: 'public',
          table: 'moments',
          filter: `user_id=eq.${userId}` // User's own moments
        },
        callback
      )
      .on(
        'postgres_changes',
        {
          event: '*',
          schema: 'public', 
          table: 'moments',
          // Filter for partner's moments will be handled by RLS policies
        },
        (payload) => {
          // Additional filtering can be done here if needed
          callback(payload);
        }
      )
      .subscribe();

    this.channels.set(channelName, channel);
    return channelName;
  }

  /**
   * Subscribe to partner relationship changes
   */
  subscribeToPartnerChanges(userId: string, callback: (payload: any) => void): string {
    const channelName = `partners_${userId}`;
    
    // Remove existing channel if it exists
    this.unsubscribe(channelName);

    const channel = supabase
      .channel(channelName)
      .on(
        'postgres_changes',
        {
          event: '*',
          schema: 'public',
          table: 'partner_relationships',
          filter: `user_id=eq.${userId}`
        },
        callback
      )
      .on(
        'postgres_changes',
        {
          event: '*',
          schema: 'public',
          table: 'partner_relationships',
          filter: `partner_id=eq.${userId}`
        },
        callback
      )
      .subscribe();

    this.channels.set(channelName, channel);
    return channelName;
  }

  /**
   * Subscribe to presence (online/offline status)
   * Note: Simplified implementation - can be enhanced with proper presence API
   */
  subscribeToPresence(userId: string, userInfo: any, callback: (payload: any) => void): string {
    const channelName = `presence_${userId}`;
    
    // Remove existing channel if it exists
    this.unsubscribe(channelName);

    // Simple channel subscription for now
    const channel = supabase
      .channel(channelName)
      .subscribe((status) => {
        if (status === 'SUBSCRIBED') {
          // Notify that user is online
          callback({
            event: 'online',
            user_id: userId,
            online_at: new Date().toISOString(),
            ...userInfo
          });
        }
      });

    this.channels.set(channelName, channel);
    return channelName;
  }

  /**
   * Unsubscribe from a specific channel
   */
  unsubscribe(channelName: string): void {
    const channel = this.channels.get(channelName);
    if (channel) {
      supabase.removeChannel(channel);
      this.channels.delete(channelName);
    }
  }

  /**
   * Unsubscribe from all channels for a user
   */
  unsubscribeAll(userId: string): void {
    const userChannels = Array.from(this.channels.keys()).filter(
      name => name.includes(userId)
    );
    
    userChannels.forEach(channelName => {
      this.unsubscribe(channelName);
    });
  }

  /**
   * Get active channels count
   */
  getActiveChannelsCount(): number {
    return this.channels.size;
  }

  /**
   * Get active channel names
   */
  getActiveChannels(): string[] {
    return Array.from(this.channels.keys());
  }

  /**
   * Cleanup all channels
   */
  cleanup(): void {
    this.channels.forEach((channel) => {
      supabase.removeChannel(channel);
    });
    this.channels.clear();
  }
}

// Export singleton instance
export const realtimeService = new RealtimeService();