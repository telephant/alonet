# Alonet Backend API

Backend API service for the Alonet mobile application built with TypeScript, Express, and Supabase.

## Architecture Overview

### Technology Stack
- **Runtime**: Node.js
- **Language**: TypeScript
- **Framework**: Express.js
- **Database**: PostgreSQL (via Supabase)
- **Authentication**: Supabase Auth
- **Storage**: Supabase Storage
- **Testing**: Jest
- **Package Manager**: pnpm

### Project Structure
```
src/
├── config/          # Configuration files
│   ├── app.ts       # Application config
│   └── supabase.ts  # Supabase client setup
├── controllers/     # Request handlers
│   ├── authController.ts
│   ├── healthController.ts
│   └── userController.ts
├── middleware/      # Express middleware
│   ├── auth.ts      # Authentication middleware
│   ├── errorHandler.ts
│   └── notFoundHandler.ts
├── routes/          # API routes
│   ├── auth.ts
│   ├── health.ts
│   └── user.ts
├── services/        # Business logic
├── types/           # TypeScript type definitions
├── utils/           # Utility functions
│   └── validators.ts
├── app.ts           # Express app setup
└── index.ts         # Server entry point
```

## API Endpoints

### Health Check
- `GET /api/health` - Basic health check
- `GET /api/health/detailed` - Detailed health check with database status

### Authentication
- `POST /api/auth/signup` - Register new user
- `POST /api/auth/signin` - Login user
- `POST /api/auth/signout` - Logout user
- `POST /api/auth/refresh` - Refresh access token
- `POST /api/auth/forgot-password` - Request password reset
- `POST /api/auth/reset-password` - Reset password

### User Management (Protected Routes)
- `GET /api/users/profile` - Get current user profile
- `PUT /api/users/profile` - Update user profile
- `POST /api/users/avatar` - Upload user avatar
- `DELETE /api/users/account` - Delete user account

## Development

### Setup
1. Clone the repository
2. Install dependencies: `pnpm install`
3. Copy `.env.example` to `.env` and fill in your Supabase credentials
4. Run development server: `pnpm dev`

### Available Scripts
- `pnpm dev` - Start development server with hot reload
- `pnpm build` - Build for production
- `pnpm start` - Start production server
- `pnpm test` - Run tests
- `pnpm test:watch` - Run tests in watch mode
- `pnpm test:coverage` - Run tests with coverage
- `pnpm lint` - Run ESLint
- `pnpm lint:fix` - Fix ESLint errors
- `pnpm format` - Format code with Prettier
- `pnpm typecheck` - Run TypeScript type checking

## Environment Variables

Required environment variables (see `.env.example`):
- `NODE_ENV` - Environment (development/production)
- `PORT` - Server port
- `SUPABASE_URL` - Supabase project URL
- `SUPABASE_ANON_KEY` - Supabase anonymous key
- `SUPABASE_SERVICE_ROLE_KEY` - Supabase service role key (optional)
- `JWT_SECRET` - JWT secret for token signing

## Error Handling

The API uses a centralized error handling approach:
- All errors are caught and processed by the error handler middleware
- Consistent error response format
- Different error details in development vs production

## Security

- Helmet.js for security headers
- CORS configuration
- Input validation on all endpoints
- JWT-based authentication via Supabase
- Rate limiting (to be implemented)

## Testing

Tests are written using Jest and Supertest. Test files should be placed next to the files they test with `.test.ts` or `.spec.ts` extension.

## Deployment

1. Build the project: `pnpm build`
2. Set environment variables
3. Start server: `pnpm start`

The compiled JavaScript will be in the `dist/` directory.