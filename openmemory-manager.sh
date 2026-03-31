#!/bin/bash
# OpenMemory Manager — auto start/stop with reference counting
#
# Manages OpenMemory server lifecycle across multiple AI CLI sessions.
# Source this from your shell config (.zshrc / .bashrc).

set -eu

OM_LOCK_DIR="${OPENMEMORY_LOCK_DIR:-/tmp/openmemory}"
OM_REF_FILE="$OM_LOCK_DIR/refcount"
OM_LOG="${OPENMEMORY_LOG:-/tmp/openmemory.log}"
OM_DIR="${OPENMEMORY_DIR:-$HOME/OpenMemory/packages/openmemory-js}"
OM_PORT="${OPENMEMORY_PORT:-8080}"

# ── Start OpenMemory if not already running ──
_om_ensure_running() {
    if curl -sf "http://localhost:${OM_PORT}/health" >/ /dev/null 2>&1; then
        return 0
    fi

    _om_reset_if_stale

    mkdir -p "$OM_LOCK_DIR"
    (cd "$OM_DIR" && nohup node dist/server/index.js > "$OM_LOG" 2>&1 &)

    local i
    for i in {1..15}; do
        if curl -sf "http://localhost:${OM_PORT}/health" > /dev/null 2>&1; then
            echo "OpenMemory started (pid: $(lsof -ti :${OM_PORT} 2>/dev/null || echo '')"
            return 0
        fi
        sleep 1
    done
    echo "OpenMemory failed to start. See $OM_LOG" >&2
    return 1
}

# ── Reference count: increment ──
_om_ref_incr() {
    mkdir -p "$OM_LOCK_DIR"
    local count=0
    [[ -f "$OM_REF_FILE" ]] && count=$(< "$OM_REF_FILE" 2>/dev/null)
    echo $((count + 1)) > "$OM_REF_FILE"
}

# ── Reference count: decrement, stop if zero ──
_om_ref_decr() {
    local count=0
    [[ -f "$OM_REF_FILE" ]] && count=$(< "$OM_REF_FILE" 2>/dev/null)
    count=$((count - 1))
    if [[ "$count" -le 0 ]]; then
        echo 0 > "$OM_REF_FILE"
        _om_stop
    else
        echo "$count" > "$OM_REF_FILE"
    fi
}

# ── Stop OpenMemory server ──
_om_stop() {
    local pid
    pid=$(lsof -ti :${OM_PORT} 2>/dev/null)
    if [[ -n "$pid" ]]; then
        kill "$pid" 2>/dev/null
        echo "OpenMemory stopped"
    fi
    echo 0 > "$OM_REF_FILE"
}

# ── Reset stale counter (server dead but refcount > 0) ──
_om_reset_if_stale() {
    [[ ! -f "$OM_REF_FILE" ]] && return 0
    local count
    count=$(< "$OM_REF_FILE" 2>/dev/null)
    [[ "$count" -gt 0 ]] || return 0

    if ! curl -sf "http://localhost:${OM_PORT}/health" > /dev/null 2>&1; then
        echo 0 > "$OM_REF_FILE"
    fi
}

