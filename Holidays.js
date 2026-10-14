// Public holiday lookup for the calendar grid. Kept out of Model.js so the
// stock clock files stay as close to upstream Omarchy as possible.
//
// The data lives in holidays/<CODE>.json, one file per country; Panel.qml
// loads only the countries switched on and passes them in as `data`
// (country -> "yyyy-MM-dd" -> [names]).

// The "holidayCountries" setting: "US,KH", "us kh", or ["US", "KH"]. Unset
// (null) falls back to the country of the system locale (en_US -> US); an
// empty string means holidays are switched off.
function parseCountries(value, localeName) {
  if (value === undefined || value === null) {
    var region = String(localeName || "").split(/[_.@-]/)[1]
    region = String(region || "").toUpperCase()
    return /^[A-Z]{2}$/.test(region) ? [region] : []
  }

  var list = Array.isArray(value)
    ? value
    : String(value).split(/[\s,;]+/)
  var out = []
  for (var i = 0; i < list.length; i++) {
    var code = String(list[i]).replace(/^\s+|\s+$/g, "").toUpperCase()
    // Codes become file names in holidays/, so nothing but two letters.
    if (/^[A-Z]{2}$/.test(code) && out.indexOf(code) === -1) out.push(code)
  }
  return out
}

// The setting value after adding or removing one country.
function withCountry(countries, code) {
  var out = countries.slice()
  if (out.indexOf(code) === -1) out.push(code)
  return out.join(",")
}

function withoutCountry(countries, code) {
  var out = []
  for (var i = 0; i < countries.length; i++) if (countries[i] !== code) out.push(countries[i])
  return out.join(",")
}

// holidays/index.json's [{code, name}] as code -> name.
function namesByCode(index) {
  var out = {}
  for (var i = 0; i < (index || []).length; i++) out[index[i].code] = index[i].name
  return out
}

// Every holiday on a "yyyy-MM-dd" day across the given countries, as
// { country, name } pairs, in the order the countries were listed.
function holidaysOn(key, countries, data) {
  var out = []
  for (var i = 0; i < countries.length; i++) {
    var days = data[countries[i]]
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
