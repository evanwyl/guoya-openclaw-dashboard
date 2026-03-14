#!/bin/bash
set -euo pipefail

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Make launchd-friendly PATH resolution work with common Node installs.
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

# Ports and paths - can be overridden by environment variables
export DASHBOARD_PORT="${DASHBOARD_PORT:-7000}"
export OPENCLAW_DIR="${OPENCLAW_DIR:-$HOME/.openclaw}"
if [ -z "${WORKSPACE_DIR:-}" ]; then
  if [ -d "$HOME/.openclaw/workspace" ]; then
    export WORKSPACE_DIR="$HOME/.openclaw/workspace"
  else
    export WORKSPACE_DIR="$HOME/clawd"
  fi
fi
export OPENCLAW_AGENT="${OPENCLAW_AGENT:-all}"

# Support launchd sessions where nvm paths are not loaded automatically.
if [ -z "${NVM_DIR:-}" ]; then
  export NVM_DIR="$HOME/.nvm"
fi

if [ -s "$NVM_DIR/nvm.sh" ]; then
  # shellcheck source=/dev/null
  . "$NVM_DIR/nvm.sh"
fi

NODE_BIN="${NODE_BIN:-}"
if [ -z "$NODE_BIN" ] && command -v node >/dev/null 2>&1; then
  NODE_BIN="$(command -v node)"
fi

if [ -z "$NODE_BIN" ] && [ -d "$HOME/.nvm/versions/node" ]; then
  NODE_BIN="$(find "$HOME/.nvm/versions/node" -type f -path '*/bin/node' 2>/dev/null | sort | tail -n 1)"
fi

if [ -z "$NODE_BIN" ]; then
  echo "❌ Node.js not found. Please install Node.js v18+ or set NODE_BIN and retry."
  exit 1
fi

# Run the dashboard using node from PATH
exec "$NODE_BIN" server.js
