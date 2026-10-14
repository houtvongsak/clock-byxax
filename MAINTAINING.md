# Maintaining clock-byxax

Two GitHub Actions keep the plugin current; normally nothing needs doing.

## Following Omarchy — `.github/workflows/sync-omarchy.yml`

- `upstream` branch: Omarchy's stock clock files, never edited by hand.
- `main` branch: this plugin — `upstream` merged in, plus our changes.

Every Monday the job takes `shell/plugins/panels/clock` from Omarchy's latest
release tag (not the development branch, so it matches what users have
installed), commits it to `upstream`, and merges `upstream` into `main`.
`manifest.json` is ours and is never synced.

If the merge conflicts, `main` is left alone, the run fails, and an issue is
opened listing the files. To resolve:

```sh
git pull
git merge origin/upstream   # fix conflicts, then
git commit && git push
```

Run it any time from Actions → Sync with Omarchy → Run workflow.

To keep conflicts rare, put new features in new files (`Holidays.js`,
`HolidayStore.qml`, `SettingsOverlay.qml`, `ShortcutsOverlay.qml`) and keep
edits to the stock files (`Panel.qml`, `BarWidget.qml`, `Model.js`) to small
hooks.

## Holiday data — `.github/workflows/holidays.yml`

Every January 2 the job reruns `bin/generate-holidays` with the latest
python-holidays and commits `holidays/` if anything changed, moving the
window to this year −5 … +10. To run it locally:

```sh
pip install holidays
bin/generate-holidays
```

## Developing locally

The plugin folder is a symlink to this repo:

```sh
ln -s "$PWD" ~/.config/omarchy/plugins/io.github.houtvongsak.clock-byxax
```

Omarchy's file watcher does not follow symlinks, and a plugin rescan can leave
the old instance answering IPC, so after editing run `omarchy-restart-shell`.
