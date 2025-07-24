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

# Function to show help
show_help() {
    echo -e "${BLUE}======================================${NC}"
    echo -e "${BLUE}Brick X WebApp - Stop Script${NC}"
    echo -e "${BLUE}======================================${NC}"
    echo -e ""
    echo -e "${GREEN}Purpose:${NC}"
    echo -e "  Stop the webapp container"
    echo -e ""
    echo -e "${GREEN}Usage:${NC}"
    echo -e "  $0 [options]"
    echo -e ""
    echo -e "${GREEN}Options:${NC}"
    echo -e "  ${YELLOW}--remove${NC}  - Remove container after stopping"
    echo -e "  ${YELLOW}--help${NC}     - Show this help"
    echo -e ""
    echo -e "${BLUE}Configuration:${NC}"
    echo -e "  Container: $CONTAINER_NAME"
    echo -e ""
    echo -e "${BLUE}Other Commands:${NC}"
    echo -e "  • Start: ${YELLOW}./scripts/start.sh${NC}"
    echo -e "  • Status: ${YELLOW}docker ps --filter name=$CONTAINER_NAME${NC}"
    echo -e "  • Clean: ${YELLOW}./scripts/clean.sh${NC}"
    echo -e "${BLUE}======================================${NC}"
}

# Function to stop the service
stop_service() {
    local remove_container=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --remove)
                remove_container=true
                shift
                ;;
            --help|-h|-help)
                show_help
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
    
    print_status "Stopping Brick X WebApp..."
    
    # Check if container is running
    if docker ps -q -f name="$CONTAINER_NAME" | grep -q .; then
        print_status "Stopping container..."
        docker stop "$CONTAINER_NAME"
        print_status "Container stopped successfully"
        
        if [ "$remove_container" = true ]; then
            print_status "Removing container..."
            docker rm "$CONTAINER_NAME"
            print_status "Container removed successfully"
        fi
    else
        print_warning "Container $CONTAINER_NAME is not running."
        
        # Check if container exists but stopped
        if docker ps -a -q -f name="$CONTAINER_NAME" | grep -q .; then
            print_status "Container exists but stopped"
            if [ "$remove_container" = true ]; then
                print_status "Removing stopped container..."
                docker rm "$CONTAINER_NAME"
                print_status "Container removed successfully"
            fi
        else
            print_warning "Container $CONTAINER_NAME does not exist."
        fi
    fi
}

# Main execution
if [[ $# -eq 0 ]]; then
    stop_service
else
    stop_service "$@"
fi