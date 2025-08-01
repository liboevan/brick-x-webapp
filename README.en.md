[中文](README.md) | English

# Brick X Webapp

Brick X web application providing user interface and static file services. **Note: The current version does not proxy other services.**

## 🏗️ Architecture

### Features
- **Vue.js Frontend** - Modern single-page application
- **Nginx Service** - High-performance static file serving
- **JWT Validation** - Integrated authentication service
- **Responsive Design** - Adapts to various devices
- **Containerized Deployment** - Complete Docker support

### Technology Stack
- **Frontend**: Vue.js 3 + Vue CLI
- **Service**: Nginx + Alpine Linux
- **Build**: Node.js 20 + npm
- **Container**: Docker + Multi-stage build
- **Port**: 17107

## 🚀 Quick Start

### Build Image
```bash
./scripts/build.sh
```

### Start Service
```bash
./scripts/run.sh start
```

### Check Status
```bash
./scripts/run.sh status
```

### View Logs
```bash
./scripts/run.sh logs
```

### Stop Service
```bash
./scripts/run.sh stop
```

## 📋 Scripts

### Build Scripts
- **`scripts/build.sh`** - Build Docker image
- **`scripts/generate_keys.sh`** - Generate RSA key pairs

### Runtime Scripts
- **`scripts/run.sh`** - Container lifecycle management

## 🔧 Configuration

### Environment Variables
- `TZ=UTC` - Timezone setting

### Ports
- **17107** - HTTP web service port

### Endpoints
- `GET /` - Homepage
- `GET /js/*` - JavaScript files
- `GET /css/*` - CSS style files
- `GET /img/*` - Image resources

## 🌐 User Interface

### Homepage Features
- **Login Interface** - User authentication
- **Device Connection** - X device connection management
- **Status Display** - Service health status
- **Responsive Layout** - Mobile device adaptation

### Page Structure
```
/
├── Login Page
├── Device Management
├── Status Monitoring
└── Settings Page
```

## 🔒 Security

### RSA Keys
- **Public Key**: `public.pem` - For JWT validation
- **Nginx Configuration** - Integrated JWT validation
- **HTTPS Ready** - SSL/TLS support

### Authentication Integration
- Integration with auth service
- JWT token validation
- User session management

## 📊 Monitoring

### Health Check
```bash
curl http://localhost:17107/
```

### Build Information
- Version information embedded in image
- Build timestamp recording
- Environment information tracking

## 🐛 Troubleshooting

### Common Issues

1. **Build Failure**
   ```bash
   # Clean and rebuild
   ./scripts/run.sh clean
   ./scripts/build.sh
   ```

2. **Port Already in Use**
   ```bash
   # Check port usage
   sudo lsof -i :17107
   
   # Stop existing container
   ./scripts/run.sh stop
   ```

3. **Page Not Accessible**
   ```bash
   # Check container status
   ./scripts/run.sh status
   
   # View logs
   ./scripts/run.sh logs
   ```

### Debug Commands
```bash
# Check container status
./scripts/run.sh status

# View detailed logs
./scripts/run.sh logs -f

# Test page access
curl http://localhost:17107/

# Check container details
docker inspect brick-x-webapp
```

## 🎯 Best Practices

1. **Build before running** - Ensure image exists
2. **Check page access** - Verify page is normal after startup
3. **Monitor logs** - Use `./scripts/run.sh logs` to view output
4. **Update keys regularly** - Periodically regenerate RSA key pairs
5. **Backup configuration** - Backup nginx configuration and key files

## 📞 Support

For issues or questions:
1. Check service status: `./scripts/run.sh status`
2. View service logs: `./scripts/run.sh logs`
3. Verify page access: Browser visit http://localhost:17107
4. Confirm key files: Check `public.pem`
5. Test endpoints: Use curl to test page access