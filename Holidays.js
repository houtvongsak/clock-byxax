.import "HolidayData.js" as Data

// Public holiday lookup for the calendar grid. Kept out of Model.js so the
// stock clock files stay as close to upstream Omarchy as possible.

var HOLIDAYS = Data.HOLIDAYS
var COUNTRY_NAMES = Data.COUNTRY_NAMES

// The "holidayCountries" setting: "US,KH", "us kh", or ["US", "KH"]. Unset
// (null) falls back to the country of the system locale (en_US -> US); an
// empty string means holidays are switched off.
function parseCountries(value, localeName) {
  if (value === undefined || value === null) {
    var region = String(localeName || "").split(/[_-]/)[1]
    return region ? [region.toUpperCase()] : []
  }

  var list = Array.isArray(value)
    ? value
    : String(value).split(/[\s,;]+/)
  var out = []
  for (var i = 0; i < list.length; i++) {
    var code = String(list[i]).replace(/^\s+|\s+$/g, "").toUpperCase()
    if (code !== "" && out.indexOf(code) === -1) out.push(code)
  }
  return out
}

// Countries the bundled data covers, in the order they were generated.
function availableCountries() {
  return Object.keys(HOLIDAYS)
}

function countryName(code) {
  return COUNTRY_NAMES[code] || code
}

// The setting value after switching one country on or off.
function toggledCountries(countries, code) {
  var out = countries.slice()
  var at = out.indexOf(code)
  if (at === -1) out.push(code)
  else out.splice(at, 1)
  return out.join(",")
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
