#!/usr/bin/with-contenv bashio
# ==============================================================================
# Fetch new log lines for every installed app via the Supervisor API and
# emit them as "<slug>: <line>" records for Fluent Bit's exec input to tag
# and parse. Each app's stream gets its own persisted line-count cursor
# (via poll-source.sh) so restarts don't re-ship the whole buffer.
# ==============================================================================
set -uo pipefail

readonly SUPERVISOR_API="http://supervisor"
readonly AUTH_HEADER="Authorization: Bearer ${SUPERVISOR_TOKEN}"
readonly SCRIPT_DIR="/etc/fluent-bit/scripts"

slugs=$(curl -s -H "${AUTH_HEADER}" "${SUPERVISOR_API}/addons" \
    | jq -r '.data.addons[].slug')

for slug in ${slugs}; do
    "${SCRIPT_DIR}/poll-source.sh" "/addons/${slug}/logs" "addon-${slug}" \
        | sed "s/^/${slug}: /"
done
