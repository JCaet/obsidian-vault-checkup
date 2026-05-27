# Phase 10 — Obsidian release review

**Goal:** Identify what Obsidian core has absorbed since the last checkup. Core features that overlap with installed plugins are the strongest "delete this plugin" signal in phase 40.

## Inputs

1. **The vault's Obsidian version.** No reliable way to read this from `.obsidian/` alone (Obsidian writes the version into per-device state, not the synced config). Ask the user: *"What Obsidian version are you on? (Settings → About)"*. If they don't know, ask them to check.
2. **The date of the last checkup.** Read the vault's audit log (path resolved in pre-flight 05). Find the most recent `## [YYYY-MM-DD] snapshot | ...` heading. That's the "since" date for this phase.
3. **If no prior snapshot exists** (first-ever checkup): use a 12-month window by default, or ask the user how far back to look.

## What to fetch

In order of preference:

1. **Obsidian official changelog:** `https://obsidian.md/changelog` — public, ungated, the canonical list.
2. **Obsidian releases on GitHub:** `https://github.com/obsidianmd/obsidian-releases/releases` — same content, often easier to filter by date range.
3. **In-app "What's new"** — not fetchable; useful as a cross-reference if the user wants to verify.

Use `WebFetch` against `https://obsidian.md/changelog` with a prompt asking for a structured summary: dates, versions, headline features per version since `<last-checkup-date>`.

## What to look for

For each release since the last checkup, classify changes into:

- **Core absorption** — a feature that overlaps with a popular community plugin. Examples from the recent history:
  - **Bases** (added v1.7+, GA later): absorbs `dataview` (table cases), `notion-like-tables` / DataLoom, much of `obsidian-projects`.
  - **Native table editing improvements**: largely absorbs `table-editor-obsidian` / Advanced Tables except formula support.
  - **URL paste on selection** (~v1.5): absorbs `url-into-selection`.
  - **Footnotes core**: replaced several footnote-helper plugins.
- **Behavior changes** — defaults that change rendering, indexing, or sync. Worth flagging even if no plugin is implicated.
- **New surfaces** — new core APIs (e.g. `Properties`, the file menu in canvases) that *enable* new community plugins rather than replace old ones.

## Output

A short structured summary, written into the audit working notes (in conversation; not into the vault changelog at this stage). Format:

```markdown
### Obsidian changes since <last-checkup-date>

#### Core absorption
- v1.X.Y (<date>): <feature> — overlaps with `<plugin-id>`. Implication: candidate for removal in phase 40 unless still uniquely useful.
- ...

#### Notable behavior changes
- v1.X.Y (<date>): <change>. Implication: <what to verify or watch>.

#### New surfaces worth exploring
- v1.X.Y (<date>): <api/feature>. Implication: opens room for new plugins; revisit in phase 50.
```

## Hand-off to phase 40

When triaging each plugin in phase 40, cross-reference this section: "Phase 10 flagged this plugin as overlapping with core feature X added in v1.Y.Z" is a clean evidence point to present to the user alongside the in-vault usage probe.
