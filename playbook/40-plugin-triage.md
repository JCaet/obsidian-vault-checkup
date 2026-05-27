# Phase 40 — Plugin triage

**Goal:** For each plugin folder on disk, decide whether it stays enabled, gets disabled, gets deleted from disk, or (for currently-disabled plugins that look useful) gets enabled. Decisions are user-made; the skill gathers evidence and presents it.

This is the longest phase. Pace it: walk plugins one at a time if the user wants the dialogue, or batch them into groups (clear-deletes, decide-or-drop, enabled-keepers) for speed.

## The loop

For each plugin folder in `.obsidian/plugins/`:

1. **Probe** — Look up the plugin in `probes/usage-probes.md`. Run the documented probe against the vault. Capture:
   - Whether the plugin has a `data.json` (configured) and how non-default it is.
   - Folder size on disk (`du -sh`).
   - In-vault usage evidence (the plugin-specific probe — `grep` for a syntax, `find` for a file extension, etc.).
   - Whether the plugin's upstream is alive (optional — only check GitHub for plugins the user wants to keep but is unsure about).
   - Whether phase 10 flagged a core feature that overlaps with this plugin.

2. **Present** — Show the evidence and a recommended action. Keep it tight: 4–6 lines per plugin is usually enough.

3. **Ask** — Use a structured question with 2–3 options:
   - **Disabled plugins:** delete folder / keep disabled / re-enable.
   - **Enabled plugins flagged as redundant:** disable for trial / disable + delete folder / keep as-is.
   - **Enabled plugins clearly active:** typically no question needed; mention in the run summary only.

4. **Act** — On user confirmation:
   - Disabling: remove from `.obsidian/community-plugins.json`.
   - Enabling: append to `.obsidian/community-plugins.json`.
   - Deleting folder: `rm -rf .obsidian/plugins/<plugin-id>`.

5. **Log** — *Do not write a changelog entry per plugin.* Track decisions in conversation. At the end of phase 40, write **one consolidated entry** with a per-plugin table (see phase 60 for format).

## Decision heuristics

| Signal | Inclination |
|---|---|
| Probe returns zero in-vault matches + no `data.json` | Delete folder. |
| Probe returns zero matches + rich `data.json` from older `pluginVersion` | Delete folder. The user tried it, never adopted it. |
| Probe returns matches but only a handful | Present count; let user decide. Don't push delete. |
| Phase 10 flagged this plugin as core-absorbed + low/no usage | Strong delete recommendation. |
| Plugin is disabled and the user volunteers an upcoming use case | Keep disabled, leave folder. Footnote in the changelog so next audit doesn't re-flag. |
| Plugin is enabled, configured, actively used | No change. Mention in run summary only. |
| Upstream looks dead (no release in 18+ months) **and** vault uses it heavily | Flag the maintenance risk; user keeps anyway is fine but they should know. |

## Anti-patterns

- **Don't recommend "keep disabled, leave folder" as a default.** Disk and sync state aren't free. Default to delete unless the user states an upcoming use case.
- **Don't auto-bundle decisions.** If the user wants 1-by-1, do 1-by-1. If they want a group sweep ("delete all the ones with zero matches"), confirm the list first, then execute.
- **Don't trust a probe alone.** Probes are evidence; the user's intent is the decision. If the probe says "0 matches" but the user says "I'm about to start using it", honor that.

## Trial-disable pattern

For an enabled plugin that's *likely* replaced by core but the user isn't 100% sure: disable it now, leave the folder on disk, and add a follow-up to the run summary ("re-evaluate in N days; delete folder if nothing regressed"). The trial period is the user's call — typical: 3–14 days. When they return, the next audit (or a one-off ask) closes the loop with a delete-folder entry.

## Trigger for trending discovery

The trending phase (50) is best run *after* triage, because:
- The user knows what they just removed and can think clearly about what (if anything) should replace it.
- New plugin candidates can be cross-referenced with workflow patterns just confirmed in triage.
