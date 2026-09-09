# https://developers.home-assistant.io/docs/apps/configuration#app-dockerfile
ARG FLUENT_BIT_VERSION=5.1.2
# Debian-based: upstream Fluent Bit ships a glibc-dynamically-linked binary,
# which isn't compatible with the musl-based Alpine HA base images. Trixie
# (Debian 13) is required because this Fluent Bit version needs glibc 2.38+,
# newer than bookworm's 2.36.
ARG BUILD_FROM=ghcr.io/home-assistant/base-debian:trixie

FROM fluent/fluent-bit:${FLUENT_BIT_VERSION} AS fluent-bit

FROM ${BUILD_FROM}

# Fluent Bit binary, pinned via FLUENT_BIT_VERSION above.
COPY --from=fluent-bit /fluent-bit/bin/fluent-bit /usr/bin/fluent-bit

RUN \
    apt-get update \
    && apt-get install --no-install-recommends -y \
        tzdata \
        libyaml-0-2 \
        python3 \
        python3-pip \
    && pip3 install --no-cache-dir --break-system-packages jinja2-cli \
    && rm -rf /var/lib/apt/lists/*

# Copy root filesystem
COPY rootfs /

LABEL \
    org.opencontainers.image.title="Home Assistant App: Fluent Bit Log Forwarder" \
    org.opencontainers.image.description="Collect Home Assistant Core, Host, Supervisor, and app logs and forward them to Grafana Loki via Fluent Bit." \
    org.opencontainers.image.source="https://github.com/carlba/hassio-addons" \
    org.opencontainers.image.licenses="Apache License 2.0"
