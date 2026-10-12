//@ pragma UseQApplication

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

    implicitHeight: Shared.margin * 2
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
      id: clock
      anchors.centerIn: parent
    }

    // Notification history, right next to the clock
    Widgets.NotificationCenter {
      anchors.verticalCenter: parent.verticalCenter
      anchors.left: clock.right
      anchors.leftMargin: Shared.margin / 2
    }

    Row {
      anchors.verticalCenter: parent.verticalCenter
      anchors.right: parent.right

      spacing: Shared.margin / 2

      // Lang
      Widgets.Lang {}

      // Audio
      Widgets.Audio {
        icon: "\uf485"
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

  // Notification toasts, top-right under the bar
  Widgets.Toasts {}
}
