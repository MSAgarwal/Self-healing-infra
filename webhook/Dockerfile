FROM python:3.9-slim

WORKDIR /app

# Install system dependencies (ssh + python runtime for Ansible modules)
RUN apt-get update && apt-get install -y \
    openssh-client \
    sshpass \
    python3 \
    python3-apt \
    && rm -rf /var/lib/apt/lists/*

# Copy Python dependencies
COPY requirements.txt .

# Install all Python packages (Ansible, Flask, Docker SDK, Requests)
RUN pip install --no-cache-dir -r requirements.txt

# Copy application
COPY webhook-handler.py .

# Create necessary directories
RUN mkdir -p /app/logs /app/ansible

# Run the application
CMD ["python", "webhook-handler.py"]
