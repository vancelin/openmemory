# openmemory

> Auto start/stop [OpenMemory](https://github.com/CaviraOSS/OpenMemory) MCP server across Claude Code, Codex CLI, and Gemini CLI.

Share long-term memory across all your AI agents — no manual start/stop needed.

## How It works

```
Terminal 1: type claude   → OpenMemory auto-starts (refcount = 1)
Terminal 2: type gemini  → shares same server  (refcount = 2)
Terminal 1: exits          → still running    (refcount = 1)
Terminal 2: exits          → auto stops       (refcount = 0)
```

Reference counting ensures OpenMemory only runs when needed and shuts down when idle.

## Prerequisites

- [OpenMemory server](https://github.com/CaviraOSS/OpenMemory) installed at `~/OpenMemory`
- Python 3.10+ with `fastmcp` and `httpx` (for Codex CLI proxy)
- Node.js 18+ (for OpenMemory server)
- `curl`, `lsof` (standard macOS/Linux tools)

### Install OpenMemory server

```bash
git clone https://github.com/CaviraOSS/OpenMemory.git ~/OpenMemory
cd ~/OpenMemory/packages/openmemory-js
npm install
npm run build
```

## Install

```bash
git clone git@github.com:vancelin/openmemory.git ~/dev/memory
cd ~/dev/memory
chmod +x install.sh openmemory-manager.sh openmemory-codex-proxy.py
./install.sh
```

Restart your terminal, then run `claude`, — OpenMemory starts automatically.

## Files

| File | Purpose |
|------|---------|
| `openmemory-manager.sh` | Core lifecycle manager (start/stop/refcount) |
| `openmemory-codex-proxy.py` | STDIO MCP proxy for Codex CLI |
| `install.sh` | One-command shell hook installer |
| `.mcp.json` | Claude Code MCP config (HTTP) |

## MCP Configuration

### Claude Code — `.mcp.json` (project root or global)

```json
{
  "mcpServers": {
    "openmemory": {
      "type": "http",
      "url": "http://localhost:8080/mcp"
    }
  }
}
```

### Gemini CLI — `~/.gemini/settings.json`

```json
{
  "mcpServers": {
    "openmemory": {
      "httpUrl": "http://localhost:8080/mcp",
      "trust": true
    }
  }
}
```

### Codex CLI — `~/.codex/config.toml`

```toml
[mcp_servers.openmemory]
command = "/path/to/python"
args = ["/path/to/openmemory-codex-proxy.py"]
```

Codex CLI only supports STDIO transport. The proxy script bridges to OpenMemory's HTTP endpoint.

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `OPENMEMORY_DIR` | `~/OpenMemory/packages/openmemory-js` | OpenMemory server path |
| `OPENMEMORY_PORT` | `8080` | Server port |
| `OPENMEMORY_URL` | `http://localhost:8080` | Codex proxy API URL |
| `OPENMEMORY_LOCK_DIR` | `/tmp/openmemory` | Lock/refcount directory |
| `OPENMEMORY_USER_ID` | `$(whoami)` | Default user ID for memory |
| `OPENMEMORY_CLIENT` | CLI name | Default client name |

## Uninstall

Remove the hooks block from `~/.zshrc` (between the `OpenMemory auto-start/stop hooks` markers):

```bash
sed -i '/# ── OpenMemory auto-start/,/# ── End OpenMemory hooks/d' ~/.zshrc
```

## License

MIT
