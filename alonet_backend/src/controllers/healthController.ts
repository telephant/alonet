import { Request, Response } from 'express';
import { supabase } from '../config/supabase';

export const healthController = {
  // Basic health check
  checkHealth: async (_req: Request, res: Response): Promise<void> => {
    res.json({
      status: 'healthy',
      timestamp: new Date().toISOString(),
    });
  },

  // Detailed health check including database connection
  checkHealthDetailed: async (_req: Request, res: Response): Promise<void> => {
    try {
      // Test database connection
      const { error } = await supabase
        .from('_health_check')
        .select('*')
        .limit(1);

      const isDatabaseHealthy = !error || error.code === 'PGRST116'; // Table doesn't exist is ok

      res.json({
        status: 'healthy',
        timestamp: new Date().toISOString(),
        services: {
          api: 'healthy',
          database: isDatabaseHealthy ? 'healthy' : 'unhealthy',
        },
      });
    } catch {
      res.status(503).json({
        status: 'unhealthy',
        timestamp: new Date().toISOString(),
        error: 'Service unavailable',
      });
    }
  },
};
