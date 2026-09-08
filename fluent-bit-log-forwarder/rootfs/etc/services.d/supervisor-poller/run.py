#!/usr/bin/env python3
"""Stream logs from the Supervisor API's /follow endpoints straight into the
files the sibling `fluent-bit` service tails, one long-lived `curl` per
source. Any stream that drops (Supervisor restart, connection reset, etc.)
is restarted on its own so one source's failure doesn't affect the others.
"""

import json
import os
import sys
import threading
import urllib.error
import urllib.request

SUPERVISOR_API = "http://supervisor"
LOG_DIR = "/var/log/fluent-bit-src"


def log_info(message):
    print(f"[info] {message}", flush=True)


def log_warning(message):
    print(f"[warning] {message}", flush=True)


def is_true(value):
    return str(value).strip().lower() == "true"


def auth_headers():
    return {"Authorization": f"Bearer {os.environ.get('SUPERVISOR_TOKEN', '')}"}


def fetch_addon_slugs():
    request = urllib.request.Request(
        f"{SUPERVISOR_API}/addons",
        headers=auth_headers(),
    )
    with urllib.request.urlopen(request) as response:
        data = json.load(response)
    return [addon["slug"] for addon in data["data"]["addons"]]


class Stream:
    """A single supervised background thread streaming a log source to a file."""

    def __init__(self, api_path, out_file, source_name, prefix=None):
        self.api_path = api_path
        self.out_file = out_file
        self.source_name = source_name
        self.prefix = prefix
        self.thread = None

    def start(self):
        os.makedirs(os.path.dirname(self.out_file), exist_ok=True)
        open(self.out_file, "a").close()

        self.thread = threading.Thread(target=self._run, daemon=True)
        self.thread.start()
        log_info(f"Streaming {self.source_name} log ({self.api_path})...")

    def _run(self):
        request = urllib.request.Request(
            f"{SUPERVISOR_API}{self.api_path}",
            headers=auth_headers(),
        )
        try:
            with urllib.request.urlopen(request) as response, open(self.out_file, "ab") as out_fh:
                for line in response:
                    if self.prefix:
                        line = f"{self.prefix}: ".encode() + line
                    out_fh.write(line)
                    out_fh.flush()
        except (urllib.error.URLError, OSError):
            pass

    def poll(self):
        return None if self.thread.is_alive() else 0


def build_streams(options):
    streams = []

    if options["collect_core_log"]:
        streams.append(Stream("/core/logs/follow", f"{LOG_DIR}/core.log", "core"))
    if options["collect_host_log"]:
        streams.append(Stream("/host/logs/follow", f"{LOG_DIR}/host.log", "host"))
    if options["collect_supervisor_log"]:
        streams.append(Stream("/supervisor/logs/follow", f"{LOG_DIR}/supervisor.log", "supervisor"))

    if options["collect_addon_logs"]:
        try:
            slugs = fetch_addon_slugs()
        except (urllib.error.URLError, KeyError, json.JSONDecodeError) as exc:
            log_warning(f"Failed to fetch addon list: {exc}")
            slugs = []
        for slug in slugs:
            streams.append(
                Stream(
                    f"/addons/{slug}/logs/follow",
                    f"{LOG_DIR}/addon.log",
                    f"addon-{slug}",
                    prefix=slug,
                )
            )

    return streams


def main():
    os.makedirs(LOG_DIR, exist_ok=True)

    options = {
        "collect_core_log": is_true(os.environ.get("COLLECT_CORE_LOG", "")),
        "collect_host_log": is_true(os.environ.get("COLLECT_HOST_LOG", "")),
        "collect_supervisor_log": is_true(os.environ.get("COLLECT_SUPERVISOR_LOG", "")),
        "collect_addon_logs": is_true(os.environ.get("COLLECT_ADDON_LOGS", "")),
    }

    streams = build_streams(options)
    for stream in streams:
        stream.start()

    log_info("All log streams started, supervising...")

    import time

    while True:
        time.sleep(2)
        for stream in streams:
            if stream.poll() is not None:
                log_warning(f"Log stream {stream.source_name} ({stream.api_path}) exited, restarting...")
                stream.start()


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        sys.exit(0)
