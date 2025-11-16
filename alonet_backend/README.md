# Alonet Backend

Backend API service for the Alonet mobile application built with TypeScript, Express, and Supabase.

## Quick Start

1. Install dependencies:
```bash
pnpm install
```

2. Set up environment variables:
```bash
cp .env.example .env
# Edit .env with your Supabase credentials
```

3. Run development server:
```bash
pnpm dev
```

## Available Scripts

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

## Documentation

See the `/docs` directory for detailed documentation:
- [Architecture Overview](docs/README.md)
- [API Documentation](docs/API.md)
- [Supabase Integration](docs/SUPABASE.md)

## Environment Variables

Create a `.env` file based on `.env.example` with your Supabase credentials:
- `SUPABASE_URL` - Your Supabase project URL
- `SUPABASE_ANON_KEY` - Your Supabase anonymous key
- `SUPABASE_SERVICE_ROLE_KEY` - Your Supabase service role key (optional)

## Tech Stack

- **Runtime**: Node.js
- **Language**: TypeScript
- **Framework**: Express.js
- **Database**: PostgreSQL (via Supabase)
- **Authentication**: Supabase Auth
- **Testing**: Jest
- **Package Manager**: pnpm