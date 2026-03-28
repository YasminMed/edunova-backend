# Force Rebuild - SPA Routing Fix - 2026-03-28
# Stage 1: Build Flutter Web
FROM debian:latest AS build-env

# Install dependencies (cached if unchanged)
RUN apt-get update && \
    apt-get install -y curl git wget unzip gdb libstdc++6 libglu1-mesa fonts-droid-fallback lib32stdc++6 python3 && \
    apt-get clean

# Clone Flutter SDK (cached if unchanged)
RUN git clone https://github.com/flutter/flutter.git -b stable /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Pre-warm Flutter
RUN flutter doctor && flutter config --enable-web

WORKDIR /app

# Cache Flutter dependencies
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Build the project
COPY . .
RUN flutter build web --release

# Stage 2: Runtime Environment (FastAPI)
FROM python:3.11-slim

WORKDIR /app

# Cache backend dependencies
COPY edunova-backend/requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copy backend code
COPY edunova-backend/ .

# Copy built frontend from build-env
COPY --from=build-env /app/build/web ./static

EXPOSE 8080

# Execute server using Python for robust port handling
CMD ["python", "main.py"]