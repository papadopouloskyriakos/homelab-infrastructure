#!/bin/bash
# Script for safe mariabackup in Galera cluster with donor check and PBS sync
# Engineering: Runs only if node is synced (wsrep_local_state=4) to preserve HA quorum
# Administering: Logs errors for troubleshooting; exits if not synced or PBS fails
# Managing: Keeps the newest $KEEP_TARBALLS local tarballs (PBS holds the history); syncs /srv/backup to PBS post-backup
# 2026-10-04: prune moved BEFORE the backup + free-space precheck + failed raw dirs removed.
# A 7-day mtime prune (~9 x 6 G) plus the 19 G raw copy filled mariadb02's 99 G rootfs at
# 06:01 NL; mysqld aborted at 06:45 and Galera lost quorum.
# Configuration
BACKUP_DIR="/srv/backup/$(date +%Y%m%d)"
DB_USER="admin"
DB_PASS="REDACTED_35d23e90"
LOG_FILE="/var/log/mariadb-backup.log"
KEEP_TARBALLS=2
MIN_FREE_FACTOR_PCT=150  # free space must be >= 150% of the datadir
PBS_REPOSITORY="root@pam@nlpbs01:ds01"
export PBS_PASSWORD="Exng@n3d!g0lD"  # From file server script; secure in production

# Function to log messages
log() {
  echo "$(date +'%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Check if node is synced (wsrep_local_state=4)
WSREP_STATE=$(mariadb -u"$DB_USER" -p"$DB_PASS" -e 'SHOW STATUS LIKE "wsrep_local_state";' 2>/dev/null | awk '/wsrep_local_state/ {print $2}')
if [ "$WSREP_STATE" != "4" ]; then
  log "Node not synced (wsrep_local_state=$WSREP_STATE). Skipping backup to preserve HA."
  exit 1
fi

# Prune BEFORE the backup: leftover raw dirs from failed runs, then all but the newest tarballs
prune() {
  find /srv/backup/ -mindepth 1 -maxdepth 1 -type d -name '20*' ! -path "$BACKUP_DIR" -exec rm -rf {} +
  ls -1t /srv/backup/*.tar.gz 2>/dev/null | tail -n +$((KEEP_TARBALLS + 1)) | xargs -r rm -f
}
prune
log "Pruned to the newest $KEEP_TARBALLS tarballs."

# Free-space precheck: the raw copy is datadir-sized and the tarball needs room too
NEED_KB=$(( $(du -sk /var/lib/mysql | cut -f1) * MIN_FREE_FACTOR_PCT / 100 ))
FREE_KB=$(df -Pk /srv/backup | awk 'NR==2 {print $4}')
if [ "$FREE_KB" -lt "$NEED_KB" ]; then
  log "Not enough free space for a backup (free ${FREE_KB} KB < needed ${NEED_KB} KB). Skipping to protect mysqld."
  exit 1
fi

# Create backup dir
mkdir -p "$BACKUP_DIR"
if [ $? -ne 0 ]; then
  log "Failed to create backup directory $BACKUP_DIR."
  exit 1
fi

# Perform backup
log "Starting backup on synced node."
mariabackup --backup --target-dir="$BACKUP_DIR" --user="$DB_USER" --password="$DB_PASS" >> "$LOG_FILE" 2>&1
if [ $? -eq 0 ]; then
  log "Backup completed successfully to $BACKUP_DIR."
else
  log "Backup failed. Check mariabackup errors."
  rm -rf "$BACKUP_DIR"
  exit 1
fi

# Compress backup (optimization for storage)
tar -czf "$BACKUP_DIR.tar.gz" -C "$(dirname "$BACKUP_DIR")" "$(basename "$BACKUP_DIR")" && rm -rf "$BACKUP_DIR"
if [ $? -eq 0 ]; then
  log "Backup compressed to $BACKUP_DIR.tar.gz."
else
  log "Compression failed."
  exit 1
fi

# Prune again so only the newest tarballs remain
prune
log "Pruned to the newest $KEEP_TARBALLS tarballs."

# Sync to PBS (integrated from file server script; deduplicates for efficiency)
log "Starting sync to PBS repository: $PBS_REPOSITORY."
proxmox-backup-client backup mariadb-backups.pxar:/srv/backup --repository "$PBS_REPOSITORY" >> "$LOG_FILE" 2>&1
if [ $? -eq 0 ]; then
  log "PBS sync completed successfully."
else
  log "PBS sync failed. Check proxmox-backup-client errors (e.g., connectivity, auth)."
  exit 1
fi

exit 0
