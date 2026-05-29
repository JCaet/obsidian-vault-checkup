# obsidian-vault-checkup

A reusable Claude Code skill for auditing Obsidian vaults — works across vaults, ages well across Obsidian releases, leaves an append-only decision log behind so the next checkup builds on the last.

## What it does

A phased audit that walks a vault and helps you decide what to keep, drop, enable, or install. Each phase produces concrete evidence; you make the calls.

1. **Release review** — fetches Obsidian's recent release notes, surfaces core features that may overlap with installed community plugins.
2. **Baseline snapshot** — generates a full plugin inventory (enabled / disabled, versions, sizes) as a rollback reference.
3. **Config hygiene** — checks `appearance.json` (broken monospace fonts are common), sweeps `*.sync-conflict-*` files, flags orphaned plugin config.
4. **Plugin triage** — for each plugin: runs the catalogued usage probe, presents findings, asks for a decision, acts, then logs.
5. **Trending discovery** — pulls the official `community-plugins.json` and `community-plugin-stats.json`, ranks by download count, filters out what's already installed.
6. **Changelog discipline** — consolidates the session's decisions into a well-formed entry in the vault's audit log (path is resolved per-vault in pre-flight; it never gets hardcoded onto your folders). Scope rules prevent the log from drowning in routine maintenance noise.

The skill never deletes anything without confirmation. You always make the keep/drop call.

## Install

This is a Claude Code skill. Drop it where Claude Code looks for skills:

**macOS / Linux:**

```bash
git clone https://github.com/JCaet/obsidian-vault-checkup ~/.claude/skills/obsidian-vault-checkup
```

**Windows (PowerShell, as administrator for symlinks):**

```powershell
git clone https://github.com/JCaet/obsidian-vault-checkup D:\Projects\obsidian-vault-checkup
New-Item -ItemType SymbolicLink `
  -Path "$env:USERPROFILE\.claude\skills\obsidian-vault-checkup" `
  -Target "D:\Projects\obsidian-vault-checkup"
```

A symlink lets you keep the repo wherever you develop it while still being discoverable as a skill.

## Invoke

In any Claude Code session, after the skill is installed:

```
/obsidian-vault-checkup
```

If the conversation is already inside an Obsidian vault directory, the skill uses that. Otherwise it will ask for the vault path.

## Requirements

- **Claude Code** (the skill is structured as a Claude Code skill).
- **bash** for the probe scripts. On Windows, Claude Code's Bash tool uses Git Bash, so no extra setup is needed when invoked through Claude.
- **`jq`** for the trending-plugins probe (the snapshot probe has a `jq`-free fallback). Install via `apt install jq`, `brew install jq`, or `choco install jq`.
- **`curl`** for fetching the community plugins catalog.

## Project layout

```
obsidian-vault-checkup/
├── SKILL.md                # entry point — skill definition and orchestration
├── README.md               # this file
├── LICENSE                 # MIT
├── playbook/               # per-phase instructions Claude follows
│   ├── 00-overview.md
│   ├── 10-release-review.md
│   ├── 20-baseline-snapshot.md
│   ├── 30-config-hygiene.md
│   ├── 40-plugin-triage.md
│   ├── 50-trending-discovery.md
│   └── 60-changelog-discipline.md
├── probes/                 # evidence-gathering scripts and catalogue
│   ├── usage-probes.md     # per-plugin usage probes (the reusable IP)
│   ├── snapshot-plugins.sh # markdown snapshot generator
│   └── trending-plugins.sh # community-plugins ranker
└── templates/
    └── audit-log.md        # starter audit log for new vaults
```

## Contributing

The most valuable contribution is **new probes** in `probes/usage-probes.md`. Format:

```markdown
## <plugin-id>
What it does: <one line>
Probe: `<shell command or pattern>`
Active when: <what counts as a positive signal>
Replacement when inactive: <core feature or alternative plugin, if any>
```

Bug fixes and playbook improvements via pull request. Commits follow [Conventional Commits](https://www.conventionalcommits.org/).

## License

MIT — see `LICENSE`.
