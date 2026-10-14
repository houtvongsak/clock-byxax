.import "HolidayData.js" as Data

// Public holiday lookup for the calendar grid. Kept out of Model.js so the
// stock clock files stay as close to upstream Omarchy as possible.

var HOLIDAYS = Data.HOLIDAYS

// The "holidayCountries" setting: "US,KH", "us kh", or ["US", "KH"]. Unset
// falls back to the country of the system locale (en_US -> US).
function parseCountries(value, localeName) {
  var list = Array.isArray(value)
    ? value
    : String(value === undefined || value === null ? "" : value).split(/[\s,;]+/)
  var out = []
  for (var i = 0; i < list.length; i++) {
    var code = String(list[i]).replace(/^\s+|\s+$/g, "").toUpperCase()
    if (code !== "" && out.indexOf(code) === -1) out.push(code)
  }
  if (out.length > 0) return out

  var region = String(localeName || "").split(/[_-]/)[1]
  return region ? [region.toUpperCase()] : []
}

// Every holiday on a "yyyy-MM-dd" day across the given countries, as
// { country, name } pairs, in the order the countries were listed.
function holidaysOn(key, countries) {
  var out = []
  for (var i = 0; i < countries.length; i++) {
    var days = HOLIDAYS[countries[i]]
    var names = days ? days[key] : null
    if (!names) continue
    for (var j = 0; j < names.length; j++) out.push({ country: countries[i], name: names[j] })
  }
  return out
}

// Tooltip text: one holiday per line, prefixed by its country only when more
// than one country is shown.
function describe(entries, countryCount) {
  var lines = []
  for (var i = 0; i < entries.length; i++)
    lines.push((countryCount > 1 ? entries[i].country + " · " : "") + entries[i].name)
  return lines.join("\n")
}
