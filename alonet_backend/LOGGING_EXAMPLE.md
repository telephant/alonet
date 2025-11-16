# Request/Response Logging

## Features Added ✅

I've added a comprehensive request/response logging system to the backend that provides:

### **What Gets Logged**

#### **Incoming Requests**
- HTTP method and URL
- Timestamp
- Request body (with sensitive fields redacted)

#### **Outgoing Responses**
- Status code with color coding
- Response time
- Success summaries for 200/201 responses
- Full error details for 4xx/5xx responses

### **Security Features**
- **Sensitive Data Protection**: Automatically redacts `password`, `refreshToken`, and `idToken` fields
- **Color Coding**: Different colors for different status codes (green=success, red=error, yellow=warning)
- **Development Only**: Custom logging only runs in development mode

### **Example Output**

When you make a request, you'll see output like this:

```
→ REQUEST  POST /api/auth/signin [2024-01-01T12:00:00.000Z]
  Body: {
    "email": "user@example.com",
    "password": "[REDACTED]"
  }

← RESPONSE 200 POST /api/auth/signin (45ms)
  Success: {
    "message": "Sign in successful",
    "userEmail": "user@example.com",
    "hasSession": true
  }

```

For errors:
```
→ REQUEST  POST /api/auth/google [2024-01-01T12:00:00.000Z]
  Body: {
    "idToken": "[REDACTED]"
  }

← RESPONSE 401 POST /api/auth/google (12ms)
  Error: {
    "error": {
      "message": "Invalid Google token or email not verified"
    }
  }

```

## Testing the Logging

1. **Start the backend:**
```bash
cd /Users/telephant/self/openthis-app/openthis_backend
pnpm run dev
```

2. **Make a test request:**
```bash
curl -X GET http://localhost:3000/api/health
```

3. **Try with POST data:**
```bash
curl -X POST http://localhost:3000/api/auth/signin \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"testpass"}'
```

## Benefits

- **Easy Debugging**: See exactly what requests come in and responses go out
- **Performance Monitoring**: Response times are logged for each request  
- **Security Aware**: Sensitive data is automatically hidden
- **Clean Format**: Color-coded and well-structured output for easy reading
- **Production Ready**: Only activates in development mode

The logging will help you debug the OAuth flow and any other API interactions!