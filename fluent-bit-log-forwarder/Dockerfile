# https://developers.home-assistant.io/docs/apps/configuration#app-dockerfile
ARG FLUENT_BIT_VERSION=3.2.5
ARG BUILD_FROM=ghcr.io/home-assistant/base:3.23

FROM --platform=$TARGETPLATFORM fluent/fluent-bit:${FLUENT_BIT_VERSION} AS fluent-bit

FROM ${BUILD_FROM}

# Statically-linked Fluent Bit binary, pinned via FLUENT_BIT_VERSION above
COPY --from=fluent-bit /fluent-bit/bin/fluent-bit /usr/bin/fluent-bit

RUN \
    apk add --no-cache \
        curl \
        jq \
        file \
    && file /usr/bin/fluent-bit \
    && /usr/bin/fluent-bit --version \
    && apk del file

# Copy root filesystem
COPY rootfs /

LABEL \
    org.opencontainers.image.title="Home Assistant App: Fluent Bit Log Forwarder" \
    org.opencontainers.image.description="Collect Home Assistant Core, Host, Supervisor, and app logs and forward them to Grafana Loki via Fluent Bit." \
    org.opencontainers.image.source="https://github.com/carlba/hassio-addons" \
    org.opencontainers.image.licenses="Apache License 2.0"
