# Home Assistant App: Fluent Bit Log Forwarder

## How to use

This app runs [Fluent Bit](https://fluentbit.io/) inside Home Assistant OS
and forwards logs to a Grafana Loki instance:

- Home Assistant Core log (`home-assistant.log`)
- Host / OS journal log
- Supervisor log (read from the same journal as the Host log, but labeled
  separately)
- The container logs of every other installed app

Logs are read from the [Supervisor API](https://developers.home-assistant.io/docs/api/supervisor/endpoints/)
on a configurable poll interval by a `supervisor-poller` service, written to
local files, and tailed from there by Fluent Bit before being pushed to
Loki via its `loki` output plugin. A persisted line-count cursor per source
avoids re-shipping the same lines on every poll or after a restart.

Fluent Bit's `exec` input (a poll-and-run-a-command plugin) was deliberately
not used to reach the Supervisor API directly: it is compiled out of
Fluent Bit's official production images (they ship without `/bin/sh`) and
its own docs flag it as a shell-injection risk when command output includes
untrusted content, which log lines are. Polling happens in a plain shell
loop instead, and Fluent Bit only ever reads local files via `tail`.

**Startup note:** on start, Fluent Bit reads any content already present in
each source file (verified via `tail`'s SQLite offset database, which
persists across restarts so already-shipped lines are never re-sent). New
content becomes available to tail once the `supervisor-poller` service
writes it, bounded by `poll_interval_seconds`.

## Configuration

### Option: `loki_host`

Hostname of your Grafana Loki instance, e.g. `loki` or `logs-prod-006.grafana.net`.

### Option: `loki_port`

Port of your Grafana Loki instance, e.g. `3100` for a local instance or
`443` for most hosted instances.

### Option: `loki_tls`

Whether to connect over TLS. Enable for hosted Loki instances such as
Grafana Cloud.

### Option: `loki_uri`

Path of the Loki push API, e.g. `/loki/api/v1/push`.

### Option: `loki_tenant_id`

Optional Loki tenant (`X-Scope-OrgID`) to send with each push request.
Leave empty for a single-tenant Loki instance.

### Option: `loki_user` / `loki_password`

Optional HTTP basic auth credentials, required by hosted Loki instances
such as Grafana Cloud (`loki_user` is the Grafana Cloud instance ID,
`loki_password` is an API key). Leave both empty if your Loki instance
doesn't require auth.

### Option: `collect_core_log`

Forward the Home Assistant Core log. Requires the app to mount the Home
Assistant config directory (already configured), since that's the only way
to reach `home-assistant.log`.

### Option: `collect_host_log`

Forward the Host/OS journal log via `GET /host/logs` on the Supervisor API.

### Option: `collect_supervisor_log`

Forward the Supervisor log. There is no separate Supervisor log endpoint —
Supervisor's own log stream lives in the same Host journal — so this reads
from `GET /host/logs` as well, but ships as its own tag/label so it can be
filtered independently in Grafana.

### Option: `collect_addon_logs`

Forward the container logs of every other installed app, discovered via
`GET /addons` and fetched per-app via `GET /addons/<slug>/logs`.

### Option: `poll_interval_seconds`

How often, in seconds, to poll the Supervisor API for new log lines.
Must be between 5 and 300.

### Option: `logs_timezone`

IANA timezone name (e.g. `Europe/Stockholm`) that the Home Assistant Core
log's timestamps are written in. Home Assistant Core writes
`home-assistant.log` in local time with no UTC offset in the string, so this
tells Fluent Bit's parser the correct offset to convert them to UTC before
shipping to Loki. The offset is resolved once when the `fluent-bit` service
(re)starts, so it reflects standard or daylight time correctly as of that
moment. Leave as `UTC` (the default) if Core's timestamps are already UTC.
Only affects Core log parsing — the Host, Supervisor, and app log sources
are stamped with real time as they're tailed, so they're unaffected.

## Required permissions

This app requests `hassio_api: true` with `hassio_role: admin` in order to
read Core, Host, and other apps' logs through the Supervisor API. `admin`
is used because the Supervisor API docs don't document a narrower role
guaranteed to read other apps' logs.

## Querying in Grafana

Each log source is shipped with a `job` label (`ha_core`, `ha_host`,
`ha_supervisor`, `ha_addon`) and a `source` label, so you can query e.g.:

```logql
{job="ha_core"}
{job="ha_addon"} |= "error"
```

Core log lines are additionally parsed for `level` and `component` fields
using Home Assistant's standard log line format.
