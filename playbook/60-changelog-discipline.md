# Phase 60 — Changelog discipline

**Goal:** Consolidate the session's decisions into a small number of well-formed entries in the vault's audit log (path resolved in pre-flight 05). The log is meant to age into a reliable track record of which features and plugins were used over time and why they came or went.

## Scope (what to log)

**Log entries are for major vault changes.** Specifically:

- **Plugin lifecycle:** enable, disable, install, delete.
- **Configuration changes that alter capabilities or vault-wide behavior** — core plugin toggles, theme or snippet changes, monospace font replacement, sync-model changes.
- **Schema or pattern changes** — new conventions in `_knowledge-base/CLAUDE.md`, folder reshuffles, naming-rule changes.
- **Decisions about the tooling stack worth preserving** — why a plugin was kept or dropped, what (if anything) replaced it.

## Out of scope (do not log)

- Routine cleanup: sync-conflict purges, cache wipes, transient debris cleanup.
- Day-to-day note editing or content additions.
- Purely cosmetic tweaks that don't materially change how the vault behaves.

Asked another way: *would a future-you trying to reconstruct this vault's history want this entry in the record?* If yes, log it. If it's repeatable maintenance, no.

## Entry format

```markdown
## [YYYY-MM-DD] <kind> | <short title>

<one-paragraph statement of what changed>

Reason: <what motivated the change — link to evidence, prior incidents, deliberate decisions>

<optional: notable side effects, follow-ups, replacements>
```

Kinds: `snapshot`, `plugin`, `config`, `refactor`, `note`.

## Style rules

- **What + why, not how-to.** The log is historical record, not a runbook. Don't include imperative instructions ("restart Obsidian", "run X next", "remember to Y") — those belong in conversation or in a separate runbook, not in the log.
- **Plain declarative sentences.** No marketing prose. No emojis unless the user adds them.
- **Bundle related changes.** A bulk plugin cleanup is one entry with a per-plugin table, not seven entries with the same date.
- **Append-only.** Never edit past entries. If facts change, write a new entry.

## When the vault doesn't have an audit log yet

Before doing anything else, create the audit log file at the path resolved in pre-flight 05, using `templates/audit-log.md` as seed content. The phase-20 baseline snapshot is the inaugural entry.

## When the vault doesn't have the spec documented

Check the vault root for `CLAUDE.md` and `AGENTS.md`. If neither documents the audit-log scope + style + format, offer to add the following block to both (they should stay in sync). The `**Audit log:**` line is what the pre-flight 05 resolver picks up on subsequent runs — it must be present.

```markdown
## Vault audit log

**Audit log:** `<resolved-path>`

Append-only log of **major** vault changes — its purpose is to keep a track record of which features and plugins have been used over time, and why they came or went, so a future read can reconstruct the decision history. Managed (in part) by the `obsidian-vault-checkup` skill.

**Update it for:**
- Plugin lifecycle: enable, disable, install, delete.
- Configuration changes that alter capabilities or vault-wide behavior (core plugin toggles, theme/snippet changes, sync-model changes).
- Schema / pattern changes (e.g., a new convention in a sub-folder CLAUDE.md, folder reshuffles, naming-rule changes).
- Decisions about the tooling stack worth preserving (why a plugin was kept or dropped, what replaced it).

**Do not update it for:**
- Routine cleanup (sync-conflict purges, cache wipes, transient debris).
- Day-to-day note editing or content additions.
- Purely cosmetic tweaks that don't materially change how the vault behaves.

Entry format: `## [YYYY-MM-DD] <kind> | <short title>` followed by what changed and **why**. Kinds: `snapshot`, `plugin`, `config`, `refactor`, `note`. The log is historical record — write what happened and the reason; do not include imperative instructions to the reader ("restart X", "run Y").
```

If the vault uses Syncthing, iCloud, Obsidian Sync, Dropbox, git, or another file-sync system, also offer to add a short "Sync model" section. Suggested wording:

```markdown
## Sync model

The vault syncs across multiple devices via **<sync system>**. Practical consequences to keep in mind:

- `*.sync-conflict-*` (or equivalent) siblings periodically appear in `.obsidian/` when the same file is edited on two devices before sync settles. They are routine debris — Obsidian only reads the canonical filename. Cleaning them up is housekeeping, not a notable change.
- `.obsidian/workspace.json` is the highest-churn file (pane layout per device), so it generates the most conflicts.
- Anything written under `.obsidian/plugins/*/data.json` may contain secrets (API keys, tokens). Treat plugin config as potentially sensitive when reasoning about the vault being synced.
```

## Final report

At the end of the checkup session, summarize for the user — in conversation, not in the audit log:

- Phases run, phases skipped.
- Plugins removed, enabled, kept-disabled.
- Config changes applied.
- Trending plugins surfaced (if any).
- **Follow-ups deferred** — trial-disable plugins to revisit, plugins kept-disabled for upcoming work, secret-scan flags to address out-of-band.

Surface follow-ups clearly so the next audit (or a one-off ask) knows where to pick up.
