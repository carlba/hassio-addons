# carlba hassio addons

## Apps

This repository contains the following apps

### [Fluent Bit Log Forwarder](./fluent-bit-log-forwarder)

![Supports aarch64 Architecture][aarch64-shield] ![Supports amd64 Architecture][amd64-shield]

_Collect Home Assistant Core, Host, Supervisor, and app logs and forward them to Grafana Loki via
Fluent Bit._

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg

curl -s -N -H "Authorization: Bearer ${SUPERVISOR_TOKEN}"
"http://supervisor/host/logs/follow?lines=100"

curl -s -N -H "Authorization: Bearer ${SUPERVISOR_TOKEN}"
"http://supervisor/core/logs/follow?lines=100"

curl -s -H "Authorization: Bearer ${SUPERVISOR_TOKEN}"
"http://supervisor/supervisor/logs/follow?lines=100"

curl -s -N -H "Authorization: Bearer ${SUPERVISOR_TOKEN}"
"http://supervisor/addons/cb646a50_get/logs/follow?lines=100"
