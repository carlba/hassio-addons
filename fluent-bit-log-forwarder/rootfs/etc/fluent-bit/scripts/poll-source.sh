#!/usr/bin/with-contenv bashio
# ==============================================================================
# Poll a single Supervisor API log endpoint and emit only the lines that
# have not been emitted on a previous poll, using a persisted line-count
# cursor so restarts don't re-ship the whole buffer.
#
# Usage: poll-source.sh <supervisor-api-path> <cursor-name>
# ==============================================================================
set -uo pipefail

readonly SUPERVISOR_API="http://supervisor"
readonly AUTH_HEADER="Authorization: Bearer ${SUPERVISOR_TOKEN}"
readonly CURSOR_DIR="/data/cursors"

api_path="${1:?usage: poll-source.sh <api-path> <cursor-name>}"
cursor_name="${2:?usage: poll-source.sh <api-path> <cursor-name>}"
cursor_file="${CURSOR_DIR}/${cursor_name}"

mkdir -p "${CURSOR_DIR}"

body_file=$(mktemp)
trap 'rm -f "${body_file}"' EXIT

http_code=$(curl -s -o "${body_file}" -w '%{http_code}' -H "${AUTH_HEADER}" "${SUPERVISOR_API}${api_path}")
if [[ "${http_code}" != "200" ]]; then
    echo "poll-source.sh: GET ${api_path} failed with HTTP ${http_code}: $(cat "${body_file}")" >&2
    exit 1
fi

body=$(cat "${body_file}")
total=$(printf '%s\n' "${body}" | wc -l | tr -d ' ')
last=0
[[ -f "${cursor_file}" ]] && last=$(cat "${cursor_file}")

if [[ "${total}" -gt "${last}" ]]; then
    printf '%s\n' "${body}" | tail -n "+$((last + 1))"
fi

echo "${total}" > "${cursor_file}"
