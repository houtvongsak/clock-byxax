import QtQuick
import Quickshell.Io
import "Holidays.js" as Holidays

// Loads holiday data from holidays/: index.json once (every country, for the
// settings picker) and <CODE>.json for just the countries switched on,
// re-read whenever that list changes. All local files; nothing goes online.
Item {
  id: root

  property var countries: []

  // country -> "yyyy-MM-dd" -> [names], for the countries switched on.
  property var data: ({})
  // [{code, name}] sorted by name, and the same as code -> name.
  property var index: []
  readonly property var names: Holidays.namesByCode(index)
  property var years: []

  readonly property string dir: decodeURIComponent(String(Qt.resolvedUrl("holidays")).replace(/^file:\/\//, ""))

  function reload() {
    loader.running = false
    if (root.countries.length === 0) {
      root.data = ({})
      return
    }
    loader.command = ["sh", "-c",
      "d=$1; shift; for c; do [ -f \"$d/$c.json\" ] && { printf '%s\\t' \"$c\"; cat \"$d/$c.json\"; }; done",
      "sh", root.dir].concat(root.countries)
    loader.running = true
  }

  onCountriesChanged: Qt.callLater(reload)
  Component.onCompleted: reload()

  // One line per country: CODE<TAB>{json}. Each data file is a single line.
  Process {
    id: loader
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        var next = {}
        var lines = String(text || "").split("\n")
        for (var i = 0; i < lines.length; i++) {
          var tab = lines[i].indexOf("\t")
          if (tab <= 0) continue
          try { next[lines[i].substring(0, tab)] = JSON.parse(lines[i].substring(tab + 1)) } catch (e) {}
        }
        root.data = next
      }
    }
  }

  FileView {
    path: root.dir + "/index.json"
    printErrors: false
    onLoaded: {
      try {
        var parsed = JSON.parse(text())
        root.index = parsed.countries || []
        root.years = parsed.years || []
      } catch (e) {}
    }
  }
}
