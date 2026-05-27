# Phase 50 — Trending discovery

**Goal:** Surface community plugins the user might benefit from but doesn't have. Optional phase — skip if the user is content with the current stack.

## Source of truth

Two files in the official `obsidian-releases` GitHub repo:

- `https://raw.githubusercontent.com/obsidianmd/obsidian-releases/HEAD/community-plugins.json` — catalog (id, name, author, description, repo).
- `https://raw.githubusercontent.com/obsidianmd/obsidian-releases/HEAD/community-plugin-stats.json` — cumulative download counts per plugin id, per version.

These are the authoritative lists; mirror them rather than scraping the website.

## The probe

```bash
probes/trending-plugins.sh <vault-path> [top-n]
```

Default top-n is 15. The script:
1. Fetches both JSONs to a temp dir.
2. Joins them on `plugin-id`.
3. Sorts by cumulative downloads (descending).
4. Filters out any plugin id already present in `.obsidian/plugins/`.
5. Emits a markdown table.

## Known limitation: "trending" vs "popular"

`community-plugin-stats.json` is cumulative — it gives **total downloads**, not **recent growth**. A plugin that was popular three years ago and is now abandoned still ranks high. To approximate "trending":

- Quick refinement: for the top hits, fetch each `repo` field's GitHub repo. Plugins with no commits in 18+ months get demoted regardless of download count.
- Deeper refinement: GitHub's API gives star history and recent commit activity. Optional — only do this if the user wants 5–10 truly fresh candidates instead of 15 popular-and-possibly-stale ones.

Document both this limitation and the available refinements to the user before showing the list, so they evaluate the table with the right expectations.

## Relevance filter

Total-download rankings include a lot of plugins that won't suit any given user. Before showing the table, scan the vault for workflow signals and filter accordingly:

| If the vault has… | Surface plugins for… |
|---|---|
| `Personal/Daily Notes/` (or equivalent) with many notes | Daily-note enhancement, periodic notes, journal review. |
| `Books/` folder with literature notes | Book tracking, citation management, reading-list workflows. |
| Many `.canvas` files | Canvas extensions, mind-mapping, graph layout. |
| Heavy `tasks-plugin` use (queries in many notes) | Task management, GTD frameworks, time tracking. |
| Many `.excalidraw` files | Drawing, diagramming, slide creation. |
| Active git remote on the vault | Git plugin variants (if not already installed). |
| Many code blocks | Code execution, syntax highlighting, embed-runner plugins. |

If none of the workflow signals fire, present a generic top-N and note that the user should treat it as a starting list, not a recommendation set.

## Present + ask

Display the filtered table with descriptions. Ask the user which (if any) they want to consider. The skill does **not** install — installation happens in Obsidian's UI (Settings → Community plugins → Browse → search id → Install → Enable). Log nothing yet — installs are user-visible via the next audit's baseline snapshot anyway, and a "you said you'd consider X" entry tends to be noise if they don't follow through.

If the user installs a plugin during the session and asks to log it, treat that as a `plugin` lifecycle entry like any other in phase 60.
