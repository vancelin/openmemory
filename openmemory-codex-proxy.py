#!/usr/bin/env python3
"""OpenMemory STDIO MCP Proxy for Codex CLI.

Bridges Codex CLI's STDIO-only MCP support to OpenMemory's HTTP MCP endpoint.
Uses FastMCP's built-in proxy to forward all MCP calls transparently.
Requires: pip install fastmcp
"""

import atexit
import os
import shlex
import subprocess
from pathlib import Path
from fastmcp.server import create_proxy

OM_URL = os.environ.get("OPENMEMORY_URL", "http://localhost:8080")
OM_MANAGER = os.environ.get(
    "OPENMEMORY_MANAGER",
    str(Path(__file__).resolve().with_name("openmemory-manager.sh")),
)


def _run_manager(func_name: str) -> None:
    """Best-effort invocation of lifecycle helpers in openmemory-manager.sh."""
    if not Path(OM_MANAGER).is_file():
        return

    command = f"source {shlex.quote(OM_MANAGER)}; {func_name}"
    subprocess.run(
        ["/bin/zsh", "-lc", command],
        check=False,
        stdout=subprocess.DEVNULL,
        stderr=subprocess.DEVNULL,
    )


def _acquire_openmemory() -> None:
    _run_manager("_om_ensure_running")
    _run_manager("_om_ref_incr")


def _release_openmemory() -> None:
    _run_manager("_om_ref_decr")


proxy = create_proxy(f"{OM_URL}/mcp", name="openmemory")

if __name__ == "__main__":
    _acquire_openmemory()
    atexit.register(_release_openmemory)
    proxy.run()
