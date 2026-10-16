import Quickshell
import Quickshell.Wayland
import QtQuick

import qs.services

import "../theme.js" as Theme

// Notification cards at the right edge under the bar, newest on top. `offset` pushes them down
// (below the opened sound panel)
PanelWindow {
  id: root

  // Room around the cards for their shadows
  property int shadowRoom: 30
  property real offset: 0

  anchors.top: true
  anchors.right: true

  // Below the bar's reserved row; the shadow room is taken off the screen margin
  margins.top: Theme.margin / 2 - shadowRoom / 2
  margins.right: Theme.margin - shadowRoom

  implicitWidth: 400 + shadowRoom * 2
  implicitHeight: Math.max(1, column.y + column.height + shadowRoom)

  // Same namespace as the bar, so the cards get the blur too
  WlrLayershell.namespace: "island"
  color: "transparent"
  visible: Notifs.popups.count > 0

  // Only the cards take input
  mask: Region {
    item: column
  }

  Column {
    id: column

    x: root.shadowRoom
    y: Math.round(root.shadowRoom / 2 + root.offset)
    width: 400
    spacing: Theme.margin / 2

    move: Transition {
      NumberAnimation { properties: "y"; duration: Theme.duration; easing.type: Easing.OutQuint }
    }

    Repeater {
      model: Notifs.popups

      Toast {
        width: column.width
        nid: model.nid
      }
    }
  }
}
