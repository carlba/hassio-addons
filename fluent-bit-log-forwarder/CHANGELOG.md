<!-- https://developers.home-assistant.io/docs/apps/presentation#keeping-a-changelog -->
## 0.2.3

- Fixed a segfault (exit code 139) in Fluent Bit when using a TLS-enabled
  Loki output with HTTP basic auth, surfaced by the 0.2.2 diagnostic
  logging. Upgraded the pinned Fluent Bit version from 3.2.5 to 5.1.2,
  which requires switching the base image from Debian bookworm (glibc
  2.36) to trixie (glibc 2.40+).

## 0.2.2

- Fluent Bit is now started without `exec`, and its exit code is logged
  explicitly, so a silent crash-restart loop shows the real exit code
  (and signal, if any) in the app log instead of no information at all.

## 0.2.1

- Fixed the Fluent Bit binary failing to start (`cannot execute: required
  file not found`). Upstream Fluent Bit ships a glibc-dynamically-linked
  binary, which is incompatible with the musl-based Alpine HA base image;
  the app now builds on the Debian-based HA base image instead.

## 0.2.0

- **Breaking:** replaced `loki_url` with `loki_host`, `loki_port`, `loki_tls`,
  and `loki_uri`, matching the Loki output plugin's own configuration keys.
- Added `loki_user` / `loki_password` for HTTP basic auth, required by
  hosted Loki instances such as Grafana Cloud.

## 0.1.0

- Initial release
