#!/usr/bin/env python3
"""Read subscription limits through Codex's own authenticated app-server."""

import json
import math
import os
import selectors
import signal
import subprocess
import sys
import time


class Unavailable(RuntimeError):
    def __init__(self, status, message):
        super().__init__(message)
        self.status = status


def read_limits(binary="codex", timeout=15):
    proc = subprocess.Popen(
        [binary, "app-server"], stdin=subprocess.PIPE, stdout=subprocess.PIPE,
        stderr=subprocess.DEVNULL, start_new_session=True,
    )
    selector = selectors.DefaultSelector()
    selector.register(proc.stdout, selectors.EVENT_READ)
    deadline = time.monotonic() + timeout
    buffer = b""

    def send(message):
        proc.stdin.write((json.dumps(message) + "\n").encode())
        proc.stdin.flush()

    def response(request_id):
        nonlocal buffer
        while time.monotonic() < deadline:
            while b"\n" in buffer:
                line, buffer = buffer.split(b"\n", 1)
                try:
                    message = json.loads(line)
                except (ValueError, UnicodeDecodeError):
                    continue
                if isinstance(message, dict) and message.get("id") == request_id:
                    if "error" in message:
                        raise RuntimeError("Codex rejected the usage request; check sign-in")
                    return message.get("result", {})
            if not selector.select(max(0, deadline - time.monotonic())):
                break
            chunk = os.read(proc.stdout.fileno(), 65536)
            if not chunk:
                raise RuntimeError("Codex closed before returning usage")
            buffer += chunk
            if len(buffer) > 2_000_000:
                raise RuntimeError("Unexpectedly large Codex response")
        raise TimeoutError("Codex usage request timed out")

    try:
        send({"id": 1, "method": "initialize", "params": {
            "clientInfo": {"name": "herdr-usage-bar", "version": "1.0"}}})
        response(1)
        send({"method": "initialized"})
        send({"id": 3, "method": "account/read", "params": {"refreshToken": False}})
        account = response(3).get("account")
        if account is None:
            raise Unavailable("signed_out", "Not signed in; run codex login")
        if account.get("type") == "apiKey":
            raise Unavailable("no_limits", "API-key account; no subscription limits")
        send({"id": 2, "method": "account/rateLimits/read", "params": {}})
        return normalize(response(2))
    finally:
        selector.close()
        # Only the short-lived process group created above; never a running agent.
        try:
            os.killpg(proc.pid, signal.SIGTERM)
        except ProcessLookupError:
            pass
        try:
            proc.wait(timeout=2)
        except subprocess.TimeoutExpired:
            os.killpg(proc.pid, signal.SIGKILL)
            proc.wait(timeout=2)
        proc.stdin.close()
        proc.stdout.close()


def number(value):
    return isinstance(value, (int, float)) and not isinstance(value, bool) and math.isfinite(value)


def normalize(result):
    windows = []
    limits = result.get("rateLimitsByLimitId") or {}
    if not limits and result.get("rateLimits"):
        item = result["rateLimits"]
        limits = {item.get("limitId") or "codex": item}
    for key, item in sorted(limits.items(), key=lambda pair: (pair[0] != "codex", pair[0])):
        for slot in ("primary", "secondary"):
            window = item.get(slot)
            if not isinstance(window, dict) or not number(window.get("usedPercent")):
                continue
            minutes, reset = window.get("windowDurationMins"), window.get("resetsAt")
            windows.append({
                "id": f"{key}:{slot}", "name": item.get("limitName") or key,
                "used": window["usedPercent"],
                "minutes": minutes if number(minutes) and minutes > 0 else None,
                "resetsAt": reset if number(reset) and reset > 0 else None,
            })
    if not windows:
        raise Unavailable("no_limits", "No subscription limits available")
    return {"ok": True, "observedAt": int(time.time()), "windows": windows}


def collect():
    try:
        output = read_limits()
        output["status"] = "ok"
    except FileNotFoundError:
        output = {"ok": False, "status": "not_installed", "error": "Codex CLI not installed"}
    except Unavailable as error:
        output = {"ok": False, "status": error.status, "error": str(error)}
    except (OSError, RuntimeError, ValueError) as error:
        output = {"ok": False, "status": "error", "error": str(error)}
    return {"id": "codex", "name": "Codex", **output}
