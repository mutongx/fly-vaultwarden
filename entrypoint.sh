#!/bin/bash

set -e

test -n "$CLOUDFLARED_SERVICE_TOKEN" || (echo '$CLOUDFLARED_SERVICE_TOKEN is not set' && exit 1)

mkdir -p /root/.config/rclone
echo "$RCLONE_CONFIG_CONTENT" >/root/.config/rclone/rclone.conf

echo "$BACKUP_RCLONE_REMOTES" >/root/.backup
cron

cloudflared service install "$CLOUDFLARED_SERVICE_TOKEN"

export _ENABLE_DUO=true

cd /root/vaultwarden
exec /root/vaultwarden/vaultwarden
