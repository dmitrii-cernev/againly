# ---- Stage 1: Build (Debian-based to avoid musl issues) ----
FROM debian:bookworm-slim AS build-env

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
  ca-certificates curl git unzip xz-utils zip bash openssl \
  && rm -rf /var/lib/apt/lists/*

# Install Flutter (pin a version for reproducibility; adjust if you want latest)
ARG FLUTTER_VERSION=3.24.1
RUN git clone https://github.com/flutter/flutter.git /flutter \
  && cd /flutter && git checkout ${FLUTTER_VERSION}

ENV PATH="/flutter/bin:/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Enable web + cache artifacts (helps in CI/Docker)
RUN flutter config --enable-web \
  && flutter precache --web \
  && flutter doctor -v

WORKDIR /app

# Cache pub deps first (better build cache)
COPY pubspec.* ./
RUN flutter pub get

# Copy the rest of your app
COPY . .

# (Optional) codegen, if you use build_runner (you do)
RUN dart run build_runner build --delete-conflicting-outputs

# Build web release
RUN flutter build web --release

# ---- Stage 2: Runtime (Nginx) ----
FROM nginx:alpine

# Add curl so your docker-compose healthcheck works
RUN apk add --no-cache curl

# Copy custom nginx config (make sure this file exists in repo root)
COPY nginx.conf /etc/nginx/nginx.conf

# Copy built web assets
COPY --from=build-env /app/build/web /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]

