# Grafana Alloy Home Assistant App

Runs [Grafana Alloy](https://grafana.com/docs/alloy/latest/) to collect and forward telemetry via Prometheus remote_write.

## Installation

1. Add this repository to Home Assistant:
   - Settings → System → Add-ons Repositories
   - Add: `https://github.com/carlba/hassio-addons`
2. Install the Grafana Alloy app from the add-ons store
3. Start the app

## Configuration

The app accepts an optional `alloy_config` option containing your Grafana Alloy configuration in Alloy syntax (`.alloy` format).

### Basic Example

```
prometheus.remote_write "prometheus" {
  endpoint {
    url = "https://prometheus.example.com/api/v1/write"
  }
}
```

### Known Limitation: Multiline Configuration

The configuration option in Home Assistant does not reliably preserve newlines in multiline text input. If your pasted configuration doesn't work after configuration, the file-based fallback below is the recommended approach.

### Fallback: Direct File Editing

If the configuration option doesn't work reliably, you can edit the configuration file directly:

1. Access `/data/alloy/config.alloy` via:
   - **Samba share** (if you have the Samba app installed)
   - **SSH** (if you have the SSH & Web Terminal app installed)
   - **File Editor app** (if installed)
2. Make your changes and save
3. Restart the Grafana Alloy app from Home Assistant

On first startup, the app creates a default configuration at `/data/alloy/config.alloy` with a placeholder URL that you can edit.

## Storage

Configuration and state data are stored in `/data/alloy/`:

- `config.alloy` — Your Grafana Alloy configuration (read-only from Alloy's perspective)
- `data/` — Component state and WAL (write-ahead log) for `prometheus.remote_write`

This data persists across app restarts and updates.

## Updating

Version updates are released as pull requests via the scheduled [check-alloy-release.yml](.github/workflows/check-alloy-release.yml) workflow. When a newer Grafana Alloy release is available, a PR is automatically created updating both the app version and the bundled Alloy version.

## Troubleshooting

### Checking Logs

View the app's logs in Home Assistant:
- Settings → System → Logs
- Filter for the Grafana Alloy app

### Configuration Errors

Check the logs for parsing errors. Common issues:
- Malformed Alloy syntax (missing braces, incorrect block structure)
- Invalid URL in `prometheus.remote_write` endpoint
- Authentication or TLS certificate issues when connecting to remote Prometheus

### Remote Write Connectivity

Verify your Prometheus remote_write endpoint is reachable and accepts the credentials/auth method you've configured. Check:
1. The endpoint URL in your configuration is correct
2. Any required authentication headers or tokens are set
3. Firewall rules allow outbound HTTPS to your Prometheus server

### Shutdown Behavior

Grafana Alloy uses SIGTERM for graceful shutdown. In rare cases (see [grafana/alloy#1980](https://github.com/grafana/alloy/issues/1980)), some setups may require an extended shutdown period. Home Assistant's s6-overlay handles SIGTERM → SIGKILL escalation automatically if needed, so no manual intervention is typically required.

## Supported Architectures

- `amd64` (Intel/AMD 64-bit)
- `aarch64` (ARM 64-bit, e.g., Raspberry Pi 4/5)

## License

This app is licensed under the MIT License. Grafana Alloy is licensed under the Elastic License 2.0 and Server Side Public License (SSPL) — see https://grafana.com/licensing/open-source/ for details.
