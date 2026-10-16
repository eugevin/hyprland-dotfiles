import QtQuick

import "../theme.js" as Theme

// Small text button (Clear, notification actions)
Rectangle {
  id: root

  property string text: ""

  signal clicked()

  width: label.width + 20
  height: label.height + 8

  radius: height / 2
  color: hover.hovered ? Theme.colors.accent : Theme.colors.surface

  DetailText {
    id: label
    anchors.centerIn: parent
    text: root.text
    color: hover.hovered ? Theme.colors.onAccent : Theme.colors.text
  }

  HoverHandler {
    id: hover
    cursorShape: Qt.PointingHandCursor
  }

  TapHandler {
    // Exclusive grab, so the click doesn't also hit the notification underneath
    gesturePolicy: TapHandler.ReleaseWithinBounds
    onTapped: root.clicked()
  }
}
