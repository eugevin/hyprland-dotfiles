import Quickshell.Hyprland
import QtQuick

import qs.components

import "../theme.js" as Theme

// Hyprland workspaces (id > 0) as dots in a glass capsule, styled like the island.
// The focused one stretches into a gold pill; ones with windows are brighter than empty ones.
// Click = switch
Item {
  id: root

  property var workspaces: Hyprland.workspaces.values.filter(({ id }) => id > 0)
  property int focusedId: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : -1

  property int dot: 8

  width: dots.width + 24
  // Same height as the island's top row
  height: Math.ceil(metrics.height) + Theme.rowPadding

  FontMetrics {
    id: metrics
    font.family: Theme.font.family
    font.pixelSize: Theme.font.size
    font.weight: Theme.font.weight
  }

  GlassShadow {
    anchors.fill: glass
    radius: glass.radius
  }

  Rectangle {
    id: glass

    anchors.fill: parent
    radius: height / 2
    color: Theme.colors.bg
    border.width: 1
    border.color: Theme.colors.line
  }

  Row {
    id: dots
    anchors.centerIn: parent

    Repeater {
      model: root.workspaces

      // Click area around the dot, so it's easy to hit
      Item {
        id: workspace

        property bool focused: modelData.id === root.focusedId
        property bool occupied: modelData.toplevels.values.length > 0

        width: dotShape.width + 12
        height: root.height

        Rectangle {
          id: dotShape
          anchors.centerIn: parent

          width: workspace.focused ? root.dot * 3 : root.dot
          height: root.dot
          radius: height / 2

          color: workspace.focused ? Theme.colors.accent
            : hover.hovered ? Theme.colors.text
            : workspace.occupied ? Theme.colors.textDim
            : Theme.colors.surfaceHover

          Behavior on width {
            NumberAnimation { duration: Theme.duration; easing.type: Easing.OutQuint }
          }
          Behavior on color {
            ColorAnimation { duration: Theme.duration }
          }
        }

        HoverHandler {
          id: hover
          cursorShape: Qt.PointingHandCursor
        }

        TapHandler {
          onTapped: modelData.activate()
        }
      }
    }
  }
}
