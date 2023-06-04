#!/bin/bash

set -e

test -n "$CLOUDFLARED_SERVICE_TOKEN" || (echo '$CLOUDFLARED_SERVICE_TOKEN is not set' && exit 1)

cloudflared service install "$CLOUDFLARED_SERVICE_TOKEN"

cd /root/vaultwarden
exec /root/vaultwarden/vaultwarden
