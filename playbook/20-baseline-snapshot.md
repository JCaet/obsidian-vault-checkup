# Phase 20 — Baseline plugin snapshot

**Goal:** Capture the current plugin state as a rollback reference *before any change is made*. This is the only phase that writes to the changelog before user-driven decisions land.

## Steps

1. **Run the snapshot probe:**

   ```bash
   probes/snapshot-plugins.sh <vault-path>
   ```

   Output is a pair of markdown tables (enabled / disabled) with versions, ready to drop into a changelog entry.

2. **Determine totals:**
   - `total = ls .obsidian/plugins/ | wc -l`
   - `enabled = length of community-plugins.json array`
   - `disabled = total - enabled`

3. **Inspect for known config issues** (also covered in phase 30, but worth noting at snapshot time so the rollback record captures the *real* state):
   - `appearance.json` — read `monospaceFontFamily`; flag if it's a proportional font (`Inter`, `Segoe UI`, `Arial`, anything not ending in `Mono` / `Code` / `Console` / `Consolas`).
   - Sync-conflict files — count `*.sync-conflict-*` under `.obsidian/`.
   - `core-plugins.json` — note whether `bases` is enabled (drives phase 40 decisions for DataLoom / Dataview).
   - Any plugin `data.json` with plaintext-looking secrets (`api_key`, `token`, `secret`). Surface to user as a security note; do not log the secret itself.

4. **Append a `snapshot` entry to the audit log** (path resolved in pre-flight 05):

   ```markdown
   ## [YYYY-MM-DD] snapshot | Plugin baseline before <Month YYYY> checkup

   Captured prior to acting on the <Month YYYY> checkup. Rollback reference for any change that follows.

   **Totals:** N plugin folders on disk — E enabled, D disabled.

   ### Enabled (E)
   <table from snapshot-plugins.sh>

   ### Installed but disabled (D)
   <table from snapshot-plugins.sh>

   ### Core plugin notes
   - Bases: enabled / disabled
   - <other notable core plugins>

   ### Known config issues at this snapshot
   - <font issue>
   - <N sync-conflict files in .obsidian/>
   - <plugin data.json with apparent secrets>

   ### Reinstall pointers
   Community plugins reinstall cleanly from inside Obsidian (Settings → Community plugins → Browse) by their slug — folder names match Obsidian's plugin IDs. Pinning to a specific past version requires manually replacing the plugin folder with a release artifact from the plugin's GitHub repo.
   ```

5. **Move on to phase 30.** The baseline is now logged; the rest of the session is allowed to change vault state.

## Notes

- Do **not** add unnecessary commentary to the snapshot (no "this plugin is great", no "consider removing"). The snapshot is a state record, not an opinion.
- The snapshot is the only `snapshot` kind in the changelog. Other entries use `plugin`, `config`, `refactor`, or `note`.
- If the resolved audit log file does not yet exist, create it from `templates/audit-log.md` first, then write the snapshot as its inaugural entry. The default H1 inside the template is `# Audit Log` — adjust if the user chose a different filename and prefers a matching heading.
