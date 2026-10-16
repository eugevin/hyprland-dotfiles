import Quickshell
import QtQuick

import "../theme.js" as Theme

// Round icon button. First click arms it (terracotta, icon turns into a check), a second click
// within 3 s runs the command
Rectangle {
  id: root

  property string icon: ""
  property var command: []
  property bool armed: false

  property bool active: hover.hovered || armed

  width: 48
  height: 48

  radius: height / 2
  // Armed = next click shuts down/reboots, so it gets the danger color, not the hover one
  color: armed ? Theme.colors.danger : active ? Theme.colors.accent : Theme.colors.surface

  Behavior on color {
    ColorAnimation { duration: Theme.duration / 2 }
  }

  Text {
    anchors.centerIn: parent

    text: root.armed ? "\uf00c" : root.icon

    font.family: Theme.font.family
    font.pixelSize: 20
    color: root.active ? Theme.colors.onAccent : Theme.colors.text
  }

  HoverHandler {
    id: hover
    cursorShape: Qt.PointingHandCursor
  }

  TapHandler {
    onTapped: {
      if (root.armed) {
        Quickshell.execDetached(root.command)
      } else {
        root.armed = true
        disarmTimer.restart()
      }
    }
  }

  Timer {
    id: disarmTimer
    interval: 3000
    onTriggered: root.armed = false
  }
}
