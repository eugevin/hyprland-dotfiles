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

      // Click opens the app (or its menu, if the app only has a menu)
      MouseArea {
        id: itemArea

        width: 20
        height: 20

        cursorShape: Qt.PointingHandCursor

        function openMenu() {
          // Under the tray pill, aligned with the icon
          const content = QsWindow.window.contentItem
          const x = content.mapFromItem(itemArea, 0, 0).x
          const y = content.mapFromItem(root, 0, root.height).y
          modelData.display(QsWindow.window, x, y)
        }

        onClicked: {
          if (modelData.onlyMenu) openMenu()
          else modelData.activate()
        }

        IconImage {
          anchors.fill: parent
          source: modelData.icon
        }
      }
    }
  }
}

