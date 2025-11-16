// Mock Supabase client for testing
export const mockSupabaseClient = {
  from: jest.fn().mockReturnThis(),
  select: jest.fn().mockReturnThis(),
  insert: jest.fn().mockReturnThis(),
  update: jest.fn().mockReturnThis(),
  delete: jest.fn().mockReturnThis(),
  eq: jest.fn().mockReturnThis(),
  filter: jest.fn().mockReturnThis(),
  order: jest.fn().mockReturnThis(),
  limit: jest.fn().mockReturnThis(),
  single: jest.fn().mockReturnThis(),
  rpc: jest.fn().mockReturnThis(),
  auth: {
    getUser: jest.fn(),
    signUp: jest.fn(),
    signInWithPassword: jest.fn(),
  },
  storage: {
    from: jest.fn().mockReturnThis(),
    upload: jest.fn(),
    getPublicUrl: jest.fn(),
  }
};

// Mock successful responses
export const mockSuccessResponse = { data: {}, error: null };
export const mockErrorResponse = { data: null, error: { message: 'Database error' } };

// Mock database records
export const mockPartnerRelationship = {
  id: 'relationship-id-123',
  user_id: 'test-user-id-123',
  partner_id: 'partner-user-id-456',
  status: 'accepted',
  invitation_code: 'ABC123',
  created_at: new Date().toISOString(),
  updated_at: new Date().toISOString()
};

export const mockMoment = {
  id: 'moment-id-123',
  user_id: 'test-user-id-123',
  event: '☕️',
  note: 'Morning coffee',
  moment_time: new Date().toISOString(),
  timezone: 'Asia/Dubai',
  created_at: new Date().toISOString(),
  updated_at: new Date().toISOString()
};

export const mockMomentReaction = {
  id: 'reaction-id-123',
  moment_id: 'moment-id-123',
  user_id: 'partner-user-id-456',
  reaction: '❤️',
  created_at: new Date().toISOString()
};