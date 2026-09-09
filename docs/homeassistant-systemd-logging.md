### Supervistor

container_name: hassio-supervisor

```json
{
  "timestamp": "2026-09-09 15:35:26.852",
  "timeEpochMs": 1788960926852,
  "timeEpochNs": "1788960926852154000",
  "timeLocal": "2026-09-09 15:35:26",
  "timeUtc": "2026-09-09 13:35:26",
  "timeFromNow": "2 minutes ago",
  "logLevel": "warning",
  "displayLevel": "warn",
  "line": {
    "PRIORITY": "3",
    "_TRANSPORT": "journal",
    "_UID": "0",
    "_GID": "0",
    "_COMM": "dockerd",
    "_EXE": "/usr/bin/dockerd",
    "_CMDLINE": "/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock",
    "_CAP_EFFECTIVE": "1ffffffffff",
    "_SYSTEMD_CGROUP": "/system.slice/docker.service",
    "_SYSTEMD_UNIT": "docker.service",
    "_SYSTEMD_SLICE": "system.slice",
    "_BOOT_ID": "a7100be245784916962258630c296ab1",
    "_MACHINE_ID": "53ff86edf9f64f2b90c8f27767b5e19c",
    "_HOSTNAME": "f07ce27a60eb",
    "_RUNTIME_SCOPE": "system",
    "IMAGE_NAME": "ghcr.io/home-assistant/aarch64-hassio-supervisor:2026.09.0",
    "CONTAINER_TAG": "hassio_supervisor",
    "_PID": "254",
    "_SYSTEMD_INVOCATION_ID": "3e4f6aaac2504239ab2ca44d5dfc07e0",
    "CONTAINER_LOG_EPOCH": "41a5d5169c18b99c7e4de657f0d11eb62f016e53471f0d957178c1688cf5f2df",
    "CONTAINER_ID": "438442be7b3f",
    "CONTAINER_ID_FULL": "438442be7b3f869f061436a5264335a593f8ec8acb20c41df3da94c2c1fb9782",
    "MESSAGE": "\u001b[33m2026-09-09 15:35:26.851 WARNING (MainThread) [supervisor.hardware.disk] Unable to find UDisks2 drive for device at /dev/vdb\u001b[0m",
    "SYSLOG_TIMESTAMP": "2026-09-09T13:35:26.851922955Z",
    "CONTAINER_LOG_ORDINAL": "154",
    "_SOURCE_REALTIME_TIMESTAMP": "1788960926852131"
  },
  "labels": {
    "Parsed fields": {
      "_BOOT_ID": "a7100be245784916962258630c296ab1",
      "_CAP_EFFECTIVE": "1ffffffffff",
      "_CMDLINE": "/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock",
      "_COMM": "dockerd",
      "_EXE": "/usr/bin/dockerd",
      "_GID": "0",
      "_HOSTNAME": "f07ce27a60eb",
      "_MACHINE_ID": "53ff86edf9f64f2b90c8f27767b5e19c",
      "_PID": "254",
      "_RUNTIME_SCOPE": "system",
      "_SOURCE_REALTIME_TIMESTAMP": "1788960926852131",
      "_SYSTEMD_CGROUP": "/system.slice/docker.service",
      "_SYSTEMD_INVOCATION_ID": "3e4f6aaac2504239ab2ca44d5dfc07e0",
      "_SYSTEMD_SLICE": "system.slice",
      "_SYSTEMD_UNIT": "docker.service",
      "_TRANSPORT": "journal",
      "_UID": "0",
      "CONTAINER_ID": "438442be7b3f",
      "CONTAINER_ID_FULL": "438442be7b3f869f061436a5264335a593f8ec8acb20c41df3da94c2c1fb9782",
      "CONTAINER_LOG_EPOCH": "41a5d5169c18b99c7e4de657f0d11eb62f016e53471f0d957178c1688cf5f2df",
      "CONTAINER_LOG_ORDINAL": "154",
      "CONTAINER_TAG": "hassio_supervisor",
      "IMAGE_NAME": "ghcr.io/home-assistant/aarch64-hassio-supervisor:2026.09.0",
      "MESSAGE": "\u001b[33m2026-09-09 15:35:26.851 WARNING (MainThread) [supervisor.hardware.disk] Unable to find UDisks2 drive for device at /dev/vdb\u001b[0m",
      "PRIORITY": "3",
      "SYSLOG_TIMESTAMP": "2026-09-09T13:35:26.851922955Z"
    },
    "Indexed labels": {
      "container_name": "hassio_supervisor",
      "host": "homeassistant",
      "job": "homeassistant",
      "service_name": "hassio_supervisor",
      "syslog_identifier": "hassio_supervisor"
    },
    "Structured metadata": {
      "detected_level": "warn"
    }
  }
}
```

