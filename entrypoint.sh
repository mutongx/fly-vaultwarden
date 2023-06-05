#!/bin/bash

set -e

test -n "$CLOUDFLARED_SERVICE_TOKEN" || (echo '$CLOUDFLARED_SERVICE_TOKEN is not set' && exit 1)

mkdir -p /root/.config/rclone
echo "$RCLONE_CONFIG_CONTENT" >/root/.config/rclone/rclone.conf

cloudflared service install "$CLOUDFLARED_SERVICE_TOKEN"

cd /root/vaultwarden
exec /root/vaultwarden/vaultwarden
