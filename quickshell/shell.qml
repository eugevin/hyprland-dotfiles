import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Wayland
import QtQuick

import qs.bar as Bar
import qs.components as Components
import qs.island
import qs.island.activities as Activities
import qs.services

import "theme.js" as Theme

ShellRoot {
  PanelWindow {
    id: bar

    anchors.top: true
    anchors.left: true
    anchors.right: true

    margins.left: Theme.margin
    margins.right: Theme.margin

    // Tall enough for the opened island; only the bar row is reserved
    implicitHeight: screen ? screen.height / 2 : 600
    exclusionMode: ExclusionMode.Normal
    exclusiveZone: row.y + row.height

    WlrLayershell.namespace: "island"
    // Keyboard only while the launcher's search field needs it
    WlrLayershell.keyboardFocus: Launcher.open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    color: "transparent"

    // Input only where something is drawn; the rest passes through to the windows below
    mask: Region {
      item: island.shape

      Region {
        item: workspaces
      }
      Region {
        item: status.shape
      }
    }

    // Three glass capsules in one row: workspaces | island | status
    Item {
      id: row

      y: Theme.margin / 2
      width: parent.width
      height: Theme.margin * 2

      // Workspaces
      Bar.Workspaces {
        id: workspaces

        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
      }
    }

    // Island: date, time and the notification count; the launcher shows up here.
    // Hover opens the calendar and the notification history
    Island {
      id: island

      y: row.y + Math.round((row.height - compactHeight) / 2)
      width: parent.width
      height: parent.height - y

      activities: [
        Activities.Clock {
          id: clockActivity
        },
        Activities.Apps {}
      ]

      // Date | time | notification count (only when there are any)
      trailing: Row {
        spacing: island.dividerGap

        Components.BarText {
          text: Time.date.toLocaleDateString(Qt.locale("en_GB"), "ddd d MMM")
        }

        Components.Divider {
          anchors.verticalCenter: parent.verticalCenter
        }

        Components.BarText {
          text: Qt.formatDateTime(Time.date, "HH:mm")
        }

        Components.Divider {
          visible: Notifs.count > 0
          anchors.verticalCenter: parent.verticalCenter
        }

        Row {
          visible: Notifs.count > 0
          spacing: 8

          Components.BarText {
            text: "\uf0f3"
            color: Theme.colors.accent
          }

          Components.BarText {
            text: Notifs.count
          }
        }
      }
      trailingActivity: clockActivity
    }

    // Status: volume and keyboard layout. Hover opens the sound settings, wheel = volume
    Island {
      id: status

      align: "right"
      y: row.y + Math.round((row.height - compactHeight) / 2)
      width: parent.width
      height: parent.height - y

      activities: [
        Activities.Status {}
      ]

      onScrolled: delta => Audio.scroll(delta)
    }
  }

  // Notification cards, right edge under the bar; they move down out of the way while the sound
  // panel is open (follows its animated height, so they slide along with it)
  Bar.Toasts {
    property real panel: status.shape.height - status.compactHeight
    offset: panel > 0 ? panel + Theme.margin / 2 : 0
  }

  // Clicking outside the bar closes the launcher. Activated a moment after opening: right away,
  // before the bar has keyboard focus, the grab is cleared at once
  HyprlandFocusGrab {
    id: grab

    windows: [bar]
    active: false
    onCleared: Launcher.close()
  }

  Timer {
    interval: 100
    running: Launcher.open
    onTriggered: grab.active = true
  }

  Connections {
    target: Launcher

    function onOpenChanged() {
      if (!Launcher.open) grab.active = false
    }
  }

  // qs ipc call island toggle
  IpcHandler {
    target: "island"

    function toggle(): void { island.pinned = !island.pinned }
    function open(): void { island.pinned = true }
    function close(): void { island.pinned = false }
  }

  // qs ipc call status toggle
  IpcHandler {
    target: "status"

    function toggle(): void { status.pinned = !status.pinned }
    function open(): void { status.pinned = true }
    function close(): void { status.pinned = false }
  }

  // qs ipc call launcher toggle
  IpcHandler {
    target: "launcher"

    function toggle(): void { Launcher.toggle() }
  }
}
