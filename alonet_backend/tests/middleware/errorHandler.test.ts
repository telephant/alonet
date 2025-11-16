import { Request, Response, NextFunction } from 'express';
import { errorHandler, CustomError } from '../../src/middleware/errorHandler';

// Mock the config module
jest.mock('../../src/config/app', () => ({
  config: {
    isDevelopment: false, // Default to production
  },
}));

// Import mocked config
import { config } from '../../src/config/app';

describe('Error Handler Middleware', () => {
  let mockReq: Partial<Request>;
  let mockRes: Partial<Response>;
  let mockNext: NextFunction;

  beforeEach(() => {
    // Reset config to production mode
    (config as any).isDevelopment = false;
    
    mockReq = {
      method: 'GET',
      url: '/test',
      params: {},
      query: {},
    };
    mockRes = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn(),
    };
    mockNext = jest.fn();
    
    // Clear mock calls
    jest.clearAllMocks();
  });

  it('should handle error with custom status code', () => {
    const error: CustomError = new Error('Custom error');
    error.statusCode = 404;

    errorHandler(error, mockReq as Request, mockRes as Response, mockNext);

    expect(mockRes.status).toHaveBeenCalledWith(404);
    expect(mockRes.json).toHaveBeenCalledWith({
      error: {
        message: 'Custom error',
      },
    });
  });

  it('should handle error without status code', () => {
    const error = new Error('Internal error');

    errorHandler(error, mockReq as Request, mockRes as Response, mockNext);

    expect(mockRes.status).toHaveBeenCalledWith(500);
    expect(mockRes.json).toHaveBeenCalledWith({
      error: {
        message: 'Internal error',
      },
    });
  });

  it('should include stack trace in development mode', () => {
    // Set development mode
    (config as any).isDevelopment = true;

    const error = new Error('Dev error');
    error.stack = 'Error stack trace';

    errorHandler(error, mockReq as Request, mockRes as Response, mockNext);

    expect(mockRes.json).toHaveBeenCalledWith({
      error: {
        message: 'Dev error',
        stack: 'Error stack trace',
      },
    });
  });

  it('should not include stack trace in production mode', () => {
    const error = new Error('Prod error');
    error.stack = 'Error stack trace';

    errorHandler(error, mockReq as Request, mockRes as Response, mockNext);

    expect(mockRes.json).toHaveBeenCalledWith({
      error: {
        message: 'Prod error',
        // No stack property
      },
    });
  });
});