### Host log

```json
{
  "timestamp": "2026-09-09 15:20:05.821",
  "timeEpochMs": 1788960005821,
  "timeEpochNs": "1788960005821297000",
  "timeLocal": "2026-09-09 15:20:05",
  "timeUtc": "2026-09-09 13:20:05",
  "timeFromNow": "5 minutes ago",
  "logLevel": "info",
  "displayLevel": "info",
  "line": {
    "_UID": "0",
    "_GID": "0",
    "_COMM": "dockerd",
    "_EXE": "/usr/bin/dockerd",
    "_CMDLINE": "/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock",
    "_CAP_EFFECTIVE": "1ffffffffff",
    "_SYSTEMD_CGROUP": "/system.slice/docker.service",
    "_SYSTEMD_UNIT": "docker.service",
    "_SYSTEMD_SLICE": "system.slice",
    "_BOOT_ID": "a7100be245784916962258630c296ab1",
    "_MACHINE_ID": "53ff86edf9f64f2b90c8f27767b5e19c",
    "_HOSTNAME": "f07ce27a60eb",
    "_RUNTIME_SCOPE": "system",
    "PRIORITY": "6",
    "SYSLOG_FACILITY": "3",
    "_TRANSPORT": "stdout",
    "_STREAM_ID": "1b023e3b3a244835b0262dbb0e95be96",
    "_PID": "254",
    "_SYSTEMD_INVOCATION_ID": "3e4f6aaac2504239ab2ca44d5dfc07e0",
    "MESSAGE": "time=\"2026-09-09T13:20:05.821211243Z\" level=info msg=\"sbJoin: gwep4 ''->'23057c9601fe', gwep6 ''->'23057c9601fe'\" eid=23057c9601fe ep=hassio_cli net=hassio nid=378e79d3eb05"
  },
  "labels": {
    "Parsed fields": {
      "_BOOT_ID": "a7100be245784916962258630c296ab1",
      "_CAP_EFFECTIVE": "1ffffffffff",
      "_CMDLINE": "/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock",
      "_COMM": "dockerd",
      "_EXE": "/usr/bin/dockerd",
      "_GID": "0",
      "_HOSTNAME": "f07ce27a60eb",
      "_MACHINE_ID": "53ff86edf9f64f2b90c8f27767b5e19c",
      "_PID": "254",
      "_RUNTIME_SCOPE": "system",
      "_STREAM_ID": "1b023e3b3a244835b0262dbb0e95be96",
      "_SYSTEMD_CGROUP": "/system.slice/docker.service",
      "_SYSTEMD_INVOCATION_ID": "3e4f6aaac2504239ab2ca44d5dfc07e0",
      "_SYSTEMD_SLICE": "system.slice",
      "_SYSTEMD_UNIT": "docker.service",
      "_TRANSPORT": "stdout",
      "_UID": "0",
      "eid": "23057c9601fe",
      "ep": "hassio_cli",
      "level": "info",
      "MESSAGE": "time=\"2026-09-09T13:20:05.821211243Z\" level=info msg=\"sbJoin: gwep4 ''->'23057c9601fe', gwep6 ''->'23057c9601fe'\" eid=23057c9601fe ep=hassio_cli net=hassio nid=378e79d3eb05",
      "net": "hassio",
      "PRIORITY": "6",
      "SYSLOG_FACILITY": "3"
    },
    "Structured metadata": {
      "detected_level": "info"
    },
    "Indexed labels": {
      "host": "homeassistant",
      "job": "homeassistant",
      "service_name": "homeassistant",
      "syslog_identifier": "dockerd"
    }
  }
}
```

### Homeassistant Core

container_name: homeassistant

