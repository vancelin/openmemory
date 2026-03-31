#!/usr/bin/env python3
"""OpenMemory STDIO MCP Proxy for Codex CLI.

Bridges Codex CLI's STDIO-only MCP support to OpenMemory's HTTP MCP endpoint.
Uses FastMCP's built-in proxy to forward all MCP calls transparently.
Requires: pip install fastmcp
"""

import os
from fastmcp.server import create_proxy

OM_URL = os.environ.get("OPENMEMORY_URL", "http://localhost:8080")
proxy = create_proxy(f"{OM_URL}/mcp", name="openmemory")

if __name__ == "__main__":
    proxy.run()
