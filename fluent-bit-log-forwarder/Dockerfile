# https://developers.home-assistant.io/docs/apps/configuration#app-dockerfile
ARG FLUENT_BIT_VERSION=3.2.5
# Debian-based: upstream Fluent Bit ships a glibc-dynamically-linked binary,
# which isn't compatible with the musl-based Alpine HA base images.
ARG BUILD_FROM=ghcr.io/home-assistant/base-debian:bookworm

FROM fluent/fluent-bit:${FLUENT_BIT_VERSION} AS fluent-bit

FROM ${BUILD_FROM}

# Fluent Bit binary, pinned via FLUENT_BIT_VERSION above.
COPY --from=fluent-bit /fluent-bit/bin/fluent-bit /usr/bin/fluent-bit

RUN \
    apt-get update \
    && apt-get install --no-install-recommends -y \
        curl \
        jq \
        libyaml-0-2 \
        libpq5 \
    && rm -rf /var/lib/apt/lists/*

# Copy root filesystem
COPY rootfs /

LABEL \
    org.opencontainers.image.title="Home Assistant App: Fluent Bit Log Forwarder" \
    org.opencontainers.image.description="Collect Home Assistant Core, Host, Supervisor, and app logs and forward them to Grafana Loki via Fluent Bit." \
    org.opencontainers.image.source="https://github.com/carlba/hassio-addons" \
    org.opencontainers.image.licenses="Apache License 2.0"
