# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.19.1] - 2026-08-26

### Added

- Initial release of Grafana Alloy Home Assistant app
- Bundles Grafana Alloy v1.19.1 for telemetry collection and Prometheus remote_write forwarding
- Supports optional multiline configuration via app options or direct file editing
- Includes s6-overlay service supervision for automatic restart on exit
- AppArmor profile for security containment
- Comprehensive documentation and troubleshooting guide
- Scheduled GitHub Actions workflow for automated version bump detection
