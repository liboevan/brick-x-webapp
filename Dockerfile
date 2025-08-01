# Multi-stage build for Vue.js TypeScript application
FROM node:20.10-alpine as build-stage

# Set working directory
WORKDIR /app

# Copy package files and source code together
COPY . .

# Install dependencies
RUN npm install
RUN npm ls --depth=0 && cat package-lock.json

# Set version and build datetime
ARG VERSION=0.1.0-dev
ARG BUILD_DATETIME
ENV VERSION=$VERSION
ENV BUILD_DATETIME=$BUILD_DATETIME

# Build the application
RUN npm run build

# Create VERSION file
RUN echo "$VERSION" > /app/VERSION

# Create build-info.json
RUN echo "{\"version\":\"$VERSION\",\"buildDateTime\":\"$BUILD_DATETIME\",\"buildTimestamp\":$(date +%s),\"environment\":\"production\",\"service\":\"brick-x-webapp\",\"description\":\"Web Application\"}" > /app/build-info.json

# Production stage
FROM ghcr.io/max-lt/nginx-jwt-module:latest as production-stage

# Install required packages
RUN apk add --no-cache \
    openssl \
    curl \
    wget

# Copy nginx configuration
COPY nginx/nginx.conf /etc/nginx/nginx.conf

# Copy public key for JWT validation from project root
COPY public.pem /etc/nginx/public.pem

# Copy built application
COPY --from=build-stage /app/dist /usr/share/nginx/html

# Copy VERSION and build-info.json from build stage
COPY --from=build-stage /app/VERSION /VERSION
COPY --from=build-stage /app/build-info.json /build-info.json

# Remove default nginx configuration that conflicts with our config
RUN rm -f /etc/nginx/conf.d/default.conf

# Expose port
EXPOSE 17107

# Start nginx
CMD ["nginx", "-g", "daemon off;"]