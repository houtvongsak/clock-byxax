import QtQuick
import qs.Commons

// Keyboard and mouse cheat sheet for the calendar popup, laid over the grid
// while "?" is held open. Kept in its own file so Panel.qml, which tracks
// upstream Omarchy, only carries the hook that shows it.
Rectangle {
  id: root

  property color foreground: Color.foreground
  property string fontFamily: Style.font.family

  signal dismissed()

  readonly property var sections: [
    { title: "CALENDAR", rows: [
      ["← →  h l  [ ]  Scroll", "Previous / next month"],
      ["↑ ↓  k j  { }", "Previous / next year"],
      ["t  Enter  Space", "Back to today"],
      ["w", "Toggle week start (Mon / Sun)"],
      ["Hover a red day", "Holiday name"]
    ]},
    { title: "PANEL", rows: [
      ["Tab  Shift+Tab", "Next / previous bar panel"],
      ["Esc", "Close"],
      ["s", "Settings"],
      ["?", "Toggle this help"]
    ]},
    { title: "MOUSE", rows: [
      ["Click W", "Toggle week start"],
      ["Click the gear", "Settings"],
      ["Click the date", "Back to today"],
      ["Double-click year bar", "Set life bar (born / live to)"],
      ["Double-click life bar", "Remove life bar"]
    ]},
    { title: "BAR CLOCK", rows: [
      ["Left click", "Open calendar"],
      ["Right click", "Cycle label format"],
      ["Middle click", "Pick timezone"]
    ]}
  ]

  color: Color.popups.background

  // Swallows clicks so nothing underneath reacts; a click anywhere closes.
  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.AllButtons
    onClicked: root.dismissed()
    onWheel: function(wheel) { wheel.accepted = true }
  }

  Column {
    anchors.centerIn: parent
    spacing: Style.space(10)

    Text {
      anchors.horizontalCenter: parent.horizontalCenter
      text: "SHORTCUTS"
      color: root.foreground
      font.family: root.fontFamily
      font.pixelSize: Style.font.body
      font.letterSpacing: 2
      font.bold: true
    }

    Repeater {
      model: root.sections

      Column {
        required property var modelData
        spacing: Style.space(2)

        Text {
          text: modelData.title
          color: Qt.darker(root.foreground, 1.9)
          font.family: root.fontFamily
          font.pixelSize: Style.font.caption
          font.letterSpacing: 1
          font.bold: true
        }

        Repeater {
          model: modelData.rows

          Row {
            required property var modelData
            spacing: Style.space(16)

            Text {
              width: Style.space(170)
              text: modelData[0]
              color: root.foreground
              font.family: root.fontFamily
              font.pixelSize: Style.font.caption
              font.bold: true
            }

            Text {
              text: modelData[1]
              color: Qt.darker(root.foreground, 1.4)
              font.family: root.fontFamily
              font.pixelSize: Style.font.caption
            }
          }
        }
      }
    }
  }
}
