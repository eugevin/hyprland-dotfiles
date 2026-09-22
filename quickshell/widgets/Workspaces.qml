import Quickshell
import Quickshell.Hyprland
import QtQuick

import "../shared.js" as Shared

Rectangle {
  width: content.width
  height: content.height

  color: Shared.colors.bg
  radius: Shared.radius

  Row {
    id: content
    anchors.centerIn: parent

    Repeater {
      model: Hyprland.workspaces.values.filter(({ id }) => id > 0)

      Item {
        id: item
        width: label.width + 24
        height: label.height + 12

        property var focusedId: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : -1

        Rectangle {
          anchors.fill: item
          radius: Shared.radius

          color: focusedId === modelData.id
            ? Shared.colors.bgActive
            : Shared.colors.bg
        }

        Text {
          id: label
          anchors.centerIn: parent

          text: modelData.id

          font.family: Shared.font.family
          font.pixelSize: Shared.font.size
          font.weight: Shared.font.weight

          color: focusedId === modelData + 1
            ? Shared.colors.textWhite
            : Shared.colors.text
        }
      }
    }
  }
}
