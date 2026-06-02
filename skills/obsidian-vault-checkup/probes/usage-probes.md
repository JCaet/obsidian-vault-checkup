# Per-plugin usage probes

A catalogue of evidence-gathering checks for common Obsidian plugins. Each entry tells you *what to look at* to decide whether a plugin is genuinely in use.

Probes return **evidence**, not decisions. The user always makes the keep/drop call. Treat probes as "if zero matches, the plugin is probably inactive — confirm with the user".

The catalogue is meant to grow. If you triage a plugin not listed here, add an entry in the format below before closing the session — that contribution survives across vaults.

## Entry format

```markdown
## <plugin-id>
What it does: <one-line summary>
Probe: <shell command or pattern, relative to the vault root>
Active when: <what counts as a positive signal>
Replacement when inactive: <core feature or alternative plugin, if any>
Notes: <optional — known quirks, upstream status>
```

---

## Tables & data

### dataview
What it does: query and aggregate notes via a JS-style DSL in fenced ` ```dataview ` blocks.
Probe: `grep -rln '```dataview' . --include='*.md'`
Active when: any match.
Replacement when inactive: Bases (core, GA in recent Obsidian). Bases covers table/grouping cases natively. JS-style ad-hoc queries are still Dataview-only.

### notion-like-tables (DataLoom)
What it does: spreadsheet-style database views stored as `.loom` files.
Probe: `find . -iname "*.loom" -not -path "*/.trash/*"`
Active when: any match outside `.trash/`.
Replacement when inactive: Bases (core).
Notes: Upstream (DecafDev) cadence has slowed. Bases handles the common cases.

### table-editor-obsidian (Advanced Tables)
What it does: tab-to-navigate cells, auto-format pipes, sort columns, **formula support via `<!-- TBLFM: ... -->`**.
Probe: `grep -rln 'TBLFM:' . --include='*.md'`
Active when: any `TBLFM:` formula marker.
Replacement when inactive: Obsidian core handles navigation, alignment, auto-format natively in modern versions. Formulas remain unique to this plugin.

---

## Workflow & capture

### obsidian-day-planner
What it does: time-blocked task management with a timeline visualization. Tasks formatted as `- [ ] HH:MM Task`.
Probe: `grep -rln '^- \[ \] \(0[0-9]\|1[0-9]\|2[0-3]\):[0-5][0-9]' . --include='*.md'`
Active when: matches in daily notes or anywhere the user time-blocks.
Notes: Check `.obsidian/plugins/obsidian-day-planner/data.json` — `pluginVersion` field is a "last opened" proxy. iCal feed entries with empty `name`/`url` indicate the user never wired up calendar integration.

### quickadd
What it does: macro/quick-action runner — capture, multi-step commands, scripted choices.
Probe: zero in-vault syntax footprint; instead inspect `.obsidian/plugins/quickadd/data.json` for the `choices` array. Empty array (or no file) means the plugin is inert.
Active when: at least 2–3 configured choices the user can name a current use for.
Replacement when inactive: Obsidian core's "Add new file" / Templates plugin covers basic capture.

### templater-obsidian
What it does: scriptable templates with JS-style placeholders and dynamic logic.
Probe: list non-empty files in the user's templates folder (read folder path from core `templates` plugin config in `.obsidian/templates.json` or from `daily-notes.json` template field). A single empty `Untitled.md` is a placeholder, not a template.
Active when: templates folder contains real template content.
Replacement when inactive: core `templates` plugin handles basic insert-from-template.

### obsidian-meta-bind-plugin
What it does: interactive inputs/buttons inside notes via `INPUT[...]` and `BUTTON[...]` syntax.
Probe: `grep -rln 'INPUT\[\|BUTTON\[\|VIEW\[' . --include='*.md'`
Active when: any match.
Replacement when inactive: no core equivalent. Keep on disk if the user has imminent template-button plans; otherwise delete.

### obsidian-outliner
What it does: keyboard-driven deep bullet hierarchies (vim-style indent/outdent, fold, drag).
Probe: count `.md` files with bullets indented 3+ levels: `grep -rEln '^(\t{3,}|        +)- ' . --include='*.md' | wc -l`
Active when: significant count (≥ 5 files).
Replacement when inactive: native bullet editing.

### obsidian-tasks-plugin
What it does: rich task syntax, queries, due dates, recurrences.
Probe: query block presence: ```grep -rln '```tasks' . --include='*.md'``` plus annotation density: `grep -rEohn '(📅|⏳|🛫|🔁|⏫|🔼|🔽|✅) ?[0-9]{4}-[0-9]{2}-[0-9]{2}' . --include='*.md' | wc -l`
Active when: any `tasks` query block OR significant emoji-annotation density.

---

## Editor enhancements

### url-into-selection
What it does: pastes a URL onto selected text as a markdown link.
Probe: N/A — Obsidian core handles this natively since ~v1.5.
Active when: never. Always-removable on modern Obsidian.

### obsidian-paste-image-rename
What it does: prompts for a clean filename on image paste instead of `Pasted image YYYYMMDDHHMMSS`.
Probe: `find . -iname "Pasted image*" -type f -not -path "*/.trash/*" | wc -l`
Interpretation: many default-named files = the plugin would help going forward (not retroactively). Recommend enabling on any vault with > ~10 default-named files.

### obsidian-auto-link-title
What it does: fetches the title of a pasted URL and inserts it as the link text.
Probe: no clean signal — it's a paste-time helper. Check `data.json` for non-default settings.

### highlightr-plugin
What it does: colored highlights beyond markdown's `==text==`.
Probe: count `==...==` markdown highlights (core syntax, plugin-agnostic): `grep -rln '==[^=]\+==' . --include='*.md'`. Then check `.obsidian/plugins/highlightr-plugin/data.json` for non-default color configurations.
Active when: user uses colored variants (not just plain `==highlight==`).
Replacement when inactive: markdown-native `==text==` works without the plugin.

### various-complements
What it does: in-line autocomplete drawn from vault content, custom dictionaries, hashtags.
Probe: no in-vault syntax; check `data.json` for custom dictionary entries or non-default trigger config.
Active when: user reports using it day-to-day (no objective probe — ask).

---

## Drawing & visual

### obsidian-excalidraw-plugin
What it does: Excalidraw drawings stored as `.excalidraw` or embedded `.excalidraw.md` files.
Probe: `find . \( -iname "*.excalidraw" -o -iname "*.excalidraw.md" \) -not -path "*/.trash/*"`
Active when: any match.
Notes: Plugin is large (~10+ MB). Worth checking even when the user has a designated drawings folder, since drawings sometimes accumulate elsewhere.

### ink
What it does: handwriting/stylus drawings.
Probe: check `.obsidian/plugins/ink/data.json` for paths to ink files; cross-reference vault for those paths.
Active when: any ink files referenced and present.
Notes: niche. Strong delete candidate unless the user uses a stylus device.

### excalibrain
What it does: graph-of-notes navigation built on tag conventions and front-matter.
Probe: check `.obsidian/plugins/excalibrain/data.json` for tag conventions; cross-reference vault for matching front-matter.
Notes: Stuck in perpetual `0.2.x` beta. Active-use signal is weak unless the user has invested in the Brain workflow.

---

## Sidebars & navigation

### calendar
What it does: sidebar mini-calendar for daily-note navigation.
Probe: requires core `daily-notes` plugin enabled AND a populated daily-notes folder. Use `grep -c daily-notes .obsidian/core-plugins.json` (or jq) and check the configured folder.
Active when: daily notes folder exists and is populated AND user uses sidebar nav (the latter is not objectively probeable — ask).
Notes: Upstream (Liam Cain) largely on hiatus. Bases with a date-grouped view is the modern alternative.

### iconic
What it does: per-file/folder icon decoration in the sidebar.
Probe: check `data.json` for configured icon overrides.
Active when: non-empty configuration.

### lapel
What it does: cosmetic decoration around headings (alignment marks).
Probe: N/A — purely visual; check `data.json` for configuration; check upstream for activity.
Notes: Upstream (Liam Cain) on hiatus. Cosmetic.

---

## Boards & projects

### obsidian-kanban
What it does: kanban-board views stored as markdown files with `kanban-plugin: basic` frontmatter.
Probe: `grep -rln '^kanban-plugin:' . --include='*.md'`
Active when: any match.

---

## Books & references

### obsidian-book-search-plugin
What it does: searches book metadata APIs and inserts results into notes.
Probe: check for a `Books/` folder (or equivalent) with notes containing typical book frontmatter (ISBN, author, publication year).
Active when: folder exists with populated notes.

---

## Imports & migration

### obsidian-importer
What it does: official one-shot import from Notion / Evernote / Apple Notes / Bear / HTML.
Probe: N/A — used at vault creation, then dead weight.
Recommendation: always delete after use. Reinstall on demand if another migration is needed.

### keepsidian
What it does: Google Keep one-way sync.
Probe: check `data.json` for OAuth tokens and recent sync timestamps.
Active when: recent sync activity and the user can name a Keep-to-vault workflow.

---

## External integrations

### google-calendar
What it does: shows Google Calendar events as in-vault notes; bidirectional in some flows.
Probe: check `data.json` for OAuth credentials and visible event-as-note files.
Active when: events appear as notes in a configured folder.
Notes: Heavy plugin; known stability issues. Bases + iCal feed is the lighter alternative.

### copilot
What it does: in-vault LLM chat (OpenAI/Gemini/local).
Probe: no in-vault footprint; check `data.json` for model configuration and provider keys.
Active when: configured + user actively uses it.

### open-gate
What it does: embeds external web apps as Obsidian panes.
Probe: check `data.json` for configured "gates" (web app URLs).
Active when: at least one gate the user can name a current use for.

---

## Link & reference helpers

### persistent-links
What it does: keeps internal links from breaking when notes are renamed.
Probe: N/A — preventative; no in-vault footprint.
Recommendation: keep on if any notes get renamed regularly. Low cost, real benefit.

---

## Theming & UI

### obsidian-style-settings
What it does: exposes theme/snippet configuration UI for themes that declare Style Settings metadata.
Probe: check `appearance.json` `cssTheme` (must be non-empty) AND `.obsidian/snippets/` folder (or at least one snippet that uses Style Settings metadata).
Active when: a theme or snippet that declares Style Settings is in use.
Replacement when inactive: not applicable — it's an enabler, not a feature.

### obsidian-reading-time
What it does: shows estimated reading time in the status bar.
Probe: N/A — status bar widget, no in-vault footprint.
Active when: user glances at it (ask).

---

## Adding a probe

If you triage a plugin not in this catalogue:

1. Identify its in-vault syntax footprint (a unique grep pattern), file extension, or required configuration.
2. Write an entry in the format above.
3. Open a pull request — or, if working in a session, suggest the addition to the user before closing.

Probes that work off **in-vault evidence** (grep / find) are best. Probes that work off **plugin configuration** are second-best (configs can be aspirational, not actual use). Probes that require **asking the user** are last resort — only use them for plugins with no objective footprint (LLM chat, autocomplete, status-bar widgets).
