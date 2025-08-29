#!/bin/bash

# Script to simulate various failures for testing
set -e

echo "🔥 Simulating failures for testing..."

case "$1" in
    "nginx")
        echo "Stopping NGINX container..."
        docker stop nginx-target || true
        echo "✅ NGINX stopped. Check Prometheus alerts in ~30 seconds."
        ;;
    "cpu")
        echo "Simulating high CPU usage..."
        docker exec nginx-target sh -c '
            for i in {1..4}; do
                yes > /dev/null &
            done
            echo "High CPU load started. It will run for 3 minutes..."
            sleep 180
            killall yes
        ' &
        echo "✅ High CPU simulation started."
        ;;
    "memory")
        echo "Simulating high memory usage..."
        docker exec nginx-target sh -c '
            # Allocate 512MB of memory
            python3 -c "
import time
data = []
for i in range(50):
    data.append(b'\''x'\'' * 10485760)  # 10MB chunks
    time.sleep(1)
    print(f'\''Allocated {(i+1)*10}MB'\'')
time.sleep(300)  # Keep memory allocated for 5 minutes
"
        ' &
        echo "✅ High memory simulation started."
        ;;
    "disk")
        echo "Simulating disk space issues..."
        docker exec nginx-target sh -c '
            dd if=/dev/zero of=/tmp/bigfile bs=1M count=100
            echo "Created 100MB file to simulate disk usage"
        '
        echo "✅ Disk space simulation completed."
        ;;
    *)
        echo "Usage: $0 {nginx|cpu|memory|disk}"
        echo "  nginx  - Stop NGINX container"
        echo "  cpu    - Simulate high CPU usage"
        echo "  memory - Simulate high memory usage"
        echo "  disk   - Simulate disk space issues"
        exit 1
        ;;
esac

echo "📊 Monitor the alerts at:"
echo "- Prometheus: http://localhost:9090/alerts"
echo "- Alertmanager: http://localhost:9093"
echo "- Webhook logs: docker logs webhook-handler"