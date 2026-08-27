#!/usr/bin/with-contenv bashio

mkdir -p /data/alloy

CONFIG_FILE=/data/alloy/config.alloy

if [ ! -f "${CONFIG_FILE}" ]; then
    bashio::log.info "Writing default Alloy configuration to ${CONFIG_FILE}"
    cat > "${CONFIG_FILE}" <<'EOF'
// Default Grafana Alloy configuration.
// Edit this via the app's Configuration option, or directly on disk under /data/alloy/config.alloy.
prometheus.remote_write "default" {
  endpoint {
    url = "https://REPLACE_ME.example.com/api/prom/push"
  }
}
EOF
fi

USER_CONFIG="$(bashio::config 'alloy_config')"
if [ -n "${USER_CONFIG}" ] && [ "${USER_CONFIG}" != "null" ]; then
    bashio::log.info "Applying Alloy configuration from app options"
    printf '%s\n' "${USER_CONFIG}" > "${CONFIG_FILE}"
fi

bashio::log.info "Starting Grafana Alloy"
bashio::log.info "Testing alloy binary..."
/usr/bin/alloy version || bashio::log.error "Alloy version check failed"
exec /usr/bin/alloy run "${CONFIG_FILE}" --storage.path=/data/alloy/data
