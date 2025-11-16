import { OAuth2Client } from 'google-auth-library';

interface GoogleTokenPayload {
  iss: string;
  aud: string;
  sub: string;
  email: string;
  email_verified: boolean;
  name: string;
  picture: string;
  given_name: string;
  family_name: string;
  iat: number;
  exp: number;
}

export class GoogleAuthService {
  private client: OAuth2Client;

  constructor() {
    const clientId = process.env.GOOGLE_CLIENT_ID;
    if (!clientId && process.env.NODE_ENV !== 'test') {
      throw new Error('GOOGLE_CLIENT_ID environment variable is required');
    }
    this.client = new OAuth2Client(clientId || 'test-client-id');
  }

  async verifyIdToken(idToken: string): Promise<GoogleTokenPayload | null> {
    // In test environment, return mock data
    if (process.env.NODE_ENV === 'test') {
      return {
        iss: 'accounts.google.com',
        aud: 'test-client-id',
        sub: 'test-user-id',
        email: 'test@gmail.com',
        email_verified: true,
        name: 'Test User',
        picture: 'https://example.com/photo.jpg',
        given_name: 'Test',
        family_name: 'User',
        iat: Date.now(),
        exp: Date.now() + 3600,
      };
    }

    try {
      const ticket = await this.client.verifyIdToken({
        idToken,
        audience: process.env.GOOGLE_CLIENT_ID,
      });

      const payload = ticket.getPayload();
      if (!payload) {
        return null;
      }

      return {
        iss: payload.iss,
        aud: payload.aud,
        sub: payload.sub,
        email: payload.email || '',
        email_verified: payload.email_verified || false,
        name: payload.name || '',
        picture: payload.picture || '',
        given_name: payload.given_name || '',
        family_name: payload.family_name || '',
        iat: payload.iat || 0,
        exp: payload.exp || 0,
      };
    } catch (error) {
      console.error('Error verifying Google ID token:', error);
      return null;
    }
  }

  async exchangeCodeForTokens(code: string, redirectUri: string) {
    try {
      const { tokens } = await this.client.getToken({
        code,
        redirect_uri: redirectUri,
      });

      if (tokens.id_token) {
        return await this.verifyIdToken(tokens.id_token);
      }

      return null;
    } catch (error) {
      console.error('Error exchanging code for tokens:', error);
      return null;
    }
  }
}

export const googleAuthService = new GoogleAuthService();
