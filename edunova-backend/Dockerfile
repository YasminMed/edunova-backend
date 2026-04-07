# Optimized Backend Dockerfile for Standalone Repository
FROM python:3.11-slim

WORKDIR /app

# Install system dependencies for PDF generation and other needs
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Cache dependencies
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copy backend code
COPY . .

# Ensure required directories exist
RUN mkdir -p static uploads

EXPOSE 8080

# Run with uvicorn
CMD ["python", "main.py"]
