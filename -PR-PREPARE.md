# OpenCode 支援提交準備

## 提交訊息 (Commit Message)

```
feat: Add OpenCode CLI support

- Add opencode() wrapper function in install.sh for auto lifecycle management
- Add .mcp.json.example as reference for MCP HTTP configuration
- Update README.md with OpenCode instructions (English & Traditional Chinese)
- OpenCode uses the same .mcp.json format as Claude Code for MCP servers
```

## PR 標題

```
feat: Add OpenCode CLI support
```

## PR 說明內容

```markdown
## Summary

Add support for [OpenCode](https://opencode.ai/) CLI to OpenMemory Auto Manager.

OpenCode is an AI-powered code editor that supports the Model Context Protocol (MCP). This PR enables OpenCode users to share long-term memory with Claude Code, Codex CLI, and Gemini CLI through the same OpenMemory server.

## Changes

### 1. install.sh
- Added `opencode()` wrapper function alongside existing `claude()`, `codex()`, `gemini()` functions
- OpenCode now triggers auto-start/stop lifecycle when invoked

### 2. .mcp.json.example (new file)
- Added example MCP configuration file for HTTP transport
- Compatible with both Claude Code and OpenCode (same format)

### 3. README.md
- Updated architecture diagram to include OpenCode
- Added OpenCode to feature list and supported tools
- Added MCP configuration instructions for OpenCode
- Updated both English and Traditional Chinese sections

## Usage

After installing the updated hooks:

```bash
# OpenCode will now auto-start OpenMemory server
opencode
```

Configure MCP in `~/.opencode/.mcp.json`:

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

## Testing

- [x] Shell syntax validation passed (`bash -n install.sh`)
- [x] JSON format validation passed
- [x] Code style matches existing patterns

## Notes

- OpenCode uses the same `.mcp.json` format as Claude Code
- HTTP MCP transport is supported (same as Claude Code)
- No breaking changes to existing functionality
```

## 檔案變更清單

| 檔案 | 變更類型 | 說明 |
|------|---------|------|
| `install.sh` | 修改 | 加入 `opencode()` 函數 |
| `.mcp.json.example` | 新增 | MCP 設定範例 |
| `README.md` | 修改 | 加入 OpenCode 文件 |

## Git 命令步驟

### 1. Fork 原倉庫
在 GitHub 上 fork https://github.com/vancelin/openmemory 到你的帳號

### 2. 修改 remote URL
```bash
cd E:/OneDrive/_Project/openmemory-fork
git remote set-url origin https://github.com/你的帳號/openmemory.git
```

### 3. 建立分支並提交
```bash
git checkout -b feat/opencode-support
git add .mcp.json.example
git commit -am "feat: Add OpenCode CLI support

- Add opencode() wrapper function in install.sh
- Add .mcp.json.example for MCP configuration reference
- Update README.md with OpenCode instructions (EN & ZH)"
git push -u origin feat/opencode-support
```

### 4. 建立 Pull Request
1. 瀏覽到 https://github.com/你的帳號/openmemory
2. 點擊 "Compare & pull request"
3. 填寫標題和說明（見上方）
4. 提交 PR
