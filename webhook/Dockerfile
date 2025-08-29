FROM python:3.9-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    openssh-client \
    sshpass \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install -r requirements.txt

# Install Ansible
RUN pip install ansible docker

# Copy application
COPY webhook-handler.py .

# Create necessary directories
RUN mkdir -p /app/logs /app/ansible

# Run the application
CMD ["python", "webhook-handler.py"]