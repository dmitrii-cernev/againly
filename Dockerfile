# Multi-stage Dockerfile for Flutter Web App

# Stage 1: Build environment
FROM alpine:3.19 AS build-env

# Install dependencies and Flutter SDK in a single layer
RUN apk add --no-cache \
  curl \
  git \
  unzip \
  xz \
  zip \
  bash \
  gcompat \
  && git clone https://github.com/flutter/flutter.git /flutter

ENV PATH="/flutter/bin:/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Configure Flutter and run doctor in a single layer
RUN flutter config --enable-web \
  && flutter doctor -v

# Set working directory
WORKDIR /app

# Copy pubspec files and get dependencies
COPY pubspec.* ./
RUN flutter pub get

# Copy the entire project
COPY . .

# Generate Hive adapters (non-interactive)
RUN dart run build_runner build --delete-conflicting-outputs

# Build the web app for production
RUN flutter build web --release

# Stage 2: Production environment
FROM nginx:alpine

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Copy the built web app from the build stage
COPY --from=build-env /app/build/web /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
