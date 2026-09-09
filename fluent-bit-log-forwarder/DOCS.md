# Home Assistant App: Fluent Bit Log Forwarder

## How to use

This app runs [Fluent Bit](https://fluentbit.io/) inside Home Assistant OS and forwards logs to a
Grafana Loki instance.

Logs are read directly from the system journal (`/var/log/journal`) via Fluent Bit's `systemd`
input, which covers the Host/OS log, the Supervisor log, and the container logs of every other
installed app — all of these already land in the journal. A `DB` offset file under `/data` tracks
the read position across restarts, so already-shipped entries are never re-sent.

## Configuration

### Option: `loki_host`

Hostname of your Grafana Loki instance, e.g. `loki` or `logs-prod-006.grafana.net`.

### Option: `loki_port`

Port of your Grafana Loki instance, e.g. `3100` for a local instance or `443` for most hosted
instances.

### Option: `loki_tls`

Whether to connect over TLS. Enable for hosted Loki instances such as Grafana Cloud.

### Option: `loki_uri`

Path of the Loki push API, e.g. `/loki/api/v1/push`.

### Option: `loki_tenant_id`

Optional Loki tenant (`X-Scope-OrgID`) to send with each push request. Leave empty for a
single-tenant Loki instance.

### Option: `loki_user` / `loki_password`

Optional HTTP basic auth credentials, required by hosted Loki instances such as Grafana Cloud
(`loki_user` is the Grafana Cloud instance ID, `loki_password` is an API key). Leave both empty if
your Loki instance doesn't require auth.

### Option: `logs_timezone`

IANA timezone name (e.g. `Europe/Stockholm`) that the Home Assistant Core log's timestamps are
written in. Home Assistant Core writes `home-assistant.log` in local time with no UTC offset in the
string, so this tells Fluent Bit's parser the correct offset to convert them to UTC before shipping
to Loki. The offset is resolved once when the `fluent-bit` service (re)starts, so it reflects
standard or daylight time correctly as of that moment. Leave as `UTC` (the default) if Core's
timestamps are already UTC.

## Querying in Grafana

Every journal entry is shipped with a `job=homeassistant` label, plus whatever journal fields Fluent
Bit surfaces (`syslog_identifier`, `container_name`, `level`, etc.), so you can query e.g.:

```logql
{job="homeassistant"}
{job="homeassistant"} |= "error"
```

Filter to a specific source by its journal fields, e.g. a single app's container logs:

```logql
{job="homeassistant", container_name="addon_a0d7b954_tailscale"}
```
