#!/bin/bash

# Build script for brick-x-webapp
# This script builds the Vue.js frontend and prepares it for Docker deployment

set -e

# Source shared configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"
source "$SCRIPT_DIR/config.sh"

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
    echo -e "Brick X Webapp - Build"
    echo -e "======================================${NC}"
}

print_header "Build"

# Accept version as first argument, or use default
VERSION=${1:-0.1.0-dev}
BUILD_DATETIME=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

print_info "Building with version: $VERSION"

# Always run docker build from the brick-x-webapp root directory
cd "$SCRIPT_DIR/.."
docker build -f Dockerfile --build-arg VERSION=$VERSION --build-arg BUILD_DATETIME=$BUILD_DATETIME -t $IMAGE_NAME:$VERSION -t $IMAGE_NAME:latest .

print_info "Build completed!"
print_info "Image: $IMAGE_NAME:$VERSION"
print_info "Image: $IMAGE_NAME:latest" 