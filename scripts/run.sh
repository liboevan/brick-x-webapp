#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Container configuration
CONTAINER_NAME="brick-x-webapp"
IMAGE_NAME="brick-x-webapp:latest"
PORT="17107"
NETWORK_NAME="brick-x-network"

case "${1:-help}" in
    "start")
        print_status "Starting Brick X Webapp..."
        
        # Check if image exists
        if ! docker image inspect "$IMAGE_NAME" >/dev/null 2>&1; then
            print_error "Image $IMAGE_NAME not found. Please run './scripts/build.sh' first."
            exit 1
        fi
        
        # Create network if it doesn't exist
        if ! docker network inspect "$NETWORK_NAME" >/dev/null 2>&1; then
            print_status "Creating network $NETWORK_NAME..."
            docker network create "$NETWORK_NAME"
        fi
        
        # Stop and remove existing container
        if docker ps -q -f name="$CONTAINER_NAME" | grep -q .; then
            print_status "Stopping existing container..."
            docker stop "$CONTAINER_NAME"
            docker rm "$CONTAINER_NAME"
        fi
        
        # Start container
        print_status "Starting container..."
        docker run -d \
            --name "$CONTAINER_NAME" \
            --network "$NETWORK_NAME" \
            -p "$PORT:$PORT" \
            -e TZ=UTC \
            --restart unless-stopped \
            "$IMAGE_NAME"
        
        print_status "Webapp started successfully!"
        print_status "Container: $CONTAINER_NAME"
        print_status "Port: $PORT"
        print_status "URL: http://localhost:$PORT"
        ;;
        
    "stop")
        print_status "Stopping Brick X Webapp..."
        
        if docker ps -q -f name="$CONTAINER_NAME" | grep -q .; then
            docker stop "$CONTAINER_NAME"
            docker rm "$CONTAINER_NAME"
            print_status "Webapp stopped and removed."
        else
            print_warning "Container $CONTAINER_NAME is not running."
        fi
        ;;
        
    "restart")
        print_status "Restarting Brick X Webapp..."
        "$0" stop
        sleep 2
        "$0" start
        ;;
        
    "status")
        print_status "Checking Brick X Webapp status..."
        
        if docker ps -q -f name="$CONTAINER_NAME" | grep -q .; then
            echo -e "${GREEN}✓ Container is running${NC}"
            docker ps --filter name="$CONTAINER_NAME" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
            
            # Test endpoint
            if command -v curl >/dev/null 2>&1; then
                response=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:$PORT/" 2>/dev/null || echo "000")
                if [ "$response" = "200" ]; then
                    echo -e "${GREEN}✓ Webapp is accessible${NC}"
                else
                    echo -e "${RED}✗ Webapp is not accessible (HTTP $response)${NC}"
                fi
            fi
        else
            echo -e "${RED}✗ Container is not running${NC}"
            
            # Check if container exists but stopped
            if docker ps -a -q -f name="$CONTAINER_NAME" | grep -q .; then
                echo -e "${YELLOW}Container exists but stopped${NC}"
                docker ps -a --filter name="$CONTAINER_NAME" --format "table {{.Names}}\t{{.Status}}"
            fi
        fi
        ;;
        
    "logs")
        if docker ps -q -f name="$CONTAINER_NAME" | grep -q .; then
            docker logs "$CONTAINER_NAME" "${@:2}"
        else
            print_error "Container $CONTAINER_NAME is not running."
            exit 1
        fi
        ;;
        
    "build")
        print_status "Building Brick X Webapp..."
        cd "$PROJECT_ROOT"
        ./scripts/build.sh
        ;;
        
    "clean")
        print_status "Cleaning Brick X Webapp..."
        
        # Stop and remove container
        "$0" stop
        
        # Remove image
        if docker image inspect "$IMAGE_NAME" >/dev/null 2>&1; then
            docker rmi "$IMAGE_NAME"
            print_status "Image removed."
        fi
        ;;
        
    "help"|"-h"|"--help"|*)
        echo -e "${BLUE}======================================${NC}"
        echo -e "${BLUE}Brick X Webapp - Management${NC}"
        echo -e "${BLUE}======================================${NC}"
        echo -e ""
        echo -e "${GREEN}Commands:${NC}"
        echo -e "  ${YELLOW}start${NC}   - Start the webapp container"
        echo -e "  ${YELLOW}stop${NC}    - Stop and remove the container"
        echo -e "  ${YELLOW}restart${NC} - Restart the service"
        echo -e "  ${YELLOW}status${NC}  - Show container status and health"
        echo -e "  ${YELLOW}logs${NC}    - Show container logs"
        echo -e "  ${YELLOW}build${NC}   - Build the Docker image"
        echo -e "  ${YELLOW}clean${NC}   - Stop container and remove image"
        echo -e "  ${YELLOW}help${NC}    - Show this help"
        echo -e ""
        echo -e "${BLUE}Configuration:${NC}"
        echo -e "  Container: $CONTAINER_NAME"
        echo -e "  Image: $IMAGE_NAME"
        echo -e "  Port: $PORT"
        echo -e "  Network: $NETWORK_NAME"
        echo -e ""
        echo -e "${BLUE}======================================${NC}"
        ;;
esac