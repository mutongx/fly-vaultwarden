#!/bin/bash
for REMOTE in ${RCLONE_BACKUP_REMOTES//,/ }; do
    /root/rclone/rclone copy /root/vaultwarden/data "$REMOTE/$(date +%Y-%m-%d-%H-%M-%S-%s)"
done
