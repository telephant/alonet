import { Request, Response, NextFunction } from 'express';

// ANSI color codes for terminal output
const colors = {
  reset: '\x1b[0m',
  bright: '\x1b[1m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  red: '\x1b[31m',
  cyan: '\x1b[36m',
  magenta: '\x1b[35m',
};

// Get status color based on status code
const getStatusColor = (status: number): string => {
  if (status >= 500) return colors.red;
  if (status >= 400) return colors.yellow;
  if (status >= 300) return colors.cyan;
  if (status >= 200) return colors.green;
  return colors.blue;
};

export const requestLogger = (
  req: Request,
  res: Response,
  next: NextFunction
): void => {
  const startTime = Date.now();
  const timestamp = new Date().toISOString();

  // Log incoming request
  console.log(
    `${colors.bright}${colors.blue}→ REQUEST${colors.reset}  ${colors.cyan}${req.method}${colors.reset} ${req.url} ${colors.magenta}[${timestamp}]${colors.reset}`
  );

  // Log request body for POST/PUT/PATCH
  if (
    ['POST', 'PUT', 'PATCH'].includes(req.method) &&
    req.body &&
    Object.keys(req.body).length > 0
  ) {
    // Don't log sensitive fields
    const bodyToLog = { ...req.body };
    if (bodyToLog.password) bodyToLog.password = '[REDACTED]';
    if (bodyToLog.refreshToken) bodyToLog.refreshToken = '[REDACTED]';
    if (bodyToLog.idToken) bodyToLog.idToken = '[REDACTED]';

    console.log(
      `  ${colors.bright}Body:${colors.reset} ${JSON.stringify(bodyToLog, null, 2).split('\n').join('\n  ')}`
    );
  }

  // Store original send function
  const originalSend = res.send;
  let responseBody: any;

  // Override send function to capture response
  res.send = function (this: Response, body: any): Response {
    responseBody = body;
    return originalSend.call(this, body);
  };

  // Log response when finished
  res.on('finish', () => {
    const duration = Date.now() - startTime;
    const statusColor = getStatusColor(res.statusCode);

    // Log outgoing response
    console.log(
      `${colors.bright}${statusColor}← RESPONSE${colors.reset} ${statusColor}${res.statusCode}${colors.reset} ${req.method} ${req.url} ${colors.yellow}(${duration}ms)${colors.reset}`
    );

    // Log response body for non-200 or if it contains error
    if (res.statusCode !== 204 && responseBody) {
      try {
        const body =
          typeof responseBody === 'string'
            ? JSON.parse(responseBody)
            : responseBody;

        // Log errors always
        if (body.error || res.statusCode >= 400) {
          console.log(
            `  ${colors.bright}${colors.red}Error:${colors.reset} ${JSON.stringify(body, null, 2).split('\n').join('\n  ')}`
          );
        } else if (res.statusCode === 200 || res.statusCode === 201) {
          // For successful responses, log a summary
          const summary: any = {};
          if (body.message) summary.message = body.message;
          if (body.user?.email) summary.userEmail = body.user.email;
          if (body.session) summary.hasSession = true;

          if (Object.keys(summary).length > 0) {
            console.log(
              `  ${colors.bright}${colors.green}Success:${colors.reset} ${JSON.stringify(summary, null, 2).split('\n').join('\n  ')}`
            );
          }
        }
      } catch {
        // If parsing fails, it's probably not JSON
      }
    }

    // Add a blank line for readability
    console.log('');
  });

  next();
};

