# Stage 1: Build Flutter Web
FROM debian:latest AS build-env

# Install dependencies
RUN apt-get update && \
    apt-get install -y curl git wget unzip gdb libstdc++6 libglu1-mesa fonts-droid-fallback lib32stdc++6 python3 && \
    apt-get clean

# Clone Flutter SDK
RUN git clone https://github.com/flutter/flutter.git -b stable /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Pre-download Flutter artifacts
RUN flutter doctor
RUN flutter config --enable-web

# Build the project
WORKDIR /app
COPY . .
RUN flutter pub get
RUN flutter build web --release

# Stage 2: Runtime Environment (FastAPI)
FROM python:3.11-slim

WORKDIR /app

# Install backend dependencies
# We copy from the root because we're in the monorepo root
COPY edunova-backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy backend code
COPY edunova-backend/ .

# Copy built frontend as static files
# We'll serve them from the 'static' directory in the backend
COPY --from=build-env /app/build/web ./static

# Ensure the database is initialized (optional but good for first run)
# RUN python populate_test_db.py

EXPOSE 8080

# The root Procfile is removed, so we use CMD directly
# Railway provides $PORT, handled internally in main.py
CMD ["python", "main.py"]
