# Phase 00 — Overview

The six phases form a sequence. Each one's output feeds the next. Skip phases only on explicit user request.

```
┌──────────────────────────┐
│ 10. Release review       │  Fetch Obsidian changelog since last
│                          │  checkup. Identify core features that
│                          │  may absorb installed plugins.
└──────────┬───────────────┘
           │  findings inform phase 40
           ▼
┌──────────────────────────┐
│ 20. Baseline snapshot    │  Snapshot all installed plugins
│                          │  (enabled+disabled, versions) into
│                          │  the audit log as rollback point.
└──────────┬───────────────┘
           ▼
┌──────────────────────────┐
│ 30. Config hygiene       │  Fix appearance.json font, sweep
│                          │  sync-conflict cruft, flag orphaned
│                          │  plugin config. Routine — do not log.
└──────────┬───────────────┘
           ▼
┌──────────────────────────┐
│ 40. Plugin triage        │  For each plugin: probe → present →
│                          │  ask → act → log. Use findings from 10.
└──────────┬───────────────┘
           ▼
┌──────────────────────────┐
│ 50. Trending discovery   │  Fetch official community-plugins
│                          │  catalog + stats. Rank, filter, surface
│                          │  candidates. User decides whether to
│                          │  install (via Obsidian UI, not the skill).
└──────────┬───────────────┘
           ▼
┌──────────────────────────┐
│ 60. Changelog discipline │  Consolidate decisions into one or
│                          │  two well-formed entries. Verify scope
│                          │  and style spec is documented in the
│                          │  vault's CLAUDE.md / AGENTS.md.
└──────────────────────────┘
```

## Cadence

Recommended: every 3–6 months, or whenever a major Obsidian release lands. Determine cadence by reading the date of the most recent `snapshot` entry in the vault's audit log (resolved in pre-flight).

## What the skill does not do

- It does not install plugins. New-plugin installation is an Obsidian UI action (Settings → Community plugins → Browse → Install). The skill surfaces candidates; the user installs.
- It does not delete files without per-change confirmation.
- It does not modify anything inside the vault's content folders. Only `.obsidian/` (config and plugin folders), the resolved audit log, and — only on first-time setup, with user confirmation — vault-root `CLAUDE.md` / `AGENTS.md` to persist the audit log path.
- It does not assume a single canonical workflow. Daily-notes users, Zettelkasten users, project-management users — the probes work off in-vault evidence regardless.

## Anti-bloat principle

The default direction is *less, not more*. Plugins on disk that aren't running still bloat sync and clutter audits. A clean default for an unused-and-uncovered plugin is **delete folder**, not "keep disabled". The user can always reinstall in 30 seconds.

The exception: plugins the user has *deliberately reserved* for upcoming work (e.g. meta-bind for planned template buttons). These get a "kept on disk, disabled" status and are footnoted in the changelog so the next audit doesn't re-flag them.
