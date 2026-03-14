#!/bin/bash
set -euo pipefail

# Get the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Ports and paths - can be overridden by environment variables
export DASHBOARD_PORT="${DASHBOARD_PORT:-7000}"
export OPENCLAW_DIR="${OPENCLAW_DIR:-$HOME/.openclaw}"
export WORKSPACE_DIR="${WORKSPACE_DIR:-$HOME/clawd}"
export OPENCLAW_AGENT="${OPENCLAW_AGENT:-main}"

if ! command -v node >/dev/null 2>&1; then
  echo "❌ Node.js not found in PATH. Please install Node.js v18+ and retry."
  exit 1
fi

# Run the dashboard using node from PATH
exec node server.js
