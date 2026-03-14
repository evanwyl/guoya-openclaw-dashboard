#!/bin/bash
set -euo pipefail

WORKSPACE_DIR="${WORKSPACE_DIR:-${OPENCLAW_WORKSPACE:-$(pwd)}}"
OUTPUT_FILE="${WORKSPACE_DIR}/data/gemini-usage.json"
RAW_FILE="/tmp/gemini-usage-raw.txt"
PARSE_SCRIPT="${WORKSPACE_DIR}/scripts/parse-gemini-usage.py"

mkdir -p "${WORKSPACE_DIR}/data"

collect_with_openclaw() {
  if ! command -v openclaw >/dev/null 2>&1; then
    return 1
  fi

  if openclaw usage gemini --json > "$RAW_FILE" 2>/dev/null; then
    return 0
  fi
  if openclaw usage --provider gemini --json > "$RAW_FILE" 2>/dev/null; then
    return 0
  fi
  if openclaw usage gemini > "$RAW_FILE" 2>/dev/null; then
    return 0
  fi
  if openclaw usage --provider gemini > "$RAW_FILE" 2>/dev/null; then
    return 0
  fi
  return 1
}

if ! collect_with_openclaw; then
  cat > "$RAW_FILE" <<'EOF'
{}
EOF
fi

if [ -f "$PARSE_SCRIPT" ]; then
  python3 "$PARSE_SCRIPT" "$RAW_FILE" "$OUTPUT_FILE"
else
  cat > "$OUTPUT_FILE" <<'EOF'
{
  "scraped_at": "",
  "models": {}
}
EOF
fi
