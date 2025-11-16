import { supabase } from '../../src/config/supabase';

describe('Supabase Connection Tests', () => {
  describe('Supabase Client', () => {
    it('should be properly initialized', () => {
      expect(supabase).toBeDefined();
      expect(typeof supabase).toBe('object');
    });

    it('should connect to Supabase successfully', async () => {
      // Test basic connection by attempting a simple query
      // This should not fail even if the table doesn't exist
      const { error } = await supabase
        .from('_health_check')
        .select('*')
        .limit(1);

      // Connection is successful if either no error or table doesn't exist error
      expect(error === null || error.code === 'PGRST116' || error.code === 'PGRST205').toBe(true);
    });
  });

  describe('Environment Variables', () => {
    it('should load environment variables correctly', () => {
      expect(process.env.SUPABASE_URL).toBeDefined();
      expect(process.env.SUPABASE_ANON_KEY).toBeDefined();
    });

    it('should have valid environment variable formats', () => {
      expect(process.env.SUPABASE_URL).toMatch(/^https:\/\/.+\.supabase\.co$/);
      expect(process.env.SUPABASE_ANON_KEY).toMatch(/^eyJ/);
    });
  });

  describe('Database Operations', () => {
    it('should handle database queries without throwing errors', async () => {
      // Test that we can make a query without the client throwing an error
      let queryError = null;
      
      try {
        await supabase
          .from('non_existent_table')
          .select('*')
          .limit(1);
      } catch (err) {
        queryError = err;
      }

      // Should not throw JavaScript errors (Supabase errors are handled in response)
      expect(queryError).toBeNull();
    });

    it('should return proper error structure for invalid queries', async () => {
      const { data, error } = await supabase
        .from('definitely_non_existent_table_12345')
        .select('*')
        .limit(1);

      expect(data).toBe(null);
      expect(error).toBeDefined();
      expect(error?.code).toBeDefined();
      expect(error?.message).toBeDefined();
    });
  });
});