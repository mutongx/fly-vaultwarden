#!/bin/bash
set -x
BACKUP_ID="$(date +%Y-%m-%d-%H-%M-%S-%s)"
for REMOTE in ${RCLONE_BACKUP_REMOTES//,/ }; do
    /root/rclone/rclone -v copy /root/vaultwarden/data "$REMOTE/$BACKUP_ID"
done
