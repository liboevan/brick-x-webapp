#!/bin/bash

# Generate RSA key pairs for brick-x-auth-service and brick-x-webapp
# This script generates private and public keys for JWT signing/validation

set -e

# Source shared configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}" )" && pwd)"
source "$SCRIPT_DIR/config.sh"

print_header "Generating RSA Key Pairs"

# Create directories if they don't exist
mkdir -p ../../brick-x-auth-service

print_info "Generating brick-x-auth-service private key..."
openssl genrsa -out ../../brick-x-auth-service/private.pem 2048

print_info "Generating brick-x-auth-service public key..."
openssl rsa -in ../../brick-x-auth-service/private.pem -pubout -out ../../brick-x-auth-service/public.pem

print_info "Generating brick-x-webapp public key (for nginx JWT validation)..."
cp ../../brick-x-auth-service/public.pem ../public.pem

print_info "Setting proper permissions..."
chmod 600 ../../brick-x-auth-service/private.pem
chmod 644 ../../brick-x-auth-service/public.pem
chmod 644 ../public.pem

print_info "Key generation completed successfully!"
echo ""
print_info "Generated files:"
echo "  - brick-x-auth-service/private.pem (JWT signing)"
echo "  - brick-x-auth-service/public.pem (JWT verification)"
echo "  - public.pem (Nginx JWT validation)"
echo ""
print_warning "Remember to update brick-x-auth-service config to use the private key!"
print_warning "Remember to update nginx.conf to use the public key for JWT validation!" 