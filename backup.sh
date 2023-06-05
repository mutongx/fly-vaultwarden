#!/bin/bash
BACKUP_ID="$(date +%Y-%m-%d-%H-%M-%S-%s)"
for REMOTE in ${RCLONE_BACKUP_REMOTES//,/ }; do
    /root/rclone/rclone copy /root/vaultwarden/data "$REMOTE/$BACKUP_ID"
done
