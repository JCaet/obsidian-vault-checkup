---
name: obsidian-vault-checkup
description: Use this skill to run a periodic audit of an Obsidian vault. Reviews what Obsidian core absorbed since the last checkup, snapshots installed plugins with versions, fixes common config drift (broken monospace fonts, sync-conflict cruft, orphaned plugin configs), triages each plugin against real in-vault usage evidence (probe → present → ask → act → log), surfaces relevant trending community plugins, and records every meaningful decision in a vault-resident audit log (path is resolved per-vault, never hardcoded). Invoke when the user asks to audit, review, check up on, lint, or clean an Obsidian vault — also a good fit after a major Obsidian version bump or when the plugin set has grown organically over months.
---

# Obsidian Vault Checkup

A guided, phased audit for Obsidian vaults. The skill orchestrates the flow; the user makes every keep/delete/install decision. Nothing destructive happens without explicit confirmation.

## When to invoke

- The user asks for a vault audit, plugin review, vault checkup, or vault lint.
- A major Obsidian version landed and the user wants to know which plugins are now redundant.
- The vault hasn't been reviewed in several months and the plugin list has drifted.
- After importing a vault between machines or onboarding a new vault to this workflow.

## Pre-flight

1. **Confirm the vault path.** If the conversation is happening inside the vault, the working directory is the vault root (the folder containing `.obsidian/`). Otherwise ask the user for the path.
2. **Resolve the audit log path.** Run the resolver in `playbook/05-resolve-audit-log.md`: check `CLAUDE.md` / `AGENTS.md` → check `.obsidian/obsidian-vault-checkup.json` → heuristic search → ask the user if nothing matched. Persist the resolved path on first-time setup so subsequent runs don't re-ask. Default for new vaults: `_meta/audit-log.md`.
3. **Check for the changelog scope/style spec.** If the chosen audit log convention isn't already documented in the vault's `CLAUDE.md` or `AGENTS.md`, offer to add the spec from `playbook/60-changelog-discipline.md`. The spec governs phases 20–60 — without it, log entries drift in tone.

Throughout the rest of this skill, references to "the audit log" mean *the path resolved in pre-flight step 2*, never a hardcoded location.

## Phases

Pre-flight runs first; then the six numbered phases run in order. Each phase has detailed instructions in `playbook/`. You may skip a phase if the user says so, but the default is the full sequence.

| # | Phase | File | Why |
|---|---|---|---|
| 05 | Resolve audit log path | `playbook/05-resolve-audit-log.md` | Find or set the vault's audit log location without hardcoding a convention. Pre-flight step — runs once per session. |
| 10 | Obsidian release review | `playbook/10-release-review.md` | Find out what core absorbed since last checkup — this drives plugin-triage decisions. |
| 20 | Baseline plugin snapshot | `playbook/20-baseline-snapshot.md` | Capture the current plugin state as a rollback reference before any change. |
| 30 | Config hygiene | `playbook/30-config-hygiene.md` | Fix common drift: broken monospace font, sync-conflict cruft, orphaned plugin config. |
| 40 | Plugin triage | `playbook/40-plugin-triage.md` | For each plugin: gather evidence, present, ask, act, log. Cross-references phase 10. |
| 50 | Trending discovery | `playbook/50-trending-discovery.md` | Surface community plugins the user might want, ranked by download count. |
| 60 | Changelog discipline | `playbook/60-changelog-discipline.md` | Consolidate decisions into well-formed audit-log entries. Scope and style spec. |

## Operating rules

- **The user decides; you advise.** Never auto-delete a plugin folder, never auto-enable a plugin, never edit `.obsidian/community-plugins.json` without explicit user confirmation for each change.
- **Probe before recommending.** Use `probes/usage-probes.md` for evidence. "Plugin X has zero in-vault matches for its core syntax" is a useful finding; "X looks unused" is not.
- **Routine cleanup is not logged.** Sync-conflict purges, cache wipes, transient debris. See `playbook/60-changelog-discipline.md`.
- **Meaningful changes are logged.** Plugin lifecycle (enable / disable / install / delete), capability-affecting config changes, schema or tooling decisions. Format: `## [YYYY-MM-DD] <kind> | <title>` with what + why; no procedural instructions to the reader.
- **Cross-platform shell.** Probes are bash scripts. They run under macOS / Linux native and Windows Git Bash. When Claude Code's Bash tool is the executor, this is automatic.

## Outputs

- Edits to `.obsidian/community-plugins.json` and removals from `.obsidian/plugins/` (per-change user confirmation).
- One or more dated entries appended to the vault's audit log (path resolved in pre-flight).
- A summary report at end of session: phases run, decisions made, follow-ups deferred.

## Source

This skill is open source — `https://github.com/JCaet/obsidian-vault-checkup`. Contributions and per-plugin probe additions welcome; see `probes/usage-probes.md` for the catalogue format.
