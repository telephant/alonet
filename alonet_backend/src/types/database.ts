/**
 * Database type definitions for Supabase tables
 */

export interface Database {
  public: {
    Tables: {
      profiles: {
        Row: {
          id: string;
          email: string | null;
          full_name: string | null;
          avatar_url: string | null;
          created_at: string;
          updated_at: string;
        };
        Insert: Omit<Database['public']['Tables']['profiles']['Row'], 'created_at' | 'updated_at'>;
        Update: Partial<Database['public']['Tables']['profiles']['Insert']>;
      };
      partner_relationships: {
        Row: {
          id: string;
          user_id: string;
          partner_id: string;
          status: 'pending' | 'accepted' | 'rejected';
          invitation_code: string | null;
          created_at: string;
          updated_at: string;
          accepted_at: string | null;
        };
        Insert: Pick<Database['public']['Tables']['partner_relationships']['Row'], 'user_id' | 'partner_id'> & {
          status?: 'pending' | 'accepted' | 'rejected';
          invitation_code?: string;
          accepted_at?: string;
        };
        Update: Partial<Database['public']['Tables']['partner_relationships']['Insert']>;
      };
      moments: {
        Row: {
          id: string;
          user_id: string;
          event: string;
          note: string | null;
          moment_time: string;
          timezone: string;
          reaction: string | null;
          reacted_at: string | null;
          created_at: string;
          updated_at: string;
        };
        Insert: Omit<Database['public']['Tables']['moments']['Row'], 'id' | 'created_at' | 'updated_at' | 'reaction' | 'reacted_at'>;
        Update: Partial<Database['public']['Tables']['moments']['Insert']> & {
          reaction?: string | null;
          reacted_at?: string | null;
        };
      };
    };
  };
}

export type Profile = Database['public']['Tables']['profiles']['Row'];
export type PartnerRelationship = Database['public']['Tables']['partner_relationships']['Row'];
export type Moment = Database['public']['Tables']['moments']['Row'];

export type NewProfile = Database['public']['Tables']['profiles']['Insert'];
export type NewPartnerRelationship = Database['public']['Tables']['partner_relationships']['Insert'];
export type NewMoment = Database['public']['Tables']['moments']['Insert'];

export type UpdateProfile = Database['public']['Tables']['profiles']['Update'];
export type UpdatePartnerRelationship = Database['public']['Tables']['partner_relationships']['Update'];
export type UpdateMoment = Database['public']['Tables']['moments']['Update'];