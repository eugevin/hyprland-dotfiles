import QtQuick

import "../theme.js" as Theme

// Heading of a column in an opened panel ("October 2026", "Notifications"); fixed height, so
// headings of neighbouring columns line up
DetailText {
  height: 28
  verticalAlignment: Text.AlignVCenter

  font.weight: Theme.font.weightBold
  color: Theme.colors.textBright
}
