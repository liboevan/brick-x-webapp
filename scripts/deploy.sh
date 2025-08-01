#!/bin/bash

# Complete deployment script for brick-x system
# This script generates keys, builds Vue.js app, and builds Docker images

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}======================================"
    echo -e "Brick X - Complete Deployment"
    echo -e "======================================${NC}"
}

print_header "Starting Complete Deployment"

# Check prerequisites
print_info "Checking prerequisites..."

if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed. Please install Docker first."
    exit 1
fi

if ! command -v node &> /dev/null; then
    print_error "Node.js is not installed. Please install Node.js first."
    exit 1
fi

if ! command -v npm &> /dev/null; then
    print_error "npm is not installed. Please install npm first."
    exit 1
fi

if ! command -v openssl &> /dev/null; then
    print_error "OpenSSL is not installed. Please install OpenSSL first."
    exit 1
fi

print_info "All prerequisites are satisfied!"

# Step 1: Generate RSA keys
print_header "Step 1: Generating RSA Keys"
cd docker/keys
chmod +x generate_keys.sh
./generate_keys.sh
cd ../..

# Step 2: Build Vue.js application
print_header "Step 2: Building Vue.js Application"
chmod +x scripts/build.sh
./scripts/build.sh

# Step 3: Build brick-x-auth-service Docker image
print_header "Step 3: Building brick-x-auth-service Docker Image"
cd ../brick-x-auth-service
docker build -t brick-x-auth-service:latest .
print_info "brick-x-auth-service Docker image built successfully!"

# Step 4: Build brick-x-webapp Docker image
print_header "Step 4: Building brick-x-webapp Docker Image"
cd ../brick-x-webapp
docker build -t brick-x-webapp:latest .
print_info "brick-x-webapp Docker image built successfully!"

# Step 5: Create docker-compose file
print_header "Step 5: Creating docker-compose.yml"
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  brick-x-auth-service:
    image: brick-x-auth-service:latest
    container_name: brick-x-auth-service
    ports:
      - "8081:8081"
    volumes:
      - ./brick-x-auth-service/config.json:/root/config.json:ro
      - ./brick-x-auth-service/keys:/root/keys:ro
    networks:
      - brick-x-network

  brick-x-webapp:
    image: brick-x-webapp:latest
    container_name: brick-x-webapp
    ports:
      - "8080:17107"  # 修复：使用正确的端口映射
    depends_on:
      - brick-x-auth-service
    networks:
      - brick-x-network

networks:
  brick-x-network:
    driver: bridge
EOF

print_info "docker-compose.yml created successfully!"

# Step 6: Final instructions
print_header "Deployment Complete!"
print_info "All components have been built successfully!"
echo ""
print_info "To start the services, run:"
echo "  docker-compose up -d"
echo ""
print_info "To access the application:"
echo "  - Webapp: http://localhost:8080"
echo "  - Auth API: http://localhost:8081"
echo ""
print_info "Default local users:"
echo "  - x-admin (password: admin123)"
echo "  - x-operator (password: operator123)"
echo "  - x-observer (password: observer123)"
echo ""
print_warning "Remember to change default passwords in production!"