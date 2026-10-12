import Quickshell
import Quickshell.Wayland
import QtQuick

import qs.widgets as Widgets

import "shared.js" as Shared

ShellRoot {
  PanelWindow {
    anchors.top: true
    anchors.left: true
    anchors.right: true

    margins.top: Shared.margin / 2
    margins.left: Shared.margin
    margins.right: Shared.margin

    height: Shared.margin * 2
    color: "transparent"

    Row {
      anchors.verticalCenter: parent.verticalCenter
      anchors.left: parent.left

      // Workspaces
      Widgets.Workspaces {}
    }

    // Single morph shape shared by all Expandables
    Widgets.MorphHost {}

    // Clock (hover for calendar and power menu)
    Widgets.Clock {
      anchors.centerIn: parent
    }

    Row {
      anchors.verticalCenter: parent.verticalCenter
      anchors.right: parent.right

      spacing: Shared.margin / 2

      // Lang
      Widgets.Simple {
        command: ["sh", "-c", "hyprctl devices | awk '/active keymap:/ {layout=$3} /main: yes/ {print layout; exit}' | cut -c1-2 | tr 'A-Z' 'a-z'"]
        interval: 200
      }

      // Audio
      Widgets.Simple {
        icon: ""
        command: ["sh", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{ if ($3 == \"[MUTED]\") print \"Muted\"; else print int($2 * 100)\"%\" }'"]
        interval: 1000
      }

      // CPU
      Widgets.Cpu {
        icon: "\uf4bc"
      }

      // Memory
      Widgets.Memory {
        icon: "\uefc5"
      }

      // Tray
      Widgets.Tray {}
    }
  }
}
