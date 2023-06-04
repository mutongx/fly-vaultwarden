FROM docker.io/library/debian:11-slim AS vw-builder

RUN apt update && \
    apt install -y build-essential curl ca-certificates git libssl-dev libsqlite3-dev pkg-config && \
    rm -rf /var/lib/apt/lists*

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain none && \
    cd /root && \
    git clone https://github.com/dani-garcia/vaultwarden.git -b 1.28.1 && \
    cd vaultwarden && \
    ~/.cargo/bin/cargo build --features sqlite --release

# Here we don't split the web build into separete build stage, because building it in parallel may exceed Fly's memory limit
RUN mkdir /root/.nodejs && \
    curl -L https://nodejs.org/dist/v16.20.0/node-v16.20.0-linux-x64.tar.gz | tar -C /root/.nodejs -xzf - --strip-components 1 && \
    cd /root && \
    git clone https://github.com/dani-garcia/bw_web_builds.git -b v2023.5.0 && \
    cd bw_web_builds && \
    PATH="/root/.nodejs/bin:$PATH" VAULT_VERSION=web-v2023.5.0 make full

FROM docker.io/library/debian:11-slim

RUN apt update && \
    apt install -y curl ca-certificates make libsqlite3-0 && \
    curl -L --output cloudflared.deb https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb && \
    dpkg -i cloudflared.deb && \
    rm cloudflared.deb && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir /root/vaultwarden && \
    mkdir /root/vaultwarden/data

COPY --from=vw-builder /root/vaultwarden/target/release/vaultwarden /root/vaultwarden/vaultwarden
COPY --from=vw-builder /root/bw_web_builds/builds/bw_web_browser-v2023.5.0 /root/vaultwarden/web-vault
COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
