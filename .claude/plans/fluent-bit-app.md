# Fluent Bit log-forwarding app for Home Assistant OS

## Context

The user wants a Home Assistant "app" (formerly "add-on"; HA renamed the concept in the
2026.2 release) that runs Fluent Bit inside Home Assistant OS to collect various Home
Assistant logs and forward them to a Grafana Loki instance. This repo
(`carlba/hassio-addons`) is a brand-new apps repository containing only
`repository.yaml` and a placeholder `README.md` — there is no existing app to copy
conventions from, so the new app must follow the official HA docs and the official
`home-assistant/apps-example` template repo exactly, plus Fluent Bit's own docs for the
Fluent Bit configuration itself.

Decisions confirmed with the user:
- **Destination:** Grafana Loki (`loki` output plugin).
- **Log scope:** Home Assistant Core log, Supervisor log, Host log, and other apps'
  container logs — i.e. as broad as HAOS permissions allow.
- **Direction:** Forwarder only, no ingestion listener.
- **Configurability:** HA UI options schema (`config.yaml` `options`/`schema`), not a
  raw mounted `fluent-bit.conf`.

### Key platform constraints discovered during research (with sources)

1. **HA Core log file** (`home-assistant.log`) is reachable by mounting the config
   directory via `map: - type: homeassistant_config, read_only: true`. This mount is
   the *only* way to reach that file (no host `/var/log` mount exists for apps).
   Source: https://developers.home-assistant.io/docs/apps/configuration/

2. **Supervisor, Host, and other-apps' logs are NOT available as files or via
   journald.** HAOS does not expose `/var/log` or the host journal to an app, and
   `docker_api` access (the only way to reach raw container logs directly) is
   explicitly documented as intended for tools like Portainer, requiring the app's
   protection mode to be disabled — a heavier, discouraged permission we should not
   request for a log shipper. The **sanctioned path** is the Supervisor REST API,
   reachable at `http://supervisor/...` with `Authorization: Bearer $SUPERVISOR_TOKEN`,
   gated by the `hassio_api: true` + `hassio_role: admin` config options:
   - `GET /core/logs` (+ `/follow`, `/latest`, `/boots/<id>[/follow]`) — HA Core logs
   - `GET /host/logs` (+ same suffixes) — Host/OS journal logs
   - `GET /addons/<slug>/logs` (+ same suffixes) — any app's own container logs,
     including apps other than this one
   - There is no separate `/supervisor/logs` endpoint; Supervisor's own log stream is
     retrieved via `/host/logs` (Supervisor runs as a container on the host journal) —
     this project will treat "Supervisor logs" and "Host logs" as one input covered by
     `/host/logs`.
   - Format is plain text (one line per record) by default; `Range: entries=...`
     supports journald-cursor paging, and a simpler `lines` query param sets how many
     recent lines to fetch. `/follow` endpoints keep the HTTP connection open for
     streaming.
   - `admin` is the role level confirmed to work; the docs don't break out a lower role
     specifically for reading *other* apps' logs, so `admin` is used rather than
     guessing at a narrower role that might 403.
   Source: https://developers.home-assistant.io/docs/api/supervisor/endpoints/,
   https://developers.home-assistant.io/docs/apps/configuration/

3. **Fluent Bit has no HTTP-poll/client input plugin** — its `http` input is
   server-mode only (opens a listening port for others to push to). The correct input
   for polling a REST endpoint on an interval is **`exec`**, running `curl` against the
   Supervisor API and emitting the response as a log record. This is the standard,
   documented way to bridge an HTTP data source into Fluent Bit when no native input
   exists. Source: https://docs.fluentbit.io/manual (pipeline/inputs: `exec`, `http`).

