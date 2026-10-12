import Quickshell
import Quickshell.Hyprland
import QtQuick

import "../shared.js" as Shared

Rectangle {
  id: root

  property int duration: 200

  property var workspaces: Hyprland.workspaces.values.filter(({ id }) => id > 0)
  property int focusedId: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : -1
  property int focusedIndex: workspaces.findIndex(workspace => workspace.id === focusedId)

  // repeater.count makes this re-evaluate once the delegates exist
  property var focusedItem: repeater.count && focusedIndex >= 0 ? repeater.itemAt(focusedIndex) : null

  width: content.width
  height: content.height

  color: Shared.colors.bg
  radius: Shared.radius

  // Active workspace highlight; slides over to the newly focused one
  Rectangle {
    visible: root.focusedItem !== null

    x: root.focusedItem ? content.x + root.focusedItem.x : 0
    y: content.y
    width: root.focusedItem ? root.focusedItem.width : 0
    height: content.height

    radius: Shared.radius
    color: Shared.colors.bgActive

    Behavior on x {
      NumberAnimation { duration: root.duration; easing.type: Easing.OutCubic }
    }
    Behavior on width {
      NumberAnimation { duration: root.duration; easing.type: Easing.OutCubic }
    }
  }

  Row {
    id: content
    anchors.centerIn: parent

    Repeater {
      id: repeater
      model: root.workspaces

      Item {
        width: label.width + 24
        height: label.height + 12

        Text {
          id: label
          anchors.centerIn: parent

          text: modelData.id

          font.family: Shared.font.family
          font.pixelSize: Shared.font.size
          font.weight: Shared.font.weight

          color: modelData.id === root.focusedId
            ? Shared.colors.textWhite
            : Shared.colors.text

          Behavior on color {
            ColorAnimation { duration: root.duration }
          }
        }

        HoverHandler {
          cursorShape: Qt.PointingHandCursor
        }

        TapHandler {
          onTapped: modelData.activate()
        }
      }
    }
  }
}
