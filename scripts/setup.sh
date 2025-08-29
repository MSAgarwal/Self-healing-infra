#!/bin/bash

# Self-Healing Infrastructure Setup Script
set -e

echo "🚀 Setting up Self-Healing Infrastructure..."

# Check prerequisites
command -v docker >/dev/null 2>&1 || { echo "Docker is required but not installed. Aborting." >&2; exit 1; }
command -v docker-compose >/dev/null 2>&1 || { echo "Docker Compose is required but not installed. Aborting." >&2; exit 1; }

# Create necessary directories
echo "📁 Creating directory structure..."
mkdir -p {prometheus,alertmanager,ansible/{playbooks,roles},webhook,nginx,scripts,monitoring/grafana/dashboards,logs}

# Set permissions
chmod +x scripts/*.sh
chmod 600 ansible/inventory.ini

# Build and start services
echo "🐳 Building and starting services..."
docker-compose up --build -d

# Wait for services to be ready
echo "⏳ Waiting for services to be ready..."
sleep 30

# Check service health
echo "🔍 Checking service health..."
services=("nginx:80" "prometheus:9090" "alertmanager:9093" "webhook-handler:8080" "grafana:3000")

for service in "${services[@]}"; do
    IFS=':' read -r name port <<< "$service"
    if curl -f -s http://localhost:$port/health >/dev/null 2>&1 || curl -f -s http://localhost:$port >/dev/null 2>&1; then
        echo "✅ $name is healthy"
    else
        echo "❌ $name is not responding"
    fi
done

echo "📊 Service URLs:"
echo "- Prometheus: http://localhost:9090"
echo "- Alertmanager: http://localhost:9093"
echo "- Grafana: http://localhost:3000 (admin/admin123)"
echo "- NGINX: http://localhost:80"
echo "- Webhook Handler: http://localhost:8080/health"

echo "✅ Setup completed successfully!"
echo "🧪 Run './scripts/test-recovery.sh' to test the self-healing functionality"