import { Request, Response, NextFunction } from 'express';
import { validateSignUp, validateSignIn } from '../../src/utils/validators';

describe('Validators', () => {
  let mockReq: Partial<Request>;
  let mockRes: Partial<Response>;
  let mockNext: NextFunction;

  beforeEach(() => {
    mockReq = {
      body: {},
    };
    mockRes = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn(),
    };
    mockNext = jest.fn();
  });

  describe('validateSignUp', () => {
    it('should pass validation with valid data', () => {
      mockReq.body = {
        email: 'test@example.com',
        password: 'Password123',
        fullName: 'John Doe',
      };

      validateSignUp(mockReq as Request, mockRes as Response, mockNext);

      expect(mockNext).toHaveBeenCalled();
      expect(mockRes.status).not.toHaveBeenCalled();
    });

    it('should reject invalid email', () => {
      mockReq.body = {
        email: 'invalid-email',
        password: 'Password123',
        fullName: 'John Doe',
      };

      validateSignUp(mockReq as Request, mockRes as Response, mockNext);

      expect(mockRes.status).toHaveBeenCalledWith(400);
      expect(mockRes.json).toHaveBeenCalledWith({
        error: { message: expect.stringContaining('Valid email is required') },
      });
      expect(mockNext).not.toHaveBeenCalled();
    });

    it('should reject weak password', () => {
      mockReq.body = {
        email: 'test@example.com',
        password: '123',
        fullName: 'John Doe',
      };

      validateSignUp(mockReq as Request, mockRes as Response, mockNext);

      expect(mockRes.status).toHaveBeenCalledWith(400);
      expect(mockRes.json).toHaveBeenCalledWith({
        error: { message: expect.stringContaining('Password must be at least 8 characters') },
      });
    });

    it('should reject short full name', () => {
      mockReq.body = {
        email: 'test@example.com',
        password: 'Password123',
        fullName: 'J',
      };

      validateSignUp(mockReq as Request, mockRes as Response, mockNext);

      expect(mockRes.status).toHaveBeenCalledWith(400);
      expect(mockRes.json).toHaveBeenCalledWith({
        error: { message: expect.stringContaining('Full name must be at least 2 characters') },
      });
    });
  });

  describe('validateSignIn', () => {
    it('should pass validation with valid credentials', () => {
      mockReq.body = {
        email: 'test@example.com',
        password: 'Password123',
      };

      validateSignIn(mockReq as Request, mockRes as Response, mockNext);

      expect(mockNext).toHaveBeenCalled();
      expect(mockRes.status).not.toHaveBeenCalled();
    });

    it('should reject missing email', () => {
      mockReq.body = {
        password: 'Password123',
      };

      validateSignIn(mockReq as Request, mockRes as Response, mockNext);

      expect(mockRes.status).toHaveBeenCalledWith(400);
      expect(mockRes.json).toHaveBeenCalledWith({
        error: { message: expect.stringContaining('Valid email is required') },
      });
    });

    it('should reject missing password', () => {
      mockReq.body = {
        email: 'test@example.com',
      };

      validateSignIn(mockReq as Request, mockRes as Response, mockNext);

      expect(mockRes.status).toHaveBeenCalledWith(400);
      expect(mockRes.json).toHaveBeenCalledWith({
        error: { message: expect.stringContaining('Password is required') },
      });
    });
  });
});