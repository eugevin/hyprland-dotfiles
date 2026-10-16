import QtQuick

import qs.island
import qs.components
import qs.services

import "../../theme.js" as Theme

// Fallback activity. Nothing of its own in the top row: date, time and the notification count are
// the island's trailing part. Opens into a month calendar and power buttons | notification history
Activity {
  priority: 0

  full: Row {
    spacing: Theme.padding

    Column {
      id: calendarColumn
      spacing: 14

      SectionTitle {
        x: 6
        text: Time.date.toLocaleDateString(Qt.locale("en_GB"), "MMMM yyyy")
      }

      Calendar {
        date: Time.date
      }

      Row {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 16

        PowerButton {
          icon: "\uf011"
          command: ["systemctl", "poweroff"]
        }

        PowerButton {
          icon: "\uf01e"
          command: ["systemctl", "reboot"]
        }
      }
    }

    Rectangle {
      width: 1
      height: Math.max(calendarColumn.height, notifications.height)
      color: Theme.colors.line
    }

    // "All caught up" sits in the middle of the calendar column's height
    NotificationList {
      id: notifications
      fillHeight: calendarColumn.height
    }
  }
}
