#!/bin/bash

PROJECT_DIR="/home/alok/projects/my-new-project"
BACKUP_DIR="$PROJECT_DIR/backups"
LOG_FILE="$PROJECT_DIR/logs/backup.log"
DATE=$(date "+%Y-%m-%d_%H-%M-%S")
BACKUP_FILE="$BACKUP_DIR/fullstack_backup_$DATE.tar.gz"

mkdir -p "$BACKUP_DIR"

# Trigger Redis save to disk before backup
docker compose -f "$PROJECT_DIR/docker-compose.yml" exec -T redis-db redis-cli SAVE > /dev/null 2>&1

# Create compressed archive excluding backups and logs folders
tar --exclude="$BACKUP_DIR" --exclude="$PROJECT_DIR/logs" -czf "$BACKUP_FILE" -C "/home/alok/projects" "my-new-project"

if [ $? -eq 0 ]; then
    echo "[$DATE] SUCCESS: Backup created at $BACKUP_FILE" >> "$LOG_FILE"
else
    echo "[$DATE] ERROR: Backup failed!" >> "$LOG_FILE"
    exit 1
fi

# Retention Policy: Delete backups older than 7 days
find "$BACKUP_DIR" -type f -name "*.tar.gz" -mtime +7 -exec rm -f {} \;
echo "[$DATE] CLEANUP: Old backups (>7 days) pruned." >> "$LOG_FILE"
