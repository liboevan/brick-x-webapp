#!/bin/bash

# Shared Configuration for Brick X WebApp Scripts
# This file contains common variables and functions used by all scripts

# Project Configuration
PROJECT_NAME="brick-x-webapp"
IMAGE_NAME="el/brick-x-webapp"
CONTAINER_NAME="el-brick-x-webapp"
WEB_PORT="17100"
NETWORK_NAME="el-brick-x-network"
DEFAULT_VERSION="0.1.0-dev"  # Default version for build
RUN_VERSION="0.1.0-dev"      # Version for start/stop operations

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
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
    echo -e "Brick X WebApp - $1"
    echo -e "======================================${NC}"
}

# Note: Individual scripts handle their own Docker operations
# This file only provides shared configuration variables 