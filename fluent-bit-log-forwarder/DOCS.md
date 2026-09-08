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
by a `supervisor-poller` service, which opens one long-lived streaming
connection per source against that source's `/logs/follow` endpoint and
appends new lines straight into local files as they arrive. Fluent Bit
tails those files and pushes new content to Loki via its `loki` output
plugin. If a stream drops (Supervisor restart, connection reset, etc.),
`supervisor-poller` restarts only that stream — other sources are
unaffected.

Fluent Bit's `exec` input (a run-a-command plugin) was deliberately not
used to reach the Supervisor API directly: it is compiled out of Fluent
Bit's official production images (they ship without `/bin/sh`) and its own
docs flag it as a shell-injection risk when command output includes
untrusted content, which log lines are. Streaming happens via background
`curl` processes instead, and Fluent Bit only ever reads local files via
`tail`.

**Startup note:** on start, Fluent Bit reads any content already present in
each source file (verified via `tail`'s SQLite offset database, which
persists across restarts so already-shipped lines are never re-sent). The
installed-app list for `collect_addon_logs` is fetched once when
`supervisor-poller` starts; an app installed afterward is picked up on the
next app restart.

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

Forward the Host/OS journal log via `GET /host/logs/follow` on the
Supervisor API.

### Option: `collect_supervisor_log`

Forward the Supervisor log via `GET /supervisor/logs/follow` on the
Supervisor API.

### Option: `collect_addon_logs`

Forward the container logs of every other installed app, discovered via
`GET /addons` and streamed per-app via `GET /addons/<slug>/logs/follow`.

### Option: `poll_interval_seconds`

Unused — log sources are streamed rather than polled. Kept for backward
compatibility with existing configurations.

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
