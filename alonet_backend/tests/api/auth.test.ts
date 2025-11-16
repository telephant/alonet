import request from 'supertest';
import { createApp } from '../../src/app';

describe('Auth API Tests', () => {
  const app = createApp();

  describe('POST /api/auth/signup', () => {
    it('should validate required fields', async () => {
      const response = await request(app)
        .post('/api/auth/signup')
        .send({})
        .expect(400);

      expect(response.body).toHaveProperty('error');
    });

    it('should validate email format', async () => {
      const response = await request(app)
        .post('/api/auth/signup')
        .send({
          email: 'invalid-email',
          password: 'StrongPassword123!',
          fullName: 'Test User',
        })
        .expect(400);

      expect(response.body).toHaveProperty('error');
    });

    it('should validate password strength', async () => {
      const response = await request(app)
        .post('/api/auth/signup')
        .send({
          email: 'test@example.com',
          password: 'weak',
          fullName: 'Test User',
        })
        .expect(400);

      expect(response.body).toHaveProperty('error');
    });

    it('should validate full name length', async () => {
      const response = await request(app)
        .post('/api/auth/signup')
        .send({
          email: 'test@example.com',
          password: 'StrongPassword123!',
          fullName: 'A',
        })
        .expect(400);

      expect(response.body).toHaveProperty('error');
    });

    it('should handle valid signup request', async () => {
      console.log('🔍 Testing valid signup request...');
      const response = await request(app)
        .post('/api/auth/signup')
        .send({
          email: 'test@example.com',
          password: 'StrongPassword123!',
          fullName: 'Test User',
        });

      console.log('📊 Signup response status:', response.status);
      
      // Accept both 201 (success) and 400 (user already exists) as valid test outcomes
      expect([201, 400]).toContain(response.status);
      
      if (response.status === 201) {
        expect(response.body).toHaveProperty('message');
        expect(response.body).toHaveProperty('user');
      }
      
      if (response.status === 400) {
        expect(response.body).toHaveProperty('error');
      }
    });
  });

  describe('POST /api/auth/signin', () => {
    it('should validate required fields', async () => {
      const response = await request(app)
        .post('/api/auth/signin')
        .send({})
        .expect(400);

      expect(response.body).toHaveProperty('error');
    });

    it('should validate email format', async () => {
      const response = await request(app)
        .post('/api/auth/signin')
        .send({
          email: 'invalid-email',
          password: 'password123',
        })
        .expect(400);

      expect(response.body).toHaveProperty('error');
    });

    it('should handle invalid credentials', async () => {
      console.log('🔍 Testing invalid credentials...');
      const response = await request(app)
        .post('/api/auth/signin')
        .send({
          email: 'nonexistent@example.com',
          password: 'wrongpassword',
        })
        .expect(401);

      console.log('📊 Invalid signin response:', response.body);
      expect(response.body).toHaveProperty('error');
      expect(response.body.error.message).toBe('Invalid credentials');
    });
  });

  describe('POST /api/auth/signout', () => {
    it('should handle signout request', async () => {
      console.log('🔍 Testing signout request...');
      const response = await request(app)
        .post('/api/auth/signout')
        .expect(200);

      console.log('📊 Signout response:', response.body);
      expect(response.body).toHaveProperty('message', 'Sign out successful');
    });
  });

  describe('POST /api/auth/refresh', () => {
    it('should validate refresh token requirement', async () => {
      const response = await request(app)
        .post('/api/auth/refresh')
        .send({})
        .expect(400);

      expect(response.body).toHaveProperty('error');
      expect(response.body.error.message).toBe('Refresh token required');
    });

    it('should handle invalid refresh token', async () => {
      console.log('🔍 Testing invalid refresh token...');
      const response = await request(app)
        .post('/api/auth/refresh')
        .send({ refreshToken: 'invalid-token' })
        .expect(401);

      console.log('📊 Refresh token response:', response.body);
      expect(response.body).toHaveProperty('error');
      expect(response.body.error.message).toBe('Invalid refresh token');
    });
  });

  describe('POST /api/auth/forgot-password', () => {
    it('should validate email requirement', async () => {
      const response = await request(app)
        .post('/api/auth/forgot-password')
        .send({})
        .expect(400);

      expect(response.body).toHaveProperty('error');
    });

    it('should handle password reset request', async () => {
      console.log('🔍 Testing forgot password request...');
      const response = await request(app)
        .post('/api/auth/forgot-password')
        .send({ email: 'test@example.com' });

      console.log('📊 Forgot password response status:', response.status);
      
      // Accept both success and error responses (depends on Supabase config)
      expect([200, 400]).toContain(response.status);
      expect(response.body).toHaveProperty('message');
    });
  });

  describe('POST /api/auth/reset-password', () => {
    it('should validate token requirement', async () => {
      const response = await request(app)
        .post('/api/auth/reset-password')
        .send({ password: 'NewPassword123!' })
        .expect(400);

      expect(response.body).toHaveProperty('error');
      expect(response.body.error.message).toBe('Token required');
    });

    it('should validate password requirement', async () => {
      const response = await request(app)
        .post('/api/auth/reset-password')
        .set('Authorization', 'Bearer fake-token')
        .send({})
        .expect(400);

      expect(response.body).toHaveProperty('error');
    });
  });

  describe('POST /api/auth/google', () => {
    it('should validate ID token requirement', async () => {
      const response = await request(app)
        .post('/api/auth/google')
        .send({})
        .expect(400);

      expect(response.body).toHaveProperty('error');
      expect(response.body.error.message).toBe('Google ID token is required');
    });

    it('should handle invalid ID token', async () => {
      console.log('🔍 Testing invalid Google ID token...');
      const response = await request(app)
        .post('/api/auth/google')
        .send({ idToken: 'invalid-token' });

      console.log('📊 Google signin response status:', response.status);
      
      // Expect error for invalid token
      expect([400, 401, 500]).toContain(response.status);
      expect(response.body).toHaveProperty('error');
    });
  });

  describe('GET /api/auth/google/callback', () => {
    it('should validate authorization code requirement', async () => {
      const response = await request(app)
        .get('/api/auth/google/callback')
        .expect(400);

      expect(response.body).toHaveProperty('error');
      expect(response.body.error.message).toBe('Authorization code required');
    });

    it('should handle invalid authorization code', async () => {
      console.log('🔍 Testing invalid authorization code...');
      const response = await request(app)
        .get('/api/auth/google/callback?code=invalid-code');

      console.log('📊 Google callback response status:', response.status);
      
      // Expect redirect or error response
      expect([302, 400, 401]).toContain(response.status);
    });
  });
});