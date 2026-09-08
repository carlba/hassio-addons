<!-- https://developers.home-assistant.io/docs/apps/presentation#keeping-a-changelog -->
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
