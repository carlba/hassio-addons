# Grafana Alloy Home Assistant App

## Context

The user wants a custom Home Assistant OS "app" (the current official term — Home Assistant
renamed "add-ons" to "apps" in the 2026.2 release; developer docs now live at
`developers.home-assistant.io/docs/apps/`) that runs Grafana Alloy for telemetry collection,
forwarding metrics via Prometheus remote_write. It will live as a new folder in the existing
`hassio-addons` repository (which already has a valid `repository.yaml`), not a separate repo.

This plan is based on live-verified current documentation (fetched 2026-08-26), not training
memory. Two points from the original request needed correction after research:

1. **"Add-ons" → "Apps" rename**: current docs, schema, and folder layout use "app"
   terminology; `/docs/add-ons/*` URLs now redirect/404.
2. **No multiline-textarea schema type exists** for app Configuration options. The user was
   informed this is a documented, unresolved community gap (real config-heavy apps like Samba/File
   Editor/SSH avoid it via direct file access) and explicitly chose to proceed anyway with a
   single `str` schema option for the Alloy config, accepting the risk. To keep this from being a
   dead end in practice, the plan adds a safety net: the app always writes a working default
   config to `/data/alloy/config.alloy` on first boot, and if the user-supplied `str` option is
   non-empty it overwrites that file before Alloy starts — so a newline-mangling failure in the
   options UI degrades to "edit the file another way," not "app won't start."

## Verified facts driving the design

