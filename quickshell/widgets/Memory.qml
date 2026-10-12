import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

import "../shared.js" as Shared

// Used RAM from /proc/meminfo; opens into a usage bar, cache, available and swap
Expandable {
  id: root

  property int interval: 2000

  // kB values from /proc/meminfo
  property var info: ({})

  property real total: info.MemTotal || 0
  property real used: total - (info.MemAvailable || 0)
  property real swapTotal: info.SwapTotal || 0

  function gigs(kb) {
    return `${(kb / 1024 / 1024).toFixed(1)}G`
  }

  sizeText: "00.0G"
  value: total ? gigs(used) : "-"

  FileView {
    id: meminfo
    path: "/proc/meminfo"

    onLoaded: {
      const info = {}
      for (const line of text().split("\n")) {
        const [key, kb] = line.split(/:\s+/)
        if (kb) info[key] = parseInt(kb)
      }
      root.info = info
    }
  }

  Timer {
    interval: root.interval
    running: true
    repeat: true
    onTriggered: meminfo.reload()
  }

  Column {
    spacing: 12

    Rectangle {
      width: grid.width
      height: 10
      radius: 3
      color: Shared.colors.track

      Rectangle {
        width: root.total ? parent.width * root.used / root.total : 0
        height: parent.height
        radius: 3
        color: Shared.colors.bgActive

        Behavior on width {
          NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
        }
      }
    }

    GridLayout {
      id: grid

      columns: 2
      columnSpacing: 24
      rowSpacing: 4

      DetailText { text: "Used"; dim: true }
      DetailText { text: `${root.gigs(root.used)} / ${root.gigs(root.total)}`; Layout.alignment: Qt.AlignRight }

      DetailText { text: "Cache"; dim: true }
      DetailText { text: root.gigs((root.info.Cached || 0) + (root.info.Buffers || 0)); Layout.alignment: Qt.AlignRight }

      DetailText { text: "Available"; dim: true }
      DetailText { text: root.gigs(root.info.MemAvailable || 0); Layout.alignment: Qt.AlignRight }

      DetailText { text: "Swap"; dim: true }
      DetailText { text: `${root.gigs(root.swapTotal - (root.info.SwapFree || 0))} / ${root.gigs(root.swapTotal)}`; Layout.alignment: Qt.AlignRight }
    }
  }
}
