#!/bin/bash

set -ueo pipefail

for FILE in .env rclone.conf backup.conf; do
    curl -fsSL -u "$VAULTWARDEN_CONFIG_AUTH" "$VAULTWARDEN_CONFIG_BASE/$FILE" \
    | curl -fsSL --data-binary @- -H "Authorization: Bearer $VAULTWARDEN_SECRET_TOKEN" -X POST "$VAULTWARDEN_SECRET_URL" \
    >"/root/$FILE"
done

cron

cloudflared service install "$CLOUDFLARED_SERVICE_TOKEN"

cd /root
exec vaultwarden
