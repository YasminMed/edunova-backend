# Force Rebuild - Optimized Production Build - 15:09:30 - 2026-04-07
# Stage 1: Build Flutter Web
FROM ghcr.io/cirruslabs/flutter:stable AS build-layer

WORKDIR /app

# Cache dependencies
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

# Copy built frontend from build-layer
COPY --from=build-layer /app/build/web ./static

EXPOSE 8080

# Execute server using Python for robust port handling
CMD ["python", "main.py"]