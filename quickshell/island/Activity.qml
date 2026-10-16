import Quickshell
import QtQuick

// One thing the island can show. Of the active ones, the highest priority wins.
// compact sits in the island's top row; full appears under it when the island opens.
Scope {
  property int priority: 0
  property bool active: true

  property Component compact
  property Component full

  // Hide the island's trailing part (date, time) while this is shown, e.g. the launcher
  property bool hideTrailing: false

  // Keep the island open while this is shown, and take over from whatever it shows (the launcher)
  property bool keepOpen: false

  // Set by the island: this activity's compact view is shown / its full view is open
  property bool shown: false
  property bool opened: false

  // Click on the island's compact view while this activity is shown
  signal tapped()
}