4. **App file layout and conventions** are taken directly from the current official
   template, `home-assistant/apps-example` (fetched live from GitHub, since the docs
   site's own tutorial only shows the 3-file minimal example): `config.yaml`,
   `Dockerfile`, `apparmor.txt`, `icon.png`/`logo.png`, `DOCS.md`, `README.md`,
   `CHANGELOG.md`, `translations/en.yaml`, and an s6-overlay service under
   `rootfs/etc/services.d/<name>/{run,finish}`. There is **no `build.yaml`** in the
   current template — the base image is selected via Dockerfile `ARG BUILD_FROM` and
   `TARGETARCH`, built with Docker Buildx (multi-arch), matching the pattern in
   `example/Dockerfile`.

## Implementation plan

Create a new app directory `fluent-bit-log-forwarder/` (slug: `fluent_bit_log_forwarder`)
alongside `repository.yaml`, following `example/` from `apps-example` file-for-file in
structure.

### 1. `fluent-bit-log-forwarder/config.yaml`

```yaml
name: Fluent Bit Log Forwarder
version: "0.1.0"
slug: fluent_bit_log_forwarder
description: Collect Home Assistant Core, Host, Supervisor, and app logs and forward them to Grafana Loki via Fluent Bit
url: "https://github.com/carlba/hassio-addons/tree/main/fluent-bit-log-forwarder"
arch:
  - aarch64
  - amd64
init: false
hassio_api: true
hassio_role: admin
map:
  - type: homeassistant_config
    read_only: true
options:
  loki_url: "http://loki:3100"
  loki_tenant_id: ""
  collect_core_log: true
  collect_host_log: true
  collect_supervisor_log: true
  collect_addon_logs: true
  poll_interval_seconds: 15
schema:
  loki_url: "url"
  loki_tenant_id: "str?"
  collect_core_log: "bool"
  collect_host_log: "bool"
  collect_supervisor_log: "bool"
  collect_addon_logs: "bool"
  poll_interval_seconds: "int(5,300)"
image: "ghcr.io/carlba/fluent-bit-log-forwarder"
```

Each `collect_*` toggle and the interval are read by the `run` script (via
`bashio::config`) and used to decide which `[INPUT]` blocks get rendered into
`fluent-bit.conf`, so users can disable sources they don't want without editing config
files directly.

### 2. `fluent-bit-log-forwarder/Dockerfile`

Mirror `example/Dockerfile`'s `ARG BUILD_FROM` / `TARGETARCH` / `tempio` pattern, but
install Fluent Bit instead of a custom binary. Since Fluent Bit publishes its own Alpine
package and official multi-arch images, evaluate at implementation time whether to
`FROM` the HA base image and `apk add fluent-bit` (if available in the base's Alpine
repos) versus copying the Fluent Bit binary from `fluent/fluent-bit:<pinned-version>`
in a multi-stage build — prefer whichever gives a pinned, reproducible Fluent Bit
version. Add `curl` and `jq` (used by the `exec` input's helper script). Copy `rootfs/`
last, as in the template.

### 3. `fluent-bit-log-forwarder/rootfs/`

- `etc/services.d/fluent-bit/run` — a `bashio`-based script that:
  - Reads all `options` via `bashio::config`.
  - Renders `/etc/fluent-bit/fluent-bit.conf` from a template (simple `sed`/heredoc is
    fine given the small number of variables — no need for `tempio` unless the base
    image already provides it for other purposes), enabling/disabling `[INPUT]`
    sections per the `collect_*` toggles.
  - `exec`s `fluent-bit -c /etc/fluent-bit/fluent-bit.conf`.
- `etc/services.d/fluent-bit/finish` — copy the template's `finish` script verbatim
  (halts the s6 supervision tree on non-zero, non-256 exit).
- `etc/fluent-bit/parsers.conf` (optional) — a parser for HA's log line format
  (`YYYY-MM-DD HH:MM:SS.mmm LEVEL (thread) [component] message`) so Loki gets
  structured labels (`level`, `component`) instead of one opaque line, using Fluent
  Bit's `regex` parser type. This is worth doing since it's the main value-add over
  just cat-ing logs at Loki.

### 4. Fluent Bit pipeline design (rendered into `fluent-bit.conf`)

- One `[INPUT]` of `Name exec` per enabled log source, each running `curl` against the
  Supervisor API with `Authorization: Bearer ${SUPERVISOR_TOKEN}` (this env var is
  auto-injected into apps that set `hassio_api: true`), tagged distinctly
  (`ha.core`, `ha.host`, `ha.addon.<slug>`), at `Interval_Sec` from
  `poll_interval_seconds`.
  - Core: `curl -s -H "Authorization: Bearer ${SUPERVISOR_TOKEN}" http://supervisor/core/logs/latest`
  - Host/Supervisor: `curl -s -H "Authorization: Bearer ${SUPERVISOR_TOKEN}" http://supervisor/host/logs/latest`
  - Other apps: for `collect_addon_logs`, first resolve the list of installed apps via
    `GET /addons` (also Supervisor API), then loop `curl` per slug against
    `/addons/<slug>/logs/latest`. This needs a small wrapper script (e.g.
    `/etc/fluent-bit/scripts/poll-addon-logs.sh`) rather than a one-line `Command`,
    since it must fan out to a dynamic list of slugs — the `exec` input's `Command`
    just calls this script.
- One `[FILTER]` (`Name parser` or `Name modify`) per input tag to attach a `job`/
  `source` label matching the tag, plus apply the HA log-line regex parser where
  applicable.
- One `[OUTPUT]` of `Name loki`, `Match *`, `Host`/`Port`/`Tls` derived from
  `loki_url`, `tenant_id` from `loki_tenant_id` (omitted if empty), and `Labels`
  built from the record's `job`/`source`/`level` fields so logs are queryable in
  Grafana by source and severity.

Since polling with `exec` re-fetches `/latest` on every interval, the `run` script (or
a small stateful wrapper) needs simple de-duplication (e.g. track the last seen
journald cursor per source and use the `Range` header on subsequent polls instead of
re-reading from `/latest` every time) to avoid re-shipping the same lines repeatedly.
This is the trickiest correctness piece and should be implemented and tested carefully
— worth a quick manual verification against a running HAOS instance once built.

### 5. Supporting files

- `apparmor.txt` — start from `example/apparmor.txt`, add file access needed by
  `fluent-bit`, `curl`, `jq`, and the wrapper scripts under `/etc/fluent-bit/`; iterate
  using the `complain` flag + `journalctl _TRANSPORT="audit" -g 'apparmor="ALLOWED"'`
  technique the template comments describe.
- `translations/en.yaml` — human-readable name/description for every `options`/`schema`
  key (`loki_url`, `loki_tenant_id`, each `collect_*` toggle, `poll_interval_seconds`).
- `DOCS.md` — explain what the app does, required Loki setup, and what each option
  configures.
- `README.md`, `CHANGELOG.md` (starting at `## 0.1.0 - Initial release`), `icon.png`,
  `logo.png` — same purpose as in the template.
- Update root `README.md` to list the new app (matching how `apps-example`'s root
  README lists `example/`).

### 6. CI (optional follow-up, not blocking first version)

The template repo's `.github/workflows/build-app.yaml`, `builder.yaml`, and
`lint.yaml` provide the reference pattern for multi-arch build/publish and linting.
Recommend adding equivalent workflows in a follow-up once the app itself works
end-to-end locally, rather than bundling CI into the first pass.

## Verification

1. Local lint: validate `config.yaml` against the schema conventions above (no
   automated linter available without CI, so a careful manual review is the first
   gate).
2. Build the image locally for at least one target arch (`docker buildx build --platform
   linux/amd64 --build-arg BUILD_FROM=... .`) and confirm it starts and Fluent Bit
   parses its config without error (`fluent-bit -c ... -e` dry-run style check, or just
   run and watch for immediate crash/parse errors in logs).
3. Install the repository on a real (or test) Home Assistant OS instance via
   Supervisor → Apps → Repositories, install this app, and confirm:
   - The app starts (Supervisor log shows the s6 service running, no apparmor denials).
   - With `collect_core_log` on, Core log lines arrive in Loki with the right labels.
   - With `collect_host_log` on, Host/Supervisor log lines arrive.
   - With `collect_addon_logs` on, at least one other installed app's logs arrive.
   - Restarting the app does not cause duplicate log floods (cursor-based
     de-duplication works).
   - Toggling a `collect_*` option off in the UI and restarting stops that source
     without breaking the others.
4. Check Grafana/Loki directly (`{job="ha_core"}`-style LogQL query) to confirm labels
   and content are usable, not just "did it not crash."
