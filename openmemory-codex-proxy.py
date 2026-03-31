#!/usr/bin/env python3
"""OpenMemory STDIO MCP Proxy for Codex CLI.

Bridges Codex CLI's STDIO-only MCP support to OpenMemory's HTTP MCP endpoint.
Requires: pip install fastmcp httpx
"""

import os
from fastmcp import FastMCP
import httpx
import json

mcp = FastMCP("openmemory")
API_BASE = os.environ.get("OPENMEMORY_URL", "http://localhost:8080")
USER_ID = os.environ.get("OPENMEMORY_USER_ID", os.environ.get("USER", "default"))
CLIENT_NAME = os.environ.get("OPENMEMORY_CLIENT", "codex-cli")


@mcp.tool()
def add_memories(text: str) -> str:
    """Store a new memory. Use this to remember facts, preferences, or context."""
    try:
        r = httpx.post(
            f"{API_BASE}/api/v1/memories/",
            json={"text": text, "user_id": USER_ID, "client_name": CLIENT_NAME},
            timeout=30,
        )
        data = r.json()
        return json.dumps(data, ensure_ascii=False)
    except Exception as e:
        return f"Error: {e}"


@mcp.tool()
def search_memory(query: str) -> str:
    """Search memories semantically. Returns relevant stored memories."""
    try:
        r = httpx.post(
            f"{API_BASE}/api/v1/memories/search/",
            json={"query": query, "user_id": USER_ID, "client_name": CLIENT_NAME},
            timeout=30,
        )
        data = r.json()
        return json.dumps(data, ensure_ascii=False)
    except Exception as e:
        return f"Error: {e}"


@mcp.tool()
def list_memories() -> str:
    """List all stored memories."""
    try:
        r = httpx.get(
            f"{API_BASE}/api/v1/memories/",
            params={"user_id": USER_ID, "client_name": CLIENT_NAME},
            timeout=30,
        )
        data = r.json()
        return json.dumps(data, ensure_ascii=False)
    except Exception as e:
        return f"Error: {e}"


@mcp.tool()
def delete_all_memories() -> str:
    """Delete all stored memories. Use with caution."""
    try:
        r = httpx.delete(
            f"{API_BASE}/api/v1/memories/",
            params={"user_id": USER_ID, "client_name": CLIENT_NAME},
            timeout=30,
        )
        data = r.json()
        return json.dumps(data, ensure_ascii=False)
    except Exception as e:
        return f"Error: {e}"


if __name__ == "__main__":
    mcp.run()
