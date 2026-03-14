#!/bin/bash
set -e

echo "🚀 OpenClaw Dashboard Installer"
echo "================================"
echo ""

# OS Detection
OS_TYPE=$(uname -s)
NONINTERACTIVE="${NONINTERACTIVE:-0}"
echo "💻 Detected OS: $OS_TYPE"

# Check for Node.js
if ! command -v node &> /dev/null; then
  echo "❌ Node.js not found. Please install Node.js v18+ first."
  if [ "$OS_TYPE" == "Darwin" ]; then
    echo "   Recommendation: brew install node"
  else
    echo "   Recommendation: curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash - && sudo apt-get install -y nodejs"
  fi
  exit 1
fi

NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
  echo "❌ Node.js version is too old (need v18+, have v$NODE_VERSION)"
  exit 1
fi

echo "✅ Node.js $(node --version) detected"

# Check for jq (needed for Docker page)
if ! command -v jq &> /dev/null; then
  echo "⚠️  jq not found. Docker management page won't work without it."
  if [ "$OS_TYPE" == "Darwin" ]; then
    echo "   Install: brew install jq"
  else
    echo "   Install: sudo apt-get install -y jq"
  fi
fi

# Check for tmux (needed for Claude CLI usage scraper)
if ! command -v tmux &> /dev/null; then
  echo "⚠️  tmux not found. Claude CLI usage scraper won't work without it."
  if [ "$OS_TYPE" == "Darwin" ]; then
    echo "   Install: brew install tmux"
  else
    echo "   Install: sudo apt-get install -y tmux"
  fi
fi

echo ""

# Detect workspace
if [ -z "$WORKSPACE_DIR" ]; then
  if [ -n "${OPENCLAW_WORKSPACE:-}" ]; then
    WORKSPACE_DIR="$OPENCLAW_WORKSPACE"
  elif [ -d "$HOME/.openclaw/workspace" ]; then
    WORKSPACE_DIR="$HOME/.openclaw/workspace"
  else
    DEFAULT_WORKSPACE="$HOME/clawd"
    if [ "$NONINTERACTIVE" = "1" ]; then
      WORKSPACE_DIR="$DEFAULT_WORKSPACE"
    else
      read -p "Enter your OpenClaw workspace path (default: $DEFAULT_WORKSPACE): " input
      WORKSPACE_DIR="${input:-$DEFAULT_WORKSPACE}"
    fi
  fi
fi

if [ ! -d "$WORKSPACE_DIR" ]; then
  echo "⚠️  Workspace directory does not exist: $WORKSPACE_DIR"
  if [ "$NONINTERACTIVE" = "1" ]; then
    mkdir -p "$WORKSPACE_DIR"
    echo "✅ Created workspace directory"
  else
    read -p "Create it now? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      mkdir -p "$WORKSPACE_DIR"
      echo "✅ Created workspace directory"
    else
      echo "❌ Installation cancelled"
      exit 1
    fi
  fi
fi

echo "✅ Workspace: $WORKSPACE_DIR"
echo ""

# Detect OpenClaw directory
OPENCLAW_DIR="${OPENCLAW_DIR:-$HOME/.openclaw}"
if [ ! -d "$OPENCLAW_DIR" ]; then
  echo "⚠️  OpenClaw directory not found: $OPENCLAW_DIR"
  if [ "$NONINTERACTIVE" = "1" ]; then
    echo "⚠️  NONINTERACTIVE=1, continuing."
  else
    read -p "Continue anyway? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      echo "❌ Installation cancelled"
      exit 1
    fi
  fi
fi

# Port selection
DASHBOARD_PORT="${DASHBOARD_PORT:-7000}"
if [ "$NONINTERACTIVE" != "1" ]; then
  read -p "Dashboard port (default: $DASHBOARD_PORT): " input
  DASHBOARD_PORT="${input:-$DASHBOARD_PORT}"
fi

# Copy scraper scripts to workspace if not present
SCRIPTS_DIR="$WORKSPACE_DIR/scripts"
mkdir -p "$SCRIPTS_DIR"
CURRENT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

copied_any=false
for f in scrape-claude-usage.sh parse-claude-usage.py scrape-gemini-usage.sh parse-gemini-usage.py; do
  if [ -f "$CURRENT_DIR/scripts/$f" ] && [ ! -f "$SCRIPTS_DIR/$f" ]; then
    cp "$CURRENT_DIR/scripts/$f" "$SCRIPTS_DIR/"
    copied_any=true
  fi
done

if [ -f "$SCRIPTS_DIR/scrape-claude-usage.sh" ]; then
  chmod +x "$SCRIPTS_DIR/scrape-claude-usage.sh"
fi
if [ -f "$SCRIPTS_DIR/scrape-gemini-usage.sh" ]; then
  chmod +x "$SCRIPTS_DIR/scrape-gemini-usage.sh"
fi

if [ "$copied_any" = true ]; then
  echo "✅ Scraper scripts copied to $SCRIPTS_DIR"
else
  echo "✅ Scraper scripts already exist in $SCRIPTS_DIR"
fi

echo ""
echo "📋 Installation Summary"
echo "----------------------"
echo "Workspace:     $WORKSPACE_DIR"
echo "OpenClaw Dir:  $OPENCLAW_DIR"
echo "Port:          $DASHBOARD_PORT"
echo "Install Dir:   $CURRENT_DIR"
echo "Agent Scope:   all"
echo ""

if [ "$OS_TYPE" == "Linux" ]; then
  echo "🔐 Linux detected: Can install as systemd service."
  if [ "$NONINTERACTIVE" = "1" ]; then
    REPLY="n"
  else
    read -p "Proceed with systemd service installation? (y/n): " -n 1 -r
    echo
  fi
  if [[ ${REPLY:-n} =~ ^[Yy]$ ]]; then
    SERVICE_FILE="/etc/systemd/system/agent-dashboard.service"
    SERVICE_CONTENT="[Unit]
Description=OpenClaw Agent Dashboard
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$CURRENT_DIR
ExecStart=$(which node) $CURRENT_DIR/server.js
Environment=DASHBOARD_PORT=$DASHBOARD_PORT
Environment=WORKSPACE_DIR=$WORKSPACE_DIR
Environment=OPENCLAW_DIR=$OPENCLAW_DIR
Environment=OPENCLAW_AGENT=all
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target"

    if [ -w /etc/systemd/system ]; then
      echo "$SERVICE_CONTENT" > "$SERVICE_FILE"
    else
      echo "$SERVICE_CONTENT" | sudo tee "$SERVICE_FILE" > /dev/null
    fi

    sudo systemctl daemon-reload
    sudo systemctl enable agent-dashboard
    sudo systemctl start agent-dashboard
    echo "✅ Systemd service installed and started."
  fi
fi

echo ""
echo "🎉 Setup complete!"
echo "To start the dashboard manually, run:"
echo "  ./run-dashboard.sh"
echo ""
echo "Dashboard will be available at:"
echo "  → http://localhost:$DASHBOARD_PORT"
echo ""
echo "🔐 First-time setup:"
echo "  1. Open the dashboard URL above"
echo "  2. Register a username and password"
echo ""
