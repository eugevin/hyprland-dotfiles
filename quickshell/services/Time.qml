pragma Singleton

import Quickshell
import QtQuick

// Current date and time, to the minute
Singleton {
  property alias date: clock.date

  SystemClock {
    id: clock
    precision: SystemClock.Minutes
  }
}
