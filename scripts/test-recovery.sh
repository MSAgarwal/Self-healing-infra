#!/bin/bash

# Comprehensive testing script for self-healing functionality
set -e

echo "🧪 Testing Self-Healing Infrastructure..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test functions
test_service_health() {
    local service=$1
    local port=$2
    local url="http://localhost:$port"
    
    if curl -f -s $url >/dev/null 2>&1; then
        echo -e "${GREEN}✅ $service is healthy${NC}"
        return 0
    else
        echo -e "${RED}❌ $service is not healthy${NC}"
        return 1
    fi
}

wait_for_alert() {
    local alert_name=$1
    local max_wait=$2
    local count=0
    
    echo "⏳ Waiting for alert '$alert_name' to trigger..."
    
    while [ $count -lt $max_wait ]; do
        if curl -s http://localhost:9090/api/v1/alerts | grep -q "$alert_name"; then
            echo -e "${GREEN}✅ Alert '$alert_name' triggered${NC}"
            return 0
        fi
        sleep 5
        count=$((count + 5))
        echo -n "."
    done
    
    echo -e "${RED}❌ Alert '$alert_name' did not trigger within ${max_wait}s${NC}"
    return 1
}

wait_for_recovery() {
    local service=$1
    local port=$2
    local max_wait=$3
    local count=0
    
    echo "⏳ Waiting for $service recovery..."
    
    while [ $count -lt $max_wait ]; do
        if test_service_health $service $port; then
            echo -e "${GREEN}✅ $service recovered automatically${NC}"
            return 0
        fi
        sleep 5
        count=$((count + 5))
        echo -n "."
    done
    
    echo -e "${RED}❌ $service did not recover within ${max_wait}s${NC}"
    return 1
}

# Test