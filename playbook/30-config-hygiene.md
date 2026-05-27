# Phase 30 — Config hygiene

**Goal:** Fix the small, common drift that accumulates in `.obsidian/` over months of use. Routine fixes (sync-conflict purge) are *not* logged. Capability-affecting fixes (font replacement, theme reset) *are* logged.

## Checks

### 1. Monospace font in `appearance.json`

Read `.obsidian/appearance.json`. Inspect `monospaceFontFamily`.

**Common failure:** the value is set to a proportional font (`Inter`, `Segoe UI`, `Arial`, etc.), which makes code blocks render with uneven character widths. This usually happens when a user copies the text-font value into the monospace slot without noticing.

A real monospace family ends in `Mono`, `Code`, `Console`, `Consolas`, or is one of the known monospaces (`Courier New`, `Menlo`, `Monaco`, `Source Code Pro`, `Roboto Mono`, `Inconsolata`, `Hack`, `Fira Code`, `IBM Plex Mono`, etc.).

**Recommended fallback chain:**
```json
"monospaceFontFamily": "JetBrains Mono,Cascadia Code,Consolas,monospace"
```

Order rationale: JetBrains Mono if installed → Cascadia Code (ships with recent Windows / Windows Terminal) → Consolas (always present on Windows) → generic monospace. Adjust for macOS-primary users (`Menlo` or `SF Mono` first).

**Log this fix.** Capability-affecting change. Use kind `config`.

### 2. Sync-conflict cruft

Find files matching `*.sync-conflict-*` under `.obsidian/`. Common sources:
- Syncthing — produces `*.sync-conflict-<date>-<time>-<deviceid>.<ext>` siblings.
- iCloud — produces `<name> 2.<ext>` style copies.
- Obsidian Sync — produces `<name> (conflict <date>).<ext>`.

For each detected family of conflict files:
- List them with size + timestamp for user review.
- Confirm none contain unique state (workspace.json conflicts in particular accumulate harmlessly; plugin data.json conflicts may hold older configs).
- Bulk-delete on user confirmation.

**Do not log.** This is routine maintenance per the changelog scope spec. If hundreds of conflicts indicate a deeper sync problem, surface it as a conversational note, not a changelog entry.

### 3. Orphaned plugin config

Look in `.obsidian/plugins/*/data.json` for configs whose plugin folder is otherwise empty or whose plugin is disabled in `community-plugins.json` but has rich settings. Common patterns:
- `pluginVersion` field in `data.json` lower than the current `manifest.json` version → the plugin hasn't been opened since that version. Use as a "last touched" proxy.
- References to other plugins that have been removed (e.g. `dataviewSource: ""` after Dataview deletion) → orphaned integration.

Surface as findings during phase 40 triage, not as separate fixes.

### 4. Secret scan

Heuristic scan of `.obsidian/plugins/*/data.json` for likely API keys / tokens:
```bash
grep -lE '"(api_?key|token|secret|access_token)"\s*:\s*"[^"]{12,}"' .obsidian/plugins/*/data.json
```

If hits and the vault is synced (Syncthing, iCloud, Obsidian Sync, Dropbox, git), flag clearly:
> The vault is synced and `<plugin>/data.json` contains what looks like an API key in plaintext. Confirm this is acceptable, or move the secret to an environment variable / OS keychain if the plugin supports it.

Do not echo the secret to the conversation or any log.

### 5. Theme + snippets sanity

- `appearance.json` `cssTheme: ""` and no `.obsidian/snippets/` folder → `obsidian-style-settings` plugin is dead weight; cross-reference in phase 40.
- Existing `cssTheme` + missing/empty `snippets/` → fine.
- `snippets/` with files but `enabledCssSnippets` array empty in `appearance.json` → snippet code shipped but inert; flag.

## Outputs

- Edits applied to `.obsidian/appearance.json` (font) if user confirms — logged.
- Sync-conflict files deleted if user confirms — not logged.
- Findings surfaced to user for phase 40 cross-reference (orphaned config, secrets, theme/snippet state) — not logged in this phase.
