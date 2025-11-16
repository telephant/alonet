# Type System Design

## Overview

This document outlines our clean and type-safe design for handling authenticated requests in the Alonet backend API.

## Previous Issues

- ❌ `AuthRequest` type was imported but never defined
- ❌ Global namespace extension used unsafe `any` type
- ❌ Inconsistent null checking throughout controllers
- ❌ No clear separation between authenticated and optional auth endpoints

## New Design

### 1. Core Types (`src/types/auth.ts`)

```typescript
// Authenticated user type from Supabase
export interface AuthenticatedUser extends User {
  id: string;
  email?: string;
}

// For routes that require authentication
export interface AuthenticatedRequest extends Request {
  user: AuthenticatedUser; // Always present, no optional chaining needed
}

// For routes that may or may not require auth
export interface OptionalAuthRequest extends Request {
  user?: AuthenticatedUser;
}
```

### 2. Auth Middleware (`src/middleware/auth.ts`)

- Uses `OptionalAuthRequest` as input (since user may not be authenticated yet)
- Guarantees `req.user` exists after successful authentication
- Re-exports all auth types for convenience
- Type-safe user attachment with proper Supabase User typing

### 3. Controller Benefits

#### Before:
```typescript
export const createMoment = async (req: AuthRequest, res: Response) => {
  const userId = req.user?.id; // Optional chaining needed
  if (!userId) {                // Manual null check required
    return res.status(401).json({ error: 'Unauthorized' });
  }
  // ... rest of function
}
```

#### After:
```typescript
export const createMoment = async (req: Request, res: Response) => {
  const userId = req.user!.id; // Non-null assertion - guaranteed by auth middleware
  // ... rest of function (no null checks needed)
}
```

## Type Safety Guarantees

1. **Compile-time safety**: Global namespace extension provides `req.user` typing
2. **Runtime safety**: Auth middleware guarantees user is authenticated before reaching controllers  
3. **Clean code**: Non-null assertions eliminate repetitive null checks
4. **Express compatibility**: Uses standard Express Request type with route middleware

## Usage Patterns

### Authenticated Routes (Most Common)
```typescript
import { Request, Response } from 'express';

export const controllerFunction = async (req: Request, res: Response) => {
  const userId = req.user!.id; // Non-null assertion - guaranteed by auth middleware
  // ... controller logic
};
```

### Optional Authentication Routes (Rare)
```typescript
import { OptionalAuthRequest } from '../types/auth';

export const publicFunction = async (req: OptionalAuthRequest, res: Response) => {
  if (req.user) {
    // User is authenticated
    const userId = req.user.id;
  } else {
    // Public access
  }
};
```

### Middleware Usage
```typescript
// All routes require authentication
router.use(authenticate);

// Individual route requires authentication  
router.get('/protected', authenticate, controllerFunction);
```

## Files Updated

- ✅ `src/types/auth.ts` - New type definitions
- ✅ `src/middleware/auth.ts` - Improved typing and exports
- ✅ `src/controllers/partnerController.ts` - All functions use `AuthenticatedRequest`
- ✅ `src/controllers/momentController.ts` - All functions use `AuthenticatedRequest`
- ✅ `src/controllers/realtimeController.ts` - Auth function uses `AuthenticatedRequest`
- ✅ `src/routes/*.ts` - Updated imports for new route exports
- ✅ `src/app.ts` - Updated route imports

## Benefits

1. **Reduced boilerplate**: No more repetitive auth checks
2. **Better developer experience**: Clear types and auto-completion
3. **Fewer bugs**: Compile-time catching of auth-related errors
4. **Maintainable**: Centralized auth typing in one place
5. **Scalable**: Easy to extend for new auth requirements