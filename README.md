# clock-byxax

Omarchy's built-in clock and calendar (`omarchy.clock`), kept in step with
upstream, plus:

- **Public holidays in red**, with the holiday name on hover. Ships US and
  Cambodia (KH); any country is one command away.
- **Settings**: the gear in the popup's corner (or `s`) switches holiday
  countries on and off, picks the week start, and picks the bar label format.
- **Shortcut cheat sheet**: press `?` (or Ctrl+?) in the calendar popup to
  see every key and mouse action; `?` or Esc puts it away.

## Install

```sh
omarchy plugin add https://github.com/houtvongsak/clock-byxax.git --enable
```

It replaces the built-in clock in the same bar slot. `omarchy plugin remove
io.github.houtvongsak.clock-byxax` puts the stock clock back.

## Holidays

Pick countries with `holidayCountries` on the widget's entry in
`~/.config/omarchy/shell.json` (unset = your locale's country):

```json
{ "id": "io.github.houtvongsak.clock-byxax", "holidayCountries": "US,KH" }
```

Holiday dates come from [python-holidays](https://github.com/vacanza/holidays)
and are baked into `HolidayData.js` (current year −5 to +10), so nothing is
fetched at runtime. To add countries or refresh the data:

```sh
pip install holidays
bin/generate-holidays US KH   # ISO 3166-1 alpha-2 codes
```

## Staying on top of upstream Omarchy

- `upstream` branch: the stock clock files, untouched.
- `main` branch: this plugin's changes, rebased on `upstream`.

After an Omarchy update:

```sh
bin/sync-upstream
```

It copies the installed stock clock (`/usr/share/omarchy/shell/plugins/panels/clock`)
onto `upstream` and rebases `main` on top. Changes are kept in new files
(`Holidays.js`, `HolidayData.js`) with only small hooks in `Panel.qml`, so
conflicts stay rare.
