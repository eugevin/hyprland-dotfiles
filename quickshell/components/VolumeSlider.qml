import QtQuick

import qs.services

import "../theme.js" as Theme

// Default output volume bar; interactive adds a handle and click/drag to set it
Item {
  id: root

  property bool interactive: false

  width: 260
  height: interactive ? 20 : 8

  Rectangle {
    anchors.verticalCenter: parent.verticalCenter
    width: parent.width
    height: 8
    radius: 4
    color: Theme.colors.surface

    Rectangle {
      width: parent.width * Audio.volume
      height: parent.height
      radius: parent.radius
      color: Audio.muted ? Theme.colors.textDim : Theme.colors.accent

      Behavior on width {
        NumberAnimation { duration: 100 }
      }
    }
  }

  Rectangle {
    visible: root.interactive
    anchors.verticalCenter: parent.verticalCenter
    x: (parent.width - width) * Audio.volume
    width: 16
    height: 16
    radius: 8
    color: Theme.colors.textBright
  }

  MouseArea {
    anchors.fill: parent
    enabled: root.interactive
    cursorShape: Qt.PointingHandCursor

    function apply(x) {
      Audio.setVolume(x / width * 100)
    }

    onPressed: mouse => apply(mouse.x)
    onPositionChanged: mouse => apply(mouse.x)
  }
}
