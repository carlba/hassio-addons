<!-- https://developers.home-assistant.io/docs/apps/presentation#keeping-a-changelog -->
## 0.2.5

- The 0.2.4 AppArmor profile widening did not fix the segfault (exit code
  139). Rather than continue guessing at individual permissions, disabled
  AppArmor confinement for this app entirely (`apparmor: false` in
  `config.yaml`) and removed the now-unused `apparmor.txt` profile. If this
  fixes it, the next step is to narrow the profile back down deliberately
  (e.g. via `complain` mode + audit log) instead of running unconfined
  long-term.

## 0.2.4

- Fixed a segfault (exit code 139) in Fluent Bit that only occurred under
  the app's AppArmor confinement, not when running the same binary and
  config standalone. The bundled `apparmor.txt` profile was hand-tuned for
  Fluent Bit 3.2.5 and denied file/proc access that the 5.1.2 OpenSSL 3.x
  TLS stack needs; a denied access on some paths surfaces as SIGSEGV
  rather than a clean error. Widened the profile (OpenSSL abstraction,
  `/proc` and `/sys` CPU/entropy info, CA certificate paths).

## 0.2.3

- Upgraded the pinned Fluent Bit version from 3.2.5 to 5.1.2 (requiring
  the base image to move from Debian bookworm to trixie for its glibc
  2.38+ requirement), after the 0.2.2 diagnostic logging revealed a
  segfault (exit code 139). This did not fix the segfault on its own —
  see 0.2.4.

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
