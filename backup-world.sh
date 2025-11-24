#!/bin/bash
BACKUP_DIR=~/minecraft_backups
DATE=$(date +"%Y-%m-%d_%H%M")
mkdir -p "$BACKUP_DIR"

echo "Creating backup: world_backup_$DATE ..."
cp -r world world_nether world_the_end "$BACKUP_DIR/world_backup_$DATE"/
echo "Backup saved to $BACKUP_DIR/world_backup_$DATE"

# Keep only the last 10 backups
ls -1t "$BACKUP_DIR" | tail -n +11 | xargs -I {} rm -rf "$BACKUP_DIR"/{}
