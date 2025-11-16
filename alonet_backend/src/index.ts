import { createServer } from 'http';
import { createApp } from './app';
import { config } from './config/app';
import { websocketService } from './services/websocketService';

// Create Express app
const app = createApp();

// Create HTTP server
const httpServer = createServer(app);

// Initialize WebSocket service
websocketService.init(httpServer);

// Start server
httpServer.listen(config.port, () => {
  console.log(`Server is running on port ${config.port} in ${config.env} mode`);
  console.log(`WebSocket server initialized for real-time communication`);
});

// Handle graceful shutdown
process.on('SIGINT', () => {
  console.log('Shutting down server...');
  websocketService.cleanup();
  httpServer.close(() => {
    console.log('Server shut down successfully');
    process.exit(0);
  });
});

process.on('SIGTERM', () => {
  console.log('Shutting down server...');
  websocketService.cleanup();
  httpServer.close(() => {
    console.log('Server shut down successfully');
    process.exit(0);
  });
});
