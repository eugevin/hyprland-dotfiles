import Quickshell
import QtQuick

import "../shared.js" as Shared

// First click arms the button, second click within 3s runs the command
Rectangle {
  id: root

  property string icon: ""
  property string label: ""
  property var command: []
  property bool armed: false

  property bool active: hover.hovered || armed

  width: Math.ceil(metrics.width) + 24
  height: Math.ceil(buttonText.height) + 12

  radius: Shared.radius
  // Armed = next click shuts down/reboots, so it gets the danger color, not the hover one
  color: armed ? Shared.colors.danger : active ? Shared.colors.bgActive : Shared.colors.track

  TextMetrics {
    id: metrics
    font: buttonText.font
    text: `${root.icon}  ${root.label}`
  }

  DetailText {
    id: buttonText
    anchors.centerIn: parent

    text: `${root.icon}  ${root.armed ? "Sure?" : root.label}`
    color: root.active ? Shared.colors.textWhite : Shared.colors.text
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
