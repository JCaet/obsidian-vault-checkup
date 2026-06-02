# Pre-flight 05 — Resolve the vault's audit log path

**Goal:** Find (or create) the path where this skill writes its decisions, *without imposing a one-size-fits-all convention on the user*. Run this before any phase that writes to the log (i.e., before phase 20).

The audit log is a vault-resident markdown file the skill appends to. Conceptually it's a changelog of major vault decisions — many users prefer to think of it as an audit log, hence the name used throughout the skill. Default path for new vaults: `_meta/audit-log.md`.

## Resolution order

Stop at the first source that yields a usable path.

### 1. Vault `CLAUDE.md` / `AGENTS.md`

Search the vault root for either file. In each found file, grep for a parseable convention key:

```
**Audit log:** `<path>`
```

The path is the backticked value. Both files are checked; if both have one and they disagree, prefer `CLAUDE.md` and flag the inconsistency to the user.

### 2. Skill-owned config file

Check `.obsidian/obsidian-vault-checkup.json`:

```json
{
  "auditLogPath": "_meta/audit-log.md"
}
```

The `auditLogPath` is vault-relative. Other keys (e.g. `lastCheckupDate`) may exist alongside; ignore them at this step.

### 3. Heuristic file search

Look for an existing file matching common patterns:

```
_meta/audit-log.md
_meta/Audit Log.md
_meta/Vault Changelog.md
_meta/CHANGELOG.md
_admin/audit-log.md
_logs/audit-log.md
.meta/audit-log.md
audit-log.md           (vault root)
CHANGELOG.md           (vault root)
```

- **Exactly one match:** auto-use, mention in conversation ("Found `<path>`, using it as the audit log"). Persist the choice (see below) so future runs skip the heuristic.
- **Multiple matches:** ask the user which to use. Persist the choice.
- **Zero matches:** proceed to step 4.

### 4. Ask the user (first-time setup)

When no existing audit log is found, ask:

> No audit log was found in this vault. The skill needs a markdown file to append decisions to. Where would you like it?
>
> 1. `_meta/audit-log.md` *(recommended; matches the Obsidian wiki-meta convention)*
> 2. `<vault-root>/audit-log.md` *(simpler, visible in the file tree)*
> 3. Custom path

If the user picks a custom path, accept any vault-relative `.md` path. Reject paths inside `Clippings/`, `.trash/`, `.obsidian/`, or other folders that are conventionally immutable or hidden from the vault content surface.

## Persistence

After resolution, persist the choice so the resolver doesn't re-ask next run.

### Primary: vault `CLAUDE.md` / `AGENTS.md`

If at least one of `CLAUDE.md` or `AGENTS.md` exists at the vault root, add (or update) the convention line in the file's vault-changelog section, or append a new minimal section if none exists:

```markdown
## Vault audit log (`obsidian-vault-checkup` skill)

**Audit log:** `<path>`

Append-only log of major vault changes (plugin lifecycle, capability-affecting config, schema changes). Managed by the `obsidian-vault-checkup` skill. See the skill's `playbook/60-changelog-discipline.md` for scope and format rules.
```

Write to both files if both exist (they should stay in sync). If neither exists, fall through to the skill config.

### Fallback: `.obsidian/obsidian-vault-checkup.json`

For vaults without `CLAUDE.md` or `AGENTS.md`, write:

```json
{
  "auditLogPath": "<path>"
}
```

Create the file if it doesn't exist. Preserve other keys if it does.

## Audit-log file creation

If the resolved path's file does not yet exist, **do not create it now**. Phase 20 (baseline snapshot) creates it as part of writing the inaugural snapshot entry. Use `templates/audit-log.md` as the seed content; replace the H1 to match the user's preferred filename if it's not the default `audit-log.md`.

## Sanity checks

After resolution, before proceeding:

- The resolved path is vault-relative (no `..` traversal, no absolute path).
- The resolved path is `.md`.
- The parent directory either exists or can be created safely (not inside `Clippings/`, `.trash/`, or `.obsidian/`).
- If the file exists, it parses as markdown (has at least a recognizable H1 or the standard log structure).

If any check fails, surface the issue to the user and re-resolve.

## Output to other phases

After 05 finishes, other phases receive the resolved path. Throughout this skill's playbook files, references to "the audit log" mean *this resolved path*, not any hardcoded location.
