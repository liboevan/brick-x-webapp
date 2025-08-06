// Runtime Configuration
// This file is loaded after the app is built
// Modify this file to change configuration without rebuilding

window.BRICK_CONFIG = {
  // API Configuration - All through gateway
  api: {
    baseUrl: '/api',
    customNTP: {
      baseUrl: '/api/clock',
      endpoints: {
        status: '/status',
        servers: '/servers',
        serverMode: '/server-mode',
        version: '/version',
        defaultServers: '/servers/default'
      }
    },
    sentinel: {
      baseUrl: '/api/auth',
      endpoints: {
        health: '/health',
        metrics: '/metrics',
        alerts: '/alerts',
        configure: '/configure'
      }
    }
  },

  // Application Settings
  app: {
    title: 'Brick X',
    version: window.BUILD_INFO?.version || '0.1.0-dev',
    environment: 'production'
  },

  // Feature Configuration
  features: {
    customNTP: {
      enabled: true,
      title: 'Custom NTP',
      description: 'Configure and manage NTP time synchronization',
      icon: '🕐',
      url: '/ntp',
      color: '#4CAF50',
      permissions: ['x/clock:read']
    },
    sentinel: {
      enabled: true,
      title: 'Security Sentinel',
      description: 'User management and authentication system',
      icon: '🛡️',
      url: '/sentinel',
      color: '#FF5722'
    },
    gateway: {
      enabled: true,
      title: 'Gateway Monitor',
      description: 'Reverse proxy and traffic management',
      icon: '🚪',
      url: '/gateway',
      color: '#2196F3',
      permissions: ['x/layout:read']
    },
    login: {
      enabled: true,
      title: 'Login System',
      description: 'User authentication and session management',
      icon: '🔑',
      url: '/login',
      color: '#9C27B0'
    },
    smartHome: {
      enabled: true,
      title: 'Smart Home',
      description: 'Manage your smart home devices and scenes',
      icon: '🏠',
      url: '/smart-home',
      color: '#8BC34A',
      permissions: ['x/smart:read']
    }
  },

  // System Configuration
  system: {
    name: 'Brick System',
    version: window.BUILD_INFO?.version || '0.1.0-dev',
    status: 'online'
  },

  // Debug Settings
  debug: {
    enabled: false,
    logLevel: 'info'
  }
};