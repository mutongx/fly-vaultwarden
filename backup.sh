#!/bin/bash
set -x
COPY="echo /root/rclone/rclone --s3-no-check-bucket -v copy"
BACKUP_ID="$(date +%Y-%m-%d-%H-%M-%S-%s)"
sqlite3 /root/vaultwarden/data/db.sqlite3 ".backup $BACKUP_ID.sqlite3"
while IFS= read -r REMOTE; do
    $COPY "$BACKUP_ID.sqlite3" "$REMOTE"
    $COPY "/root/vaultwarden/data/attachments" "$REMOTE/attachments"
    $COPY "/root/vaultwarden/data/sends" "$REMOTE/sends"
done </root/.backup
rm "$BACKUP_ID.sqlite3"
