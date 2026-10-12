import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

import "../shared.js" as Shared

// CPU usage from /proc/stat; opens into per-core bars, temperature and load average
Expandable {
  id: root

  property int interval: 2000

  // Previous {idle, total} per line of /proc/stat: [0] = all cores, then cpu0, cpu1, ...
  property var last: []
  property var cores: []

  property string temperature: "-"
  property string load: "-"

  sizeText: "100%"

  function usage(fields, previous) {
    // user nice system idle iowait irq softirq steal ...
    const idle = fields[3] + fields[4]
    const total = fields.reduce((a, b) => a + b, 0)
    const busy = previous && total > previous.total
      ? 1 - (idle - previous.idle) / (total - previous.total)
      : 0
    return { idle, total, busy }
  }

  FileView {
    id: stat
    path: "/proc/stat"

    onLoaded: {
      const lines = text().split("\n").filter(line => line.startsWith("cpu"))
      const samples = lines.map((line, i) => {
        const fields = line.trim().split(/\s+/).slice(1).map(Number)
        return root.usage(fields, root.last[i])
      })

      if (root.last.length) {
        root.value = `${Math.round(samples[0].busy * 100)}%`
        root.cores = samples.slice(1).map(sample => sample.busy)
      }

      root.last = samples
    }
  }

  // AMD (k10temp) or Intel (coretemp) package temperature; hwmon numbering changes between boots
  Process {
    command: ["sh", "-c", "for h in /sys/class/hwmon/hwmon*; do case $(cat $h/name) in k10temp|coretemp) echo $h/temp1_input; exit;; esac; done"]
    running: true

    stdout: StdioCollector {
      onStreamFinished: temp.path = this.text.trim()
    }
  }

  FileView {
    id: temp
    onLoaded: root.temperature = `${Math.round(Number(text()) / 1000)}°C`
  }

  FileView {
    id: loadavg
    path: "/proc/loadavg"
    onLoaded: root.load = text().split(" ").slice(0, 3).join("  ")
  }

  Timer {
    interval: root.interval
    running: true
    repeat: true
    onTriggered: {
      stat.reload()
      if (temp.path) temp.reload()
      loadavg.reload()
    }
  }

  Column {
    spacing: 12

    Row {
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 4

      Repeater {
        model: root.cores

        Rectangle {
          width: 10
          height: 48
          radius: 3
          color: Shared.colors.track

          Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: Math.max(2, parent.height * modelData)
            radius: 3
            color: Shared.colors.bgActive

            Behavior on height {
              NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
            }
          }
        }
      }
    }

    GridLayout {
      anchors.horizontalCenter: parent.horizontalCenter
      columns: 2
      columnSpacing: 24
      rowSpacing: 4

      DetailText { text: "Temp"; dim: true }
      DetailText { text: root.temperature; Layout.alignment: Qt.AlignRight }

      DetailText { text: "Load"; dim: true }
      DetailText { text: root.load; Layout.alignment: Qt.AlignRight }
    }
  }
}
