import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import QtQuick

// Main keyboard layout as two letters ("en", "ru"). Re-queried on Hyprland's activelayout event.
Pill {
  id: root

  sizeText: "en"

  Process {
    id: query

    command: ["hyprctl", "devices", "-j"]
    running: true

    stdout: StdioCollector {
      onStreamFinished: {
        const keyboard = JSON.parse(this.text).keyboards.find(k => k.main)
        if (keyboard) root.value = keyboard.active_keymap.slice(0, 2).toLowerCase()
      }
    }
  }

  Connections {
    target: Hyprland

    function onRawEvent(event) {
      if (event.name === "activelayout") query.running = true
    }
  }
}
