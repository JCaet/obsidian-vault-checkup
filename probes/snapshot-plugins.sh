#!/usr/bin/env bash
#
# snapshot-plugins.sh — Generate a markdown snapshot of plugins in an Obsidian vault.
#
# Usage: snapshot-plugins.sh <vault-path>
#
# Output (stdout): two markdown tables (enabled / disabled) with versions,
# ready to paste into an audit-log snapshot entry.

set -euo pipefail

VAULT="${1:-}"

if [[ -z "$VAULT" ]]; then
  echo "Usage: $0 <vault-path>" >&2
  exit 1
fi

if [[ ! -d "$VAULT/.obsidian/plugins" ]]; then
  echo "Not a vault root (no .obsidian/plugins/): $VAULT" >&2
  exit 1
fi

PLUGINS_DIR="$VAULT/.obsidian/plugins"
ENABLED_FILE="$VAULT/.obsidian/community-plugins.json"

# Parse the enabled list. Prefer jq; fall back to grep if jq is unavailable.
enabled=""
if [[ -f "$ENABLED_FILE" ]]; then
  if command -v jq >/dev/null 2>&1; then
    enabled=$(jq -r '.[]' "$ENABLED_FILE" 2>/dev/null || true)
  else
    enabled=$(grep -oE '"[^"]+"' "$ENABLED_FILE" 2>/dev/null | tr -d '"' || true)
  fi
fi

# Helper: extract version from a manifest.json
manifest_version() {
  local manifest="$1"
  if [[ ! -f "$manifest" ]]; then
    echo "(no manifest)"
    return
  fi
  if command -v jq >/dev/null 2>&1; then
    jq -r '.version // "unknown"' "$manifest" 2>/dev/null
  else
    grep -oE '"version"\s*:\s*"[^"]+"' "$manifest" \
      | head -1 \
      | sed -E 's/.*"version"\s*:\s*"([^"]+)".*/\1/'
  fi
}

# Helper: check enabled status
is_enabled() {
  local name="$1"
  [[ -n "$enabled" ]] && echo "$enabled" | grep -Fxq "$name"
}

# Iterate plugin folders, sorted alphabetically
declare -a enabled_rows=()
declare -a disabled_rows=()

while IFS= read -r -d '' d; do
  name=$(basename "$d")
  version=$(manifest_version "$d/manifest.json")
  row="| $name | $version |"
  if is_enabled "$name"; then
    enabled_rows+=("$row")
  else
    disabled_rows+=("$row")
  fi
done < <(find "$PLUGINS_DIR" -mindepth 1 -maxdepth 1 -type d -print0 | sort -z)

# Emit
echo "### Enabled (${#enabled_rows[@]})"
echo
echo "| Plugin folder | Version |"
echo "|---|---|"
if ((${#enabled_rows[@]} > 0)); then
  printf '%s\n' "${enabled_rows[@]}"
fi
echo
echo "### Installed but disabled (${#disabled_rows[@]})"
echo
echo "| Plugin folder | Version |"
echo "|---|---|"
if ((${#disabled_rows[@]} > 0)); then
  printf '%s\n' "${disabled_rows[@]}"
fi
