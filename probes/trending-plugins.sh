#!/usr/bin/env bash
#
# trending-plugins.sh — Surface popular Obsidian community plugins not installed in a vault.
#
# Usage: trending-plugins.sh <vault-path> [top-n]
#   top-n default: 15
#
# Requirements: curl, jq
#
# Output (stdout): markdown table of the top N plugins by cumulative downloads
# that are not present in the vault's .obsidian/plugins/ directory.
#
# Limitation: stats are cumulative, not "recent growth". A plugin popular years
# ago and now abandoned can still rank highly. See playbook/50-trending-discovery.md
# for refinement suggestions (GitHub last-commit checks, etc.).

set -euo pipefail

VAULT="${1:-}"
N="${2:-15}"

if [[ -z "$VAULT" ]]; then
  echo "Usage: $0 <vault-path> [top-n]" >&2
  exit 1
fi

if [[ ! -d "$VAULT/.obsidian/plugins" ]]; then
  echo "Not a vault root (no .obsidian/plugins/): $VAULT" >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "jq is required. Install via: apt install jq | brew install jq | choco install jq" >&2
  exit 1
fi

if ! command -v curl >/dev/null 2>&1; then
  echo "curl is required." >&2
  exit 1
fi

PLUGINS_URL="https://raw.githubusercontent.com/obsidianmd/obsidian-releases/HEAD/community-plugins.json"
STATS_URL="https://raw.githubusercontent.com/obsidianmd/obsidian-releases/HEAD/community-plugin-stats.json"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

curl -fsSL "$PLUGINS_URL" -o "$tmp/plugins.json"
curl -fsSL "$STATS_URL" -o "$tmp/stats.json"

# Collect installed plugin IDs (one per line)
installed_ids=$(find "$VAULT/.obsidian/plugins" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' 2>/dev/null \
  || find "$VAULT/.obsidian/plugins" -mindepth 1 -maxdepth 1 -type d -exec basename {} \;)

# Join catalog + stats, filter out installed, take top N
jq -r \
  --slurpfile stats "$tmp/stats.json" \
  --argjson n "$N" \
  --arg installed "$installed_ids" \
  '
    ($installed | split("\n") | map(select(length > 0))) as $inst
    | [
        .[] | . as $p
        | ($stats[0][$p.id] // null) as $s
        | select($s != null)
        | select(($inst | index($p.id)) == null)
        | {
            id:          $p.id,
            name:        $p.name,
            description: ($p.description // ""),
            downloads:   ($s.downloads // 0),
            repo:        $p.repo
          }
      ]
    | sort_by(-.downloads)
    | .[0:$n]
  ' "$tmp/plugins.json" > "$tmp/ranked.json"

# Emit markdown table
echo "## Top $N Obsidian community plugins by cumulative downloads (not already installed)"
echo
echo "_Note: ranking is by total downloads, not recent growth. Cross-check the repo for last-commit recency before adopting._"
echo
echo "| Rank | Plugin | Downloads | Description |"
echo "|---|---|---|---|"

i=0
jq -c '.[]' "$tmp/ranked.json" | while read -r row; do
  i=$((i + 1))
  name=$(echo "$row" | jq -r '.name')
  repo=$(echo "$row" | jq -r '.repo')
  downloads=$(echo "$row" | jq -r '.downloads')
  description=$(echo "$row" | jq -r '.description' | tr '|' '/' | tr -d '\n')
  printf '| %d | [%s](https://github.com/%s) | %s | %s |\n' \
    "$i" "$name" "$repo" "$downloads" "$description"
done
