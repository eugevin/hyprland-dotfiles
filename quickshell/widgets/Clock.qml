import Quickshell
import QtQuick

// Time; opens into the full date, a month calendar and power buttons
Expandable {
  id: root

  value: Qt.formatDateTime(clock.date, "MM.dd | HH:mm")

  onCollapsed: {
    shutdownButton.armed = false
    rebootButton.armed = false
  }

  SystemClock {
    id: clock
    precision: SystemClock.Minutes
  }

  Column {
    spacing: 12

    DetailText {
      anchors.horizontalCenter: parent.horizontalCenter
      text: clock.date.toLocaleDateString(Qt.locale("en_GB"), "dddd, d MMMM yyyy")
    }

    Calendar {
      anchors.horizontalCenter: parent.horizontalCenter
      date: clock.date
    }

    Row {
      anchors.horizontalCenter: parent.horizontalCenter
      spacing: 8

      PowerButton {
        id: shutdownButton
        icon: "\uf011"
        label: "Shutdown"
        command: ["systemctl", "poweroff"]
      }

      PowerButton {
        id: rebootButton
        icon: "\uf01e"
        label: "Reboot"
        command: ["systemctl", "reboot"]
      }
    }
  }
}
