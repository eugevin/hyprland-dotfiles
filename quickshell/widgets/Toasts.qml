import Quickshell
import Quickshell.Wayland
import QtQuick

import "../shared.js" as Shared

// Notification toasts in the top-right corner under the bar, newest on top
PanelWindow {
  id: root

  anchors.top: true
  anchors.right: true

  margins.top: Shared.margin / 2
  margins.right: Shared.margin

  implicitWidth: 380
  implicitHeight: Math.max(1, column.height)

  color: "transparent"
  visible: Notifs.popups.count > 0

  // Only the toasts take input
  mask: Region {
    item: column
  }

  Column {
    id: column

    width: parent.width
    spacing: Shared.margin / 2

    move: Transition {
      NumberAnimation { properties: "y"; duration: 200; easing.type: Easing.OutCubic }
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