```json
{
  "timestamp": "2026-09-09 16:02:18.979",
  "timeEpochMs": 1788962538979,
  "timeEpochNs": "1788962538979883000",
  "timeLocal": "2026-09-09 16:02:18",
  "timeUtc": "2026-09-09 14:02:18",
  "timeFromNow": "28 seconds ago",
  "logLevel": "error",
  "displayLevel": "error",
  "line": {
    "PRIORITY": "3",
    "_TRANSPORT": "journal",
    "_UID": "0",
    "_GID": "0",
    "_COMM": "dockerd",
    "_EXE": "/usr/bin/dockerd",
    "_CMDLINE": "/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock",
    "_CAP_EFFECTIVE": "1ffffffffff",
    "_SYSTEMD_CGROUP": "/system.slice/docker.service",
    "_SYSTEMD_UNIT": "docker.service",
    "_SYSTEMD_SLICE": "system.slice",
    "_BOOT_ID": "a7100be245784916962258630c296ab1",
    "_MACHINE_ID": "53ff86edf9f64f2b90c8f27767b5e19c",
    "_HOSTNAME": "f07ce27a60eb",
    "_RUNTIME_SCOPE": "system",
    "IMAGE_NAME": "ghcr.io/home-assistant/qemuarm-64-homeassistant:2026.9.1",
    "CONTAINER_TAG": "homeassistant",
    "CONTAINER_LOG_ORDINAL": "10",
    "_PID": "254",
    "_SYSTEMD_INVOCATION_ID": "3e4f6aaac2504239ab2ca44d5dfc07e0",
    "CONTAINER_ID": "6a16875948e1",
    "CONTAINER_ID_FULL": "6a16875948e14a8ffc4ae376416dc2e06786f40aef268946c12bb0213dc2adfe",
    "CONTAINER_LOG_EPOCH": "5434c4563f43a86a7c9b367eaf01a7ac25b0b88572145c32bf9f0b33e8dfb846",
    "MESSAGE": "\u001b[31m2026-09-09 16:02:18.965 ERROR (MainThread) [homeassistant.components.system_log.external] wohoo\u001b[0m",
    "SYSLOG_TIMESTAMP": "2026-09-09T14:02:18.979229457Z",
    "_SOURCE_REALTIME_TIMESTAMP": "1788962538979736"
  },
  "labels": {
    "Parsed fields": {
      "_BOOT_ID": "a7100be245784916962258630c296ab1",
      "_CAP_EFFECTIVE": "1ffffffffff",
      "_CMDLINE": "/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock",
      "_COMM": "dockerd",
      "_EXE": "/usr/bin/dockerd",
      "_GID": "0",
      "_HOSTNAME": "f07ce27a60eb",
      "_MACHINE_ID": "53ff86edf9f64f2b90c8f27767b5e19c",
      "_PID": "254",
      "_RUNTIME_SCOPE": "system",
      "_SOURCE_REALTIME_TIMESTAMP": "1788962538979736",
      "_SYSTEMD_CGROUP": "/system.slice/docker.service",
      "_SYSTEMD_INVOCATION_ID": "3e4f6aaac2504239ab2ca44d5dfc07e0",
      "_SYSTEMD_SLICE": "system.slice",
      "_SYSTEMD_UNIT": "docker.service",
      "_TRANSPORT": "journal",
      "_UID": "0",
      "CONTAINER_ID": "6a16875948e1",
      "CONTAINER_ID_FULL": "6a16875948e14a8ffc4ae376416dc2e06786f40aef268946c12bb0213dc2adfe",
      "CONTAINER_LOG_EPOCH": "5434c4563f43a86a7c9b367eaf01a7ac25b0b88572145c32bf9f0b33e8dfb846",
      "CONTAINER_LOG_ORDINAL": "10",
      "CONTAINER_TAG": "homeassistant",
      "IMAGE_NAME": "ghcr.io/home-assistant/qemuarm-64-homeassistant:2026.9.1",
      "MESSAGE": "\u001b[31m2026-09-09 16:02:18.965 ERROR (MainThread) [homeassistant.components.system_log.external] wohoo\u001b[0m",
      "PRIORITY": "3",
      "SYSLOG_TIMESTAMP": "2026-09-09T14:02:18.979229457Z"
    },
    "Indexed labels": {
      "container_name": "homeassistant",
      "host": "homeassistant",
      "job": "homeassistant",
      "service_name": "homeassistant",
      "syslog_identifier": "homeassistant"
    },
    "Structured metadata": {
      "detected_level": "error"
    }
  }
}
```
