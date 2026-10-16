import QtQuick

import "../theme.js" as Theme

// Month grid for the given date, weeks start on Monday, today highlighted
Grid {
  id: root

  property date date: new Date()

  property int year: date.getFullYear()
  property int month: date.getMonth()
  property int today: date.getDate()

  // Empty cells before the 1st (Monday = 0)
  property int offset: (new Date(year, month, 1).getDay() + 6) % 7
  property int days: new Date(year, month + 1, 0).getDate()

  columns: 7
  columnSpacing: 2
  rowSpacing: 2

  Repeater {
    model: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]

    Item {
      width: 36
      height: 30

      DetailText {
        anchors.centerIn: parent
        text: modelData
        dim: true
      }
    }
  }

  Repeater {
    model: root.offset + root.days

    Rectangle {
      property int day: index - root.offset + 1
      property bool isToday: day === root.today

      width: 36
      height: 30

      radius: height / 2
      color: isToday ? Theme.colors.accent : "transparent"

      DetailText {
        anchors.centerIn: parent
        text: day > 0 ? day : ""
        color: isToday ? Theme.colors.onAccent : Theme.colors.text
      }
    }
  }
}
