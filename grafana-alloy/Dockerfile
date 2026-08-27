FROM ghcr.io/home-assistant/base-debian:latest

ARG ALLOY_VERSION=v1.19.0
ARG BUILD_ARCH

RUN apt-get update && apt-get install -y --no-install-recommends \
    unzip ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Map HA arch naming to Grafana's release asset naming and install the pinned binary
# directly from the official GitHub release (grafana/alloy).
RUN set -eu; \
    case "${BUILD_ARCH}" in \
      amd64) ALLOY_ARCH="amd64" ;; \
      aarch64) ALLOY_ARCH="arm64" ;; \
      *) echo "Unsupported architecture: ${BUILD_ARCH}" >&2; exit 1 ;; \
    esac; \
    curl -fsSL -o /tmp/alloy.zip \
      "https://github.com/grafana/alloy/releases/download/${ALLOY_VERSION}/alloy-linux-${ALLOY_ARCH}.zip" && \
    unzip -q /tmp/alloy.zip -d /tmp && \
    install -m 0755 /tmp/alloy-linux-${ALLOY_ARCH} /usr/bin/alloy && \
    rm -f /tmp/alloy.zip /tmp/alloy-linux-${ALLOY_ARCH}

LABEL \
  io.hass.version="${ALLOY_VERSION}" \
  io.hass.type="app" \
  io.hass.arch="${BUILD_ARCH}"

COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
