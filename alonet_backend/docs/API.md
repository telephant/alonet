# API Documentation

## Base URL
```
http://localhost:3000/api
```

## Authentication
Most endpoints require authentication. Include the JWT token in the Authorization header:
```
Authorization: Bearer <token>
```

## Endpoints

### Health Check

#### GET /health
Basic health check endpoint.

**Response:**
```json
{
  "status": "healthy",
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

#### GET /health/detailed
Detailed health check including database connectivity.

**Response:**
```json
{
  "status": "healthy",
  "timestamp": "2024-01-01T00:00:00.000Z",
  "services": {
    "api": "healthy",
    "database": "healthy"
  }
}
```

### Authentication

#### POST /auth/signup
Register a new user.

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "SecurePass123",
  "fullName": "John Doe"
}
```

**Response:**
```json
{
  "message": "User created successfully",
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "created_at": "2024-01-01T00:00:00.000Z"
  },
  "session": {
    "access_token": "jwt-token",
    "refresh_token": "refresh-token",
    "expires_in": 3600
  }
}
```

#### POST /auth/signin
Sign in an existing user.

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "SecurePass123"
}
```

**Response:**
```json
{
  "message": "Sign in successful",
  "user": {
    "id": "uuid",
    "email": "user@example.com"
  },
  "session": {
    "access_token": "jwt-token",
    "refresh_token": "refresh-token",
    "expires_in": 3600
  }
}
```

#### POST /auth/signout
Sign out the current user.

**Response:**
```json
{
  "message": "Sign out successful"
}
```

#### POST /auth/refresh
Refresh the access token.

**Request Body:**
```json
{
  "refreshToken": "refresh-token"
}
```

**Response:**
```json
{
  "message": "Token refreshed successfully",
  "session": {
    "access_token": "new-jwt-token",
    "refresh_token": "new-refresh-token",
    "expires_in": 3600
  }
}
```

#### POST /auth/forgot-password
Request a password reset email.

**Request Body:**
```json
{
  "email": "user@example.com"
}
```

**Response:**
```json
{
  "message": "Password reset email sent"
}
```

#### POST /auth/reset-password
Reset password with token.

**Headers:**
```
Authorization: Bearer <reset-token>
```

**Request Body:**
```json
{
  "password": "NewSecurePass123"
}
```

**Response:**
```json
{
  "message": "Password reset successful"
}
```

#### POST /auth/google
Google OAuth sign-in for mobile apps.

**Request Body:**
```json
{
  "idToken": "google-id-token-from-mobile-app"
}
```

**Response:**
```json
{
  "message": "Google sign-in successful",
  "user": {
    "id": "uuid",
    "email": "user@gmail.com",
    "user_metadata": {
      "provider": "google",
      "full_name": "John Doe",
      "avatar_url": "https://lh3.googleusercontent.com/..."
    }
  },
  "access_token": "jwt-token-or-temp-token",
  "user_metadata": {
    "provider": "google",
    "name": "John Doe",
    "picture": "https://lh3.googleusercontent.com/..."
  }
}
```

#### GET /auth/google/callback
Google OAuth callback for web authentication.

**Query Parameters:**
- `code` - Authorization code from Google
- `state` (optional) - State parameter for CSRF protection

**Response:**
Redirects to frontend URL with success/error parameters:
- Success: `{FRONTEND_URL}/auth/callback?success=true`
- Error: `{FRONTEND_URL}/auth/callback?error=oauth_failed`

### User Management

All user endpoints require authentication.

#### GET /users/profile
Get the current user's profile.

**Response:**
```json
{
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "created_at": "2024-01-01T00:00:00.000Z"
  },
  "profile": {
    "id": "uuid",
    "full_name": "John Doe",
    "bio": "Software Developer",
    "phone_number": "+1234567890",
    "updated_at": "2024-01-01T00:00:00.000Z"
  }
}
```

#### PUT /users/profile
Update the current user's profile.

**Request Body:**
```json
{
  "fullName": "John Doe",
  "bio": "Senior Software Developer",
  "phoneNumber": "+1234567890"
}
```

**Response:**
```json
{
  "message": "Profile updated successfully",
  "profile": {
    "id": "uuid",
    "full_name": "John Doe",
    "bio": "Senior Software Developer",
    "phone_number": "+1234567890",
    "updated_at": "2024-01-01T00:00:00.000Z"
  }
}
```

#### POST /users/avatar
Upload user avatar (placeholder - requires file upload implementation).

**Response:**
```json
{
  "message": "Avatar upload endpoint - implement file handling",
  "userId": "uuid"
}
```

#### DELETE /users/account
Delete the current user's account.

**Response:**
```json
{
  "message": "Account deleted successfully"
}
```

## Error Responses

All error responses follow this format:

```json
{
  "error": {
    "message": "Error description",
    "stack": "Stack trace (development only)"
  }
}
```

### Common HTTP Status Codes
- `200` - Success
- `201` - Created
- `400` - Bad Request (validation errors)
- `401` - Unauthorized (authentication required)
- `403` - Forbidden (insufficient permissions)
- `404` - Not Found
- `500` - Internal Server Error
- `503` - Service Unavailable