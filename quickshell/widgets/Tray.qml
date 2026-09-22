import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray

import "../shared.js" as Shared

Item {
  id: root

  width: iconRow.width + 16
  height: iconRow.height + 12

  Rectangle {
    anchors.fill: parent
    radius: Shared.radius

    color: Shared.colors.bg
  }

  Row {
    id: iconRow

    anchors.centerIn: parent
    spacing: 8

    Repeater {
      model: SystemTray.items

      MouseArea {
        id: itemArea

        width: 20
        height: 20
        
        IconImage {
          anchors.fill: parent
          source: modelData.icon
        }
      }
    }
  }
}

