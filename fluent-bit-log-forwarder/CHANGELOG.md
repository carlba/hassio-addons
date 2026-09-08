<!-- https://developers.home-assistant.io/docs/apps/presentation#keeping-a-changelog -->
## 0.2.1

- Fixed Fluent Bit binary being copied for the wrong architecture during
  multi-arch builds, causing `cannot execute: required file not found` at
  startup.

## 0.2.0

- **Breaking:** replaced `loki_url` with `loki_host`, `loki_port`, `loki_tls`,
  and `loki_uri`, matching the Loki output plugin's own configuration keys.
- Added `loki_user` / `loki_password` for HTTP basic auth, required by
  hosted Loki instances such as Grafana Cloud.

## 0.1.0

- Initial release
