import Quickshell
import Quickshell.Io
import QtQuick

import "../shared.js" as Shared

Item {
  id: root

  width: text.width + 24
  height: text.height + 12

  property string icon: ""
  property var command: []
  property int interval: 1000

  Rectangle {
    anchors.fill: parent
    radius: Shared.radius
    color: Shared.colors.bg
  }

  Text {
    id: text
    anchors.centerIn: parent

    font.family: Shared.font.family
    font.pixelSize: Shared.font.size
    font.weight: Shared.font.weight

    color: Shared.colors.text
  }

  Process {
    id: process

    command: root.command
    running: true

    stdout: StdioCollector {
      onStreamFinished: {
        const clearText = this.text.trim();
        text.text = icon ? `${icon}  ${clearText}` : clearText
      }
    }
  }

  Timer {
    interval: root.interval
    running: true
    repeat: true
    onTriggered: process.running = true
  }
}

