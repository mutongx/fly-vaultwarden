#!/bin/bash
set -x
COPY="rclone --config /root/rclone.conf --s3-no-check-bucket -v copy"
BACKUP_ID="$(date +%Y-%m-%d-%H-%M-%S-%s)"
sqlite3 /root/data/db.sqlite3 ".backup $BACKUP_ID.sqlite3"
while IFS= read -r REMOTE; do
    $COPY "$BACKUP_ID.sqlite3" "$REMOTE"
    $COPY "/root/data/attachments" "$REMOTE/attachments"
    $COPY "/root/data/sends" "$REMOTE/sends"
done </root/backup.conf
rm "$BACKUP_ID.sqlite3"
