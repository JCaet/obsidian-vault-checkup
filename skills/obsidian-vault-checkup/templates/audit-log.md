# Audit Log

Append-only log of major structural changes to the vault: plugin add/remove/disable, config rewrites that alter capabilities or vault-wide behavior, folder reshuffles, schema changes. Managed (in part) by the `obsidian-vault-checkup` skill — but ordinary editing of this file is fine; the skill only appends.

Read top-down for the most recent state; scroll for history.

Format: each entry begins with `## [YYYY-MM-DD] <kind> | <short title>` so the file stays grep-able. Kinds: `snapshot`, `plugin`, `config`, `refactor`, `note`.

Scope: log **major** changes — the purpose is to keep a track record of which features and plugins were used over time, and why they came or went, so a future read can reconstruct the decision history. Do **not** log routine maintenance (sync-conflict purges, cache wipes), day-to-day note editing, or purely cosmetic tweaks that don't materially change vault behavior.

Style: entries describe **what** changed and **why**. The log is historical record, not a runbook — do not include imperative instructions to the reader ("restart Obsidian", "run X next").

---

<!--
Inaugural snapshot goes below. The obsidian-vault-checkup skill's
phase-20 baseline writes this entry on first run.

Template entry — replace with real data:

## [YYYY-MM-DD] snapshot | Plugin baseline before <Month YYYY> checkup

Captured prior to acting on the <Month YYYY> checkup. Rollback reference for any change that follows.

**Totals:** N plugin folders on disk — E enabled, D disabled.

### Enabled (E)

| Plugin folder | Version |
|---|---|

### Installed but disabled (D)

| Plugin folder | Version |
|---|---|

### Core plugin notes

- Bases: enabled / disabled

### Known config issues at this snapshot

- <none / list>

### Reinstall pointers

Community plugins reinstall cleanly from inside Obsidian (Settings → Community plugins → Browse) by their slug — folder names match Obsidian's plugin IDs. Pinning to a specific past version requires manually replacing the plugin folder with a release artifact from the plugin's GitHub repo.
-->
