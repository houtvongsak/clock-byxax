# clock-byxax

Omarchy's built-in clock and calendar, plus:

- **Public holidays in red** for any of ~250 countries, with the holiday
  name on hover. Lunar-calendar holidays (Khmer New Year, Pchum Ben, …)
  included.
- **Settings**: the gear in the popup's corner (or `s`) picks holiday
  countries, the week start, the bar label format, and opens Omarchy's
  timezone picker (shown with its UTC offset).
- **Shortcut cheat sheet**: press `?` (or Ctrl+?) in the calendar popup to
  see every key and mouse action.

Everything else is Omarchy's own clock, kept in step with each Omarchy
release automatically.

## Install

```sh
omarchy plugin add https://github.com/houtvongsak/clock-byxax.git --enable --yes
```

It replaces the built-in clock in the same bar slot, keeping your clock
settings. Pick your holiday countries in Settings; until then it uses your
locale's country (`en_US` → US).

## Update

```sh
omarchy plugin update io.github.houtvongsak.clock-byxax
```

This brings in the latest Omarchy clock changes and holiday data.

## Uninstall

```sh
omarchy plugin remove io.github.houtvongsak.clock-byxax
```

The stock clock comes back where it was.

## Credits

Based on `omarchy.clock` from [Omarchy](https://github.com/basecamp/omarchy).
Holiday dates from [python-holidays](https://github.com/vacanza/holidays);
nothing is fetched at runtime.
