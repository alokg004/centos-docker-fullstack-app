#!/bin/bash

PROJECT_DIR="/home/alok/projects/my-new-project"
LOG_FILE="$PROJECT_DIR/logs/self_heal.log"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

cd "$PROJECT_DIR" || exit 1

# 1. Check Docker Daemon
if ! systemctl is-active --quiet docker; then
    echo "[$TIMESTAMP] CRITICAL: Docker service down. Restarting Docker..." >> "$LOG_FILE"
    sudo systemctl restart docker
    sleep 5
fi

# 2. Check if any container in docker-compose is exited/down
DOWN_CONTAINERS=$(docker compose ps --services --filter "status=exited")

if [ -n "$DOWN_CONTAINERS" ]; then
    echo "[$TIMESTAMP] ALERT: Containers down ($DOWN_CONTAINERS). Recovering stack..." >> "$LOG_FILE"
    docker compose up -d >> "$LOG_FILE" 2>&1
    echo "[$TIMESTAMP] RECOVERED: Multi-container stack restored." >> "$LOG_FILE"
fi

# 3. Check Web & API Endpoint Health (HTTP 200 check)
WEB_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080)
API_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:5000)

if [ "$WEB_STATUS" != "200" ] || [ "$API_STATUS" != "200" ]; then
    echo "[$TIMESTAMP] WARNING: Health check failed (Web: $WEB_STATUS, API: $API_STATUS). Restarting services..." >> "$LOG_FILE"
    docker compose restart >> "$LOG_FILE" 2>&1
    echo "[$TIMESTAMP] RECOVERED: Services restarted after health check failure." >> "$LOG_FILE"
else
    echo "[$TIMESTAMP] OK: All services healthy (Web: 200, API: 200)." >> "$LOG_FILE"
fi