**Home Assistant apps** (source: developers.home-assistant.io/docs/apps/{repository,configuration,tutorial,presentation}, github.com/home-assistant/addons-example):
- `repository.yaml` schema: `name` (required), `url`, `maintainer` (optional) — existing file is already valid, no changes needed.
- Per-app folder: `config.yaml` (required), `Dockerfile` (required), `apparmor.txt` (recommended), `README.md`, `CHANGELOG.md`, `icon.png` (128×128), `logo.png` (~250×100), `rootfs/etc/services.d/<name>/{run,finish}` for s6 services.
- `build.yaml` is **deprecated and no longer read**. Base image is selected via `ARG BUILD_FROM=...` + `FROM ${BUILD_FROM}` directly in the Dockerfile, pinned to a version tag.
- `config.yaml` required keys: `name`, `version`, `slug`, `description`, `arch` (list, includes `aarch64`, `amd64`).
- `init: false` is required when the base image already has its own init (s6-overlay) — must be set or the app won't start.
- `startup`: one of `initialize`, `system`, `services`, `application` (default), `once`. Since Alloy is a standalone telemetry forwarder with no dependents in HA, `services` fits (starts before Home Assistant, appropriate for infra-style background services) — using `services` rather than default `application`.
- `boot: auto` — required for "start automatically with Home Assistant."
- `ports`: omit entirely for no exposed ports (Alloy's HTTP/debug UI stays loopback-only by default, matching "no unnecessary ports").
- `/data` is **always** mapped and writable without needing a `map` entry — this is where `/data/alloy` will live.
- `options`/`schema` types: `str`, `str(min,max)`/`str(min,)`/`str(,max)`, `bool`, `int`, `float`, `email`, `url`, `password`, `port`, `match(regex)`, `list(...)`, `device`. No multiline/textarea type — confirmed via live docs and an open community feature request.
- User options are read in service scripts via `bashio::config 'key'` (shebang `#!/usr/bin/with-contenv bashio`), backed by `/data/options.json`.
- Current long-running-process pattern is s6-overlay `services.d` (not a hand-rolled shell loop): a `run` script that ends in `exec <program>` (so the program becomes the supervised PID for correct signal handling), and a `finish` script controlling restart-vs-halt behavior on exit — this directly satisfies "run in the foreground and restart it if it exits."
- Recommended base image family: `ghcr.io/home-assistant/base:<pinned-version>`.

**Grafana Alloy** (source: grafana.com/docs/alloy/latest/{reference/cli/run,reference/components/prometheus/prometheus.remote_write,set-up/install/docker,get-started/configuration-syntax}, raw Dockerfile on github.com/grafana/alloy main, GitHub Releases API):
- Latest stable release: **v1.19.1** (published 2026-08-26).
- Official image: `grafana/alloy` on Docker Hub, multi-arch (linux/amd64, linux/arm64) — confirmed via the official Dockerfile's `TARGETOS`/`TARGETARCH` cross-compilation and Docker Hub listing. No GHCR mirror.
- Config language is now called **Alloy configuration syntax**, file extension **`.alloy`** (River naming/`​.river` extension no longer appears anywhere in current docs or the official Dockerfile).
- CLI invocation: `alloy run <config-path> [flags]`. Official image's own default: `run /etc/alloy/config.alloy --storage.path=/var/lib/alloy/data`.
- `--storage.path` is the base directory for component state; `prometheus.remote_write` automatically creates its own WAL subdirectory under it — no separate WAL flag needed. This plan points it at `/data/alloy` (the HA-persistent directory) instead of the image's default `/var/lib/alloy/data`.
- HTTP/debug server defaults to `127.0.0.1:12345` (loopback-only) — safe to leave untouched, satisfies "no unnecessary ports" (no `--server.http.listen-addr=0.0.0.0...` override, no `ports:` in config.yaml).
- `prometheus.remote_write "<label>" { endpoint { url = "..." } }` is the minimal working block for remote-write-only telemetry.
- The official image runs as **root by default** (an `alloy` uid 473 user exists in the image but is intentionally not set as `USER`, per an explicit Dockerfile comment calling non-root support experimental/undocumented) — this app will follow the official image's default (root) rather than fighting it, since HA apps commonly run as root already via `init: false` + s6.
- Config file is read-only from Alloy's perspective (only `--storage.path` is written to) — safe to mount/copy the config read-only-ish (still on a writable `/data` volume, but Alloy itself never writes to it).
- SIGTERM shutdown has a **known, not-fully-confirmed-fixed** rough edge (grafana/alloy#1980 — some setups needed SIGKILL after Docker's default 10s grace period). The s6 `finish` script pattern handles this natively (s6 sends SIGTERM, waits, escalates) so no custom handling is needed beyond that default behavior — but this is noted as a limitation to flag in the README, not hidden.

## Repository layout

```
hassio-addons/
├── repository.yaml                      (existing, unchanged)
└── grafana-alloy/
    ├── config.yaml                      Home Assistant app manifest
    ├── Dockerfile                       Copies official grafana/alloy binary layer, adds s6 service
    ├── apparmor.txt                     Minimal AppArmor profile
    ├── icon.png                         128x128 (Grafana Alloy mark, if a suitable asset can be sourced under license; otherwise omitted — flagged as a limitation, not fabricated)
    ├── logo.png                         ~250x100 (same caveat)
    ├── README.md                        Install/config/storage/update/troubleshooting
    ├── CHANGELOG.md                     keepachangelog.com format, starting entry
    └── rootfs/
        └── etc/
            └── services.d/
                └── alloy/
                    ├── run              Writes config from options if provided, execs alloy
                    └── finish           s6 restart/halt handling on exit
```

Plus, at the repo root:
```
.github/
└── workflows/
    └── check-alloy-release.yml         Scheduled workflow: checks grafana/alloy GitHub releases,
                                          opens a PR bumping ALLOY_VERSION + config.yaml version
                                          when a newer release is found (uses peter-evans/create-pull-request,
                                          a widely-used standard action for this exact pattern)
```

## Design details

### `grafana-alloy/config.yaml`
```yaml
name: Grafana Alloy
version: "1.19.1"
slug: grafana_alloy
description: Runs Grafana Alloy to collect and forward telemetry via Prometheus remote_write
url: https://github.com/carlba/hassio-addons/tree/main/grafana-alloy
arch:
  - aarch64
  - amd64
init: false
startup: services
boot: auto
options:
  alloy_config: ""
schema:
  alloy_config: "str?"
```
- No `ports:` key — zero exposed ports.
- No `map:` key — `/data` is implicitly available and writable.
- `alloy_config` is optional (`str?`); when empty, the app runs with a safe built-in default config (a `prometheus.remote_write` stub pointing at a placeholder URL, clearly documented as needing edit — no hard-coded real endpoint/credentials).

### `grafana-alloy/Dockerfile`
```dockerfile
ARG BUILD_FROM=ghcr.io/home-assistant/base:3.23
FROM ${BUILD_FROM}

ARG ALLOY_VERSION=v1.19.1
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

CMD [ "/init" ]
```
- Uses the HA base image (has s6-overlay + bashio already) as the foundation, and installs the **official pinned Alloy binary** from Grafana's GitHub release assets — this is the documented, verifiable way to get an exact pinned version onto an HA base image (mirroring `grafana/alloy` directly would mean layering two competing init systems, which is unnecessary complexity for a single binary).
- `ALLOY_VERSION` is a single, easy-to-bump build arg, kept in sync with `config.yaml`'s `version` by the update workflow.
- **Needs validation during implementation**: confirming the exact current release asset filename pattern (`alloy-linux-<arch>.zip`) against a live GitHub release listing for v1.19.1 before finalizing — will verify by fetching the release assets list, not assumed.

### `grafana-alloy/rootfs/etc/services.d/alloy/run`
```bash
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

bashio::log.info "Starting Grafana Alloy ${ALLOY_VERSION:-}"
exec /usr/bin/alloy run "${CONFIG_FILE}" --storage.path=/data/alloy/data
```
- `exec` hands off to Alloy as the supervised PID — s6 handles restart-on-exit via `finish`.
- `--storage.path=/data/alloy/data` keeps WAL/component state under the persistent `/data/alloy` tree as required.
- Falls back safely if the `str` option mangles newlines: the default file is written first and only overwritten if the option is non-empty, and the README will document editing the file directly (e.g. via the Samba/SSH/File Editor apps the user may already have) as the reliable fallback path.

### `grafana-alloy/rootfs/etc/services.d/alloy/finish`
Standard HA s6 finish-script pattern (log exit code, let s6-overlay's default supervision restart the service unless explicitly halted) — will follow the exact pattern from the current official `addons-example` repo's `finish` script rather than inventing one.

### `.github/workflows/check-alloy-release.yml`
- Scheduled (e.g. daily) workflow that queries the GitHub Releases API for `grafana/alloy`, compares the latest tag to `ALLOY_VERSION` in the Dockerfile, and if newer, opens a PR updating `ALLOY_VERSION` (Dockerfile) and `version` (config.yaml) together.
- Kept deliberately simple: no auto-merge, no auto-build — just a PR for the user to review, matching the "pinned + automated PR" preference.

### README.md contents
- What the app is / architecture diagram (text)
- Installation (add repository URL, install app)
- Configuration (the `alloy_config` option, its known limitation with multiline input, and the recommended fallback of editing `/data/alloy/config.alloy` directly via Samba/SSH/File Editor if pasted config doesn't survive the options UI)
- Storage (what lives under `/data/alloy`, that it persists across restarts/updates)
- Updating (how version bumps flow from the GitHub Action PR)
- Troubleshooting (checking logs, the known Alloy SIGTERM/shutdown caveat, verifying remote_write connectivity)

## Validation to perform during implementation

- `yamllint`/manual review of `config.yaml` and the GitHub Actions workflow YAML.
- Shellcheck on `run`/`finish` scripts.
- Verify the exact Grafana Alloy v1.19.1 release asset filenames via the GitHub releases API before finalizing the Dockerfile's download URL (flagged above as not yet confirmed).
- `docker buildx build --platform linux/amd64,linux/arm64` (or per-arch builds) to confirm the Dockerfile builds cleanly for both architectures — will attempt locally if Docker/buildx is available; if not possible in this environment, will state that explicitly as a limitation rather than claiming it was tested.
- Confirm `config.yaml` against the schema fields verified above (no invented keys).
- Sanity-check the Alloy default config block against the `prometheus.remote_write` syntax verified from live docs.

## Known limitations to disclose in the final summary

- Multiline config via the `str` options field is unverified/at-risk per community reports; the file-based fallback under `/data/alloy/config.alloy` is the reliable path.
- Grafana Alloy's SIGTERM shutdown has a reported (not confirmed fixed) rough edge in some environments (grafana/alloy#1980); relying on s6/Docker's default SIGTERM→SIGKILL escalation rather than custom handling.
- `icon.png`/`logo.png` will be omitted unless a properly licensed asset can be sourced — will not fabricate placeholder branding assets.
- Full multi-arch Docker build validation depends on local Docker/buildx availability at implementation time.
