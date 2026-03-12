#!/bin/bash
# Matrix Postgres Backup Script
# Dumps all databases, keeps last 7 days of backups
# Run via cron: 0 3 * * * /srv/matrix/postgres-backup.sh

set -euo pipefail

BACKUP_DIR="/srv/matrix/backups"
CONTAINER="postgres"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
RETENTION_DAYS=7

mkdir -p "$BACKUP_DIR"

echo "[$(date)] Starting Postgres backup..."

# Dump all databases
for DB in synapse mas mm-matrix-bridge; do
    OUTFILE="${BACKUP_DIR}/${DB}_${TIMESTAMP}.sql.gz"
    docker exec "$CONTAINER" pg_dump -U synapse -d "$DB" 2>/dev/null | gzip > "$OUTFILE"
    if [ -s "$OUTFILE" ]; then
        echo "  OK: $DB → $(du -h "$OUTFILE" | cut -f1)"
    else
        echo "  SKIP: $DB (empty or not found)"
        rm -f "$OUTFILE"
    fi
done

# Clean old backups
find "$BACKUP_DIR" -name "*.sql.gz" -mtime +${RETENTION_DAYS} -delete
echo "[$(date)] Backup complete. Files in $BACKUP_DIR:"
ls -lh "$BACKUP_DIR"/*.sql.gz 2>/dev/null | tail -10
