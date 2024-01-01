FROM docker.io/library/debian:12-slim AS builder

RUN apt update && \
    apt install -y build-essential curl ca-certificates git libssl-dev libsqlite3-dev pkg-config && \
    rm -rf /var/lib/apt/lists*

# Here we don't split the build separete stages, because building them in parallel may exceed Fly's memory limit

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain none && \
    cd /root && \
    git clone https://github.com/dani-garcia/vaultwarden.git -b 1.30.1 && \
    cd vaultwarden && \
    ~/.cargo/bin/cargo build --features sqlite --release

RUN mkdir /root/.nodejs && \
    curl -L https://nodejs.org/dist/v18.19.0/node-v18.19.0-linux-x64.tar.gz | tar -C /root/.nodejs -xzf - --strip-components 1 && \
    cd /root && \
    git clone https://github.com/dani-garcia/bw_web_builds.git && \
    cd bw_web_builds && \
    PATH="/root/.nodejs/bin:$PATH" VAULT_VERSION=web-v2023.12.0 make full

RUN mkdir /root/.golang && \
    curl -L https://go.dev/dl/go1.21.1.linux-amd64.tar.gz | tar -C /root/.golang -xzf - --strip-components 1 && \
    cd /root && \
    git clone https://github.com/rclone/rclone.git -b v1.65.0 && \
    cd rclone && \
    ~/.golang/bin/go build

FROM docker.io/library/debian:12-slim

RUN apt update && \
    apt install -y cron curl ca-certificates sqlite3 && \
    curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb && \
    dpkg -i cloudflared.deb && \
    rm cloudflared.deb && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir /root/data

COPY --from=builder /root/vaultwarden/target/release/vaultwarden /usr/local/bin/vaultwarden
COPY --from=builder /root/rclone/rclone /usr/local/bin/rclone
COPY --from=builder /root/bw_web_builds/builds/bw_web_browser-v2023.12.0 /root/web-vault
COPY --chmod=0755 --chown=0:0 backup.sh /backup.sh
COPY --chmod=0755 --chown=0:0 entrypoint.sh /entrypoint.sh

RUN echo "0 * * * * root /backup.sh >/proc/1/fd/1 2>&1" >/etc/cron.d/vaultwarden-backup

ENTRYPOINT ["/entrypoint.sh"]
