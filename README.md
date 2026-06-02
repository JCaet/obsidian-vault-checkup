# obsidian-vault-checkup

A reusable Claude Code plugin for auditing Obsidian vaults — works across vaults, ages well across Obsidian releases, leaves an append-only decision log behind so the next checkup builds on the last. The plugin ships a single skill of the same name.

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

This is a Claude Code plugin distributed from its own one-plugin marketplace. Add the marketplace, then install:

```bash
claude plugin marketplace add JCaet/obsidian-vault-checkup
claude plugin install obsidian-vault-checkup@obsidian-vault-checkup
```

The first argument to `install` is the plugin name; the part after `@` is the marketplace name (both happen to match the repo).

### Local development

To work on the plugin from a local clone, add the working tree as a marketplace by path:

```bash
git clone https://github.com/JCaet/obsidian-vault-checkup
claude plugin marketplace add ./obsidian-vault-checkup
claude plugin install obsidian-vault-checkup@obsidian-vault-checkup
```

## Invoke

In any Claude Code session, after the plugin is installed, call the skill by its namespaced name (`plugin:skill`):

```
/obsidian-vault-checkup:obsidian-vault-checkup
```

You can also just ask Claude to "audit my Obsidian vault" — the skill's description triggers it. If the conversation is already inside an Obsidian vault directory, the skill uses that; otherwise it will ask for the vault path.

## Requirements

- **Claude Code** (the skill is structured as a Claude Code skill).
- **bash** for the probe scripts. On Windows, Claude Code's Bash tool uses Git Bash, so no extra setup is needed when invoked through Claude.
- **`jq`** for the trending-plugins probe (the snapshot probe has a `jq`-free fallback). Install via `apt install jq`, `brew install jq`, or `choco install jq`.
- **`curl`** for fetching the community plugins catalog.

## Project layout

```
obsidian-vault-checkup/
├── .claude-plugin/
│   ├── plugin.json             # plugin manifest
│   └── marketplace.json        # one-plugin marketplace catalog
├── README.md                   # this file
├── LICENSE                     # MIT
├── CONTRIBUTING.md
└── skills/
    └── obsidian-vault-checkup/
        ├── SKILL.md            # entry point — skill definition and orchestration
        ├── playbook/           # per-phase instructions Claude follows
        │   ├── 00-overview.md
        │   ├── 10-release-review.md
        │   ├── 20-baseline-snapshot.md
        │   ├── 30-config-hygiene.md
        │   ├── 40-plugin-triage.md
        │   ├── 50-trending-discovery.md
        │   └── 60-changelog-discipline.md
        ├── probes/             # evidence-gathering scripts and catalogue
        │   ├── usage-probes.md     # per-plugin usage probes (the reusable IP)
        │   ├── snapshot-plugins.sh # markdown snapshot generator
        │   └── trending-plugins.sh # community-plugins ranker
        └── templates/
            └── audit-log.md    # starter audit log for new vaults
```

## Contributing

The most valuable contribution is **new probes** in `skills/obsidian-vault-checkup/probes/usage-probes.md`. Format:

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
