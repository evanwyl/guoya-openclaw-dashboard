#!/usr/bin/env python3
import json
import re
import sys
from datetime import datetime, timezone

raw_file = sys.argv[1]
output_file = sys.argv[2]

with open(raw_file, "r", encoding="utf-8", errors="ignore") as f:
    raw = f.read()

out = {
    "scraped_at": datetime.now(timezone.utc).isoformat(),
    "models": {},
}

def to_model_entry(item):
    if not isinstance(item, dict):
        return None
    model = str(item.get("model") or item.get("name") or "").strip()
    if not model:
        return None
    used = item.get("used_percent", item.get("percent", 0))
    try:
        used = float(used)
    except Exception:
        used = 0.0
    resets = str(item.get("resets_in") or item.get("resets") or "").strip()
    return model, {"used_percent": round(used, 2), "resets_in": resets}

# First try JSON output
try:
    parsed = json.loads(raw)
    if isinstance(parsed, dict):
        if isinstance(parsed.get("models"), dict):
            for name, info in parsed["models"].items():
                try:
                    used = float(info.get("used_percent", info.get("percent", 0)))
                except Exception:
                    used = 0.0
                resets = str(info.get("resets_in") or info.get("resets") or "").strip()
                out["models"][str(name)] = {"used_percent": round(used, 2), "resets_in": resets}
        elif isinstance(parsed.get("models"), list):
            for item in parsed["models"]:
                entry = to_model_entry(item)
                if entry:
                    out["models"][entry[0]] = entry[1]
        elif isinstance(parsed.get("usage"), list):
            for item in parsed["usage"]:
                entry = to_model_entry(item)
                if entry:
                    out["models"][entry[0]] = entry[1]
except Exception:
    pass

# Fallback: parse plain text lines
if not out["models"]:
    ansi_re = re.compile(r"\x1b\[[0-9;]*[A-Za-z]|\x1b\].*?\x07")
    clean = ansi_re.sub("", raw)
    lines = [x.strip() for x in clean.splitlines() if x.strip()]
    pattern = re.compile(
        r"^(?P<model>[A-Za-z0-9._:-]+).*?(?P<pct>\d+(?:\.\d+)?)\s*%\s*used(?:.*?(?:resets?\s*(?:in)?\s*)(?P<reset>.+))?$",
        re.IGNORECASE,
    )
    for line in lines:
        m = pattern.search(line)
        if not m:
            continue
        model = m.group("model")
        pct = float(m.group("pct"))
        reset = (m.group("reset") or "").strip()
        out["models"][model] = {"used_percent": round(pct, 2), "resets_in": reset}

with open(output_file, "w", encoding="utf-8") as f:
    json.dump(out, f, indent=2)

print(json.dumps(out, indent=2))
