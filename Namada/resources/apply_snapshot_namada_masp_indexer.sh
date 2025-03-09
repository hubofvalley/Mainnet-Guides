#!/bin/bash
set -euo pipefail

# Configuration
INDEXER_DIR="$HOME/namada-indexer"
SNAPSHOT_URL="https://masp-indexer-snapshot-mainnet-namada.grandvalleys.com/masp_indexer_snapshot.sql"
BACKUP_FILE="indexer_backup_$(date +%Y%m%d%H%M%S).sql"
SNAPSHOT_FILE="masp_indexer_snapshot.sql"

# User confirmation
echo "Indexer Snapshot Update Script"
echo "-------------------------------"
echo "This script will:"
echo "1. Create a database backup"
echo "2. Download the latest snapshot"
echo "3. Refresh the database"
echo "4. Restart services"
echo -e "\nA backup will be created before any changes are made."

read -p "Would you like to continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Operation cancelled - no changes made"
    exit 0
fi

# Check dependencies
check_deps() {
    for cmd in docker wget git; do
        if ! command -v "$cmd" &> /dev/null; then
            echo "Required command missing: $cmd"
            exit 1
        fi
    done
}
check_deps

# Main execution
cd "$INDEXER_DIR" || { echo "Indexer directory not found: $INDEXER_DIR"; exit 1; }

# Docker compose helper function
dc_exec() {
    docker compose exec -T postgres "$@"
}

# Create backup
echo "Creating database backup..."
docker compose up -d postgres
sleep 5 # Wait for PostgreSQL initialization

if ! dc_exec pg_dump -Fc -p 5433 --dbname="namada-indexer" --file="/tmp/$BACKUP_FILE"; then
    echo "Backup creation failed"
    exit 1
fi

docker compose cp postgres:/tmp/"$BACKUP_FILE" ./"$BACKUP_FILE"
if [ ! -f "$BACKUP_FILE" ]; then
    echo "Backup verification failed"
    exit 1
fi
echo "Backup created: $BACKUP_FILE"

# Download snapshot
echo "Downloading latest snapshot..."
rm -f "$SNAPSHOT_FILE"
if ! wget -O "$SNAPSHOT_FILE" "$SNAPSHOT_URL"; then
    echo "Snapshot download failed"
    exit 1
fi

# Stop services
echo "Stopping services..."
docker compose down -v

# Restore snapshot
echo "Initializing database restore..."
docker compose up -d postgres
sleep 5 # Allow PostgreSQL to start

docker compose cp "$SNAPSHOT_FILE" postgres:/tmp/"$SNAPSHOT_FILE"

# Modified restore command to ignore exit status 1
echo "Restoring database (this may take several minutes)..."
set +e # Disable error trapping temporarily
dc_exec pg_restore -p 5433 -d namada-indexer --clean --if-exists -v "/tmp/$SNAPSHOT_FILE"
RESTORE_EXIT=$?
set -e # Re-enable error trapping

# Handle restore exit code specifically
if [ $RESTORE_EXIT -ne 0 ] && [ $RESTORE_EXIT -ne 1 ]; then
    echo "Critical error during restore (exit code $RESTORE_EXIT)"
    exit 1
else
    echo "Restore completed with exit code $RESTORE_EXIT - proceeding..."
fi

# Cleanup
echo "Cleaning temporary files..."
dc_exec rm -f "/tmp/$SNAPSHOT_FILE"
rm -f "$SNAPSHOT_FILE"

# Restart services
echo "Starting services..."
docker compose up -d

# Monitoring
echo "Service startup complete. Monitoring logs (Ctrl+C to exit)..."
docker logs --tail 50 -f namada-indexer-transactions-1

echo "Snapshot update process completed successfully"