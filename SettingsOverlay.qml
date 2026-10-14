import QtQuick
import Quickshell.Io
import qs.Commons
import qs.Ui
import "Model.js" as Model
import "Holidays.js" as Holidays

// Settings for the clock, laid over the calendar grid — opened with the gear
// in the popup's corner or "s". It only reports choices; Panel.qml writes
// them to shell.json the same way the "W" week-start toggle does. Kept in
// its own file so Panel.qml, which tracks upstream Omarchy, only carries the
// hook that shows it.
Rectangle {
  id: root

  property color foreground: Color.foreground
  property string fontFamily: Style.font.family

  property var countries: []
  property var countryIndex: []
  property var countryNames: ({})
  property var holidayYears: []
  property int weekStart: 1
  property var formats: []
  property string currentFormat: ""
  property date now: new Date()

  signal holidayCountriesPicked(string value)
  signal weekStartPicked(int day)
  signal formatPicked(string format)
  signal timezoneRequested()
  signal dismissed()

  // The search popup owns typing while it is open, so the calendar's own
  // keys (h/l, t, s, ...) must stand down.
  readonly property bool capturingKeys: countryPicker.popupOpen

  // Every country not already on, labelled "Cambodia  KH" so either the name
  // or the code finds it.
  readonly property var addableCountries: {
    var out = []
    for (var i = 0; i < countryIndex.length; i++) {
      var c = countryIndex[i]
      if (countries.indexOf(c.code) === -1) out.push({ value: c.code, label: c.name + "  " + c.code })
    }
    return out
  }
  property string timezone: ""
  property string utcOffset: ""

  // Read fresh each time the view opens, since the picker changes it behind
  // our back.
  onVisibleChanged: if (visible) timezoneProcess.running = true

  Process {
    id: timezoneProcess
    command: ["sh", "-c", "timedatectl show -p Timezone --value; date +%:z"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        var lines = String(text || "").trim().split("\n")
        root.timezone = (lines[0] || "").trim()
        root.utcOffset = (lines[1] || "").trim()
      }
    }
  }

  // A format as the bar would show it right now; stacked vertical formats
  // are flattened onto one line.
  function preview(format) {
    var withWeek = String(format).replace(/ww/g, Model.isoWeekLiteral(now.getFullYear(), now.getMonth(), now.getDate()))
    return Qt.formatDateTime(now, withWeek).split("\n").join(" · ")
  }

  color: Color.popups.background

  // Swallows clicks and scrolls so the calendar underneath stays put.
  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.AllButtons
    onWheel: function(wheel) { wheel.accepted = true }
  }

  PanelActionButton {
    anchors.top: parent.top
    anchors.right: parent.right
    anchors.margins: Style.space(4)
    iconText: "󰅖"
    tooltipText: "Close settings (Esc)"
    foreground: root.foreground
    fontFamily: root.fontFamily
    onClicked: root.dismissed()
  }

  Column {
    anchors.centerIn: parent
    spacing: Style.space(14)

    Text {
      anchors.horizontalCenter: parent.horizontalCenter
      text: "SETTINGS"
      color: root.foreground
      font.family: root.fontFamily
      font.pixelSize: Style.font.body
      font.letterSpacing: 2
      font.bold: true
    }

    // ---- Holidays: the countries switched on, each removable, and a
    //      searchable picker over every country the data covers.
    Column {
      spacing: Style.space(6)

      PanelSectionHeader {
        text: "HOLIDAYS IN RED" + (root.holidayYears.length === 2 ? "  ·  " + root.holidayYears[0] + "–" + root.holidayYears[1] : "")
        foreground: root.foreground
        fontFamily: root.fontFamily
      }

      Flow {
        width: Style.space(420)
        spacing: Style.space(6)

        Repeater {
          model: root.countries

          Button {
            required property string modelData
            text: (root.countryNames[modelData] || modelData) + "  " + modelData
            iconText: "󰅖"
            tooltipText: "Stop showing these holidays"
            bordered: true
            foreground: root.foreground
            fontFamily: root.fontFamily
            fontSize: Style.font.bodySmall
            onClicked: root.holidayCountriesPicked(Holidays.withoutCountry(root.countries, modelData))
          }
        }

        SearchableDropdown {
          id: countryPicker
          width: Style.space(180)
          showLabel: false
          value: ""
          options: root.addableCountries
          triggerLabel: "Add country…"
          placeholderText: "Country or code…"
          foreground: root.foreground
          fontFamily: root.fontFamily
          onChanged: function(code) {
            if (code === "") return
            root.holidayCountriesPicked(Holidays.withCountry(root.countries, code))
            countryPicker.value = ""
          }
        }
      }
    }

    // ---- Week start, the same choice as clicking "W" on the grid, beside
    //      the timezone, which hands off to Omarchy's own picker — the same
    //      one middle-clicking the bar clock opens.
    Row {
      spacing: Style.space(40)

      Column {
        spacing: Style.space(6)

        PanelSectionHeader {
          text: "WEEK STARTS ON"
          foreground: root.foreground
          fontFamily: root.fontFamily
        }

        ButtonGroup {
          options: [{ value: "1", label: "Monday" }, { value: "0", label: "Sunday" }]
          value: String(root.weekStart)
          foreground: root.foreground
          fontFamily: root.fontFamily
          fontSize: Style.font.bodySmall
          focusable: false
          onChanged: function(value) { root.weekStartPicked(parseInt(value, 10)) }
        }
      }

      Column {
        spacing: Style.space(6)

        PanelSectionHeader {
          text: "TIMEZONE"
          foreground: root.foreground
          fontFamily: root.fontFamily
        }

        Button {
          text: root.timezone === ""
            ? "Pick timezone"
            : root.timezone + (root.utcOffset !== "" ? "  UTC" + root.utcOffset : "")
          iconText: "󰥔"
          tooltipText: "Open Omarchy's timezone picker"
          bordered: true
          foreground: root.foreground
          fontFamily: root.fontFamily
          fontSize: Style.font.bodySmall
          onClicked: root.timezoneRequested()
        }
      }
    }

    // ---- Bar label: every format right-click cycles through, previewed.
    Column {
      spacing: Style.space(2)

      PanelSectionHeader {
        text: "BAR LABEL"
        foreground: root.foreground
        fontFamily: root.fontFamily
      }

      Repeater {
        model: root.formats

        Rectangle {
          id: formatRow
          required property string modelData
          readonly property bool current: modelData === root.currentFormat

          width: Style.space(300)
          height: formatText.implicitHeight + Style.space(6)
          radius: Style.cornerRadius
          color: formatMouse.containsMouse
            ? Style.hoverFillFor(root.foreground, Color.accent)
            : "transparent"

          Text {
            id: formatText
            anchors.left: parent.left
            anchors.leftMargin: Style.space(6)
            anchors.verticalCenter: parent.verticalCenter
            text: (formatRow.current ? "●  " : "○  ") + root.preview(formatRow.modelData)
            color: formatRow.current ? root.foreground : Qt.darker(root.foreground, 1.4)
            font.family: root.fontFamily
            font.pixelSize: Style.font.bodySmall
            font.bold: formatRow.current
          }

          MouseArea {
            id: formatMouse
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.formatPicked(formatRow.modelData)
          }
        }
      }
    }
  }
}
