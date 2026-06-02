# Contributing

Thanks for helping improve **obsidian-vault-checkup**. This is a Claude Code plugin wrapping
a single skill, so "the code" is mostly Markdown instructions
(`skills/obsidian-vault-checkup/playbook/`), two Bash probes
(`skills/obsidian-vault-checkup/probes/`), and the probe catalogue
(`skills/obsidian-vault-checkup/probes/usage-probes.md`).

## Most valuable contribution: new probes

The probe catalogue is the reusable core of the skill. A good probe finds *evidence of use*
inside a vault — not merely that a plugin is installed. Add entries to
`skills/obsidian-vault-checkup/probes/usage-probes.md` using this format:

```markdown
## <plugin-id>
What it does: <one line>
Probe: `<shell command or pattern>`
Active when: <what counts as a positive signal>
Replacement when inactive: <core feature or alternative plugin, if any>
```

Open a [New plugin probe](../../issues/new?template=new_probe.yml) issue to propose one, or
send a pull request directly.

## Development notes

- **Shell scripts** (`skills/obsidian-vault-checkup/probes/*.sh`) target Bash and must run on macOS, Linux, and Windows
  Git Bash. Keep them POSIX-friendly and quote your variables — CI runs `shellcheck` on
  every push and pull request.
- **Markdown** is linted with `markdownlint-cli2`; configuration lives in
  `.markdownlint.json`. Run it locally before pushing if you have Node:

  ```bash
  npx markdownlint-cli2 "**/*.md"
  ```

- **Line endings:** `.gitattributes` forces LF on `*.sh` (CRLF breaks the shebang on
  Unix). Don't override it.

## Commits and pull requests

- Follow [Conventional Commits](https://www.conventionalcommits.org/)
  (`feat:`, `fix:`, `docs:`, `chore:`, …).
- Keep pull requests focused; one logical change per PR.
- Make sure both CI checks (shellcheck, markdownlint) pass.

## Reporting bugs

Use the [Bug report](../../issues/new?template=bug_report.yml) template and include your OS,
shell, and the phase where the problem occurred.
