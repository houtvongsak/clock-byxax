# clock-byxax

Omarchy's built-in clock and calendar (`omarchy.clock`), kept in step with
upstream, plus:

- **Public holidays in red** for any of ~250 countries, with the holiday
  name on hover. Lunar-calendar holidays (Khmer New Year, Pchum Ben, …)
  included.
- **Settings**: the gear in the popup's corner (or `s`) picks holiday
  countries (searchable), the week start, the bar label format, and opens
  Omarchy's timezone picker (shown with its UTC offset).
- **Shortcut cheat sheet**: press `?` (or Ctrl+?) in the calendar popup to
  see every key and mouse action; `?` or Esc puts it away.

## Install

```sh
omarchy plugin add https://github.com/houtvongsak/clock-byxax.git --enable
```

It replaces the built-in clock in the same bar slot. `omarchy plugin remove
io.github.houtvongsak.clock-byxax` puts the stock clock back.

## Holidays

Pick countries in Settings → Holidays in red. Until you do, it uses your
locale's country (`en_US` → US).

Dates come from [python-holidays](https://github.com/vacanza/holidays), one
file per country in `holidays/`, covering this year −5 to +10. Only the
countries you pick are loaded, and nothing is fetched at runtime. A GitHub
Action regenerates the data every January, so `omarchy plugin update` keeps
it current — no manual steps.

## Staying on top of upstream Omarchy

- `upstream` branch: the stock clock files, untouched.
- `main` branch: this plugin's changes, with `upstream` merged in.

After an Omarchy update:

```sh
bin/sync-upstream
```

It copies the installed stock clock (`/usr/share/omarchy/shell/plugins/panels/clock`)
onto `upstream` and merges it into `main`; then `git push`. Changes are kept in new files
(`Holidays.js`, `HolidayStore.qml`, `SettingsOverlay.qml`,
`ShortcutsOverlay.qml`) with only small hooks in `Panel.qml`, so conflicts
stay rare.
