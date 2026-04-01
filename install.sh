#!/bin/bash
# ── Install OpenMemory hooks into your shell config ──
set -e

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
SHELL_RC="$HOME/.zshrc"
SHELL_NAME="zsh"

HOOK_MARKER="# ── OpenMemory auto-start/stop hooks"
HOOK_END="# ── End OpenMemory hooks"

MANAGER_SRC="source \"$REPO_DIR/openmemory-manager.sh\""

# Detect shell
if [[ -f "$HOME/.bashrc" ]] && [[ ! -f "$HOME/.zshrc" ]]; then
    SHELL_RC="$HOME/.bashrc"
    SHELL_NAME="bash"
fi

echo "Installing OpenMemory hooks for $SHELL_NAME..."

echo ""

# 1. Link manager script
echo "Manager script: $REPO_DIR/openmemory-manager.sh"

# 2. Add hooks to shell RC if not already present
if grep -q "$HOOK_MARKER" "$SHELL_RC" 2>/dev/null; then
    echo "Hooks already installed in $SHELL_RC"
    echo "To reinstall, remove the old block first, then run this script again."
    exit 0
fi

# Generate the hook block
cat >> "$SHELL_RC" << SHEOF

$HOOK_MARKER ──────────────────────────
$MANAGER_SRC

# Helper: wrap an AI CLI with auto memory lifecycle
_om_wrap() {
  local _om_started=false
  if _om_ensure_running; then
    _om_ref_incr
    _om_started=true
  fi
  command "\$@"
  local ret=\$?
  [[ "\$_om_started" == true ]] && _om_ref_decr
  return \$ret
}

claude()   { _om_wrap claude   "\$@"; }
codex()    { _om_wrap codex    "\$@"; }
gemini()   { _om_wrap gemini   "\$@"; }
opencode() { _om_wrap opencode "\$@"; }

# Cleanup: decrement counter when terminal closes
zshexit() {
  _om_ref_decr
}
$HOOK_END ──────────────────────────────────────
SHEOF

echo "Hooks installed in $SHELL_RC"
echo ""
echo "Next steps:"
echo "  1. Clone & set up OpenMemory server:"
echo "     git clone https://github.com/CaviraOSS/OpenMemory.git ~/OpenMemory"
echo "     cd ~/OpenMemory/packages/openmemory-js && npm install && npm run build"
echo ""
echo "  2. Set environment variables (optional):"
echo "     export OPENMEMORY_DIR=\$HOME/OpenMemory/packages/openmemory-js"
echo "     export OPENMEMORY_PORT=8080"
echo ""
echo "  3. Restart your terminal, then run claude, opencode, codex, or gemini"
echo "     OpenMemory will auto-start and auto-stop."
