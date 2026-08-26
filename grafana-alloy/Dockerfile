ARG BUILD_FROM=ghcr.io/home-assistant/base:latest
FROM ${BUILD_FROM}

ARG ALLOY_VERSION=v1.19.0
ARG TARGETARCH

# Map HA arch naming to Grafana's release asset naming and install the pinned binary
# directly from the official GitHub release (grafana/alloy) rather than layering the
# full grafana/alloy image, so it composes cleanly with the HA base image's s6-overlay init.
RUN set -eu; \
    case "${TARGETARCH}" in \
      amd64) ALLOY_ARCH="amd64" ;; \
      arm64) ALLOY_ARCH="arm64" ;; \
      *) echo "Unsupported architecture: ${TARGETARCH}" >&2; exit 1 ;; \
    esac; \
    curl -fsSL -o /tmp/alloy.zip \
      "https://github.com/grafana/alloy/releases/download/${ALLOY_VERSION}/alloy-linux-${ALLOY_ARCH}.zip" && \
    unzip -q /tmp/alloy.zip -d /tmp/alloy-extract && \
    install -m 0755 /tmp/alloy-extract/alloy-linux-${ALLOY_ARCH} /usr/bin/alloy && \
    rm -rf /tmp/alloy.zip /tmp/alloy-extract

COPY rootfs /
