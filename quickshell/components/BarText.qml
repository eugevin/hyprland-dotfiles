import QtQuick

import "../theme.js" as Theme

// Text in the bar row (full size); see DetailText for panel content
Text {
  font.family: Theme.font.family
  font.pixelSize: Theme.font.size
  font.weight: Theme.font.weight

  color: Theme.colors.text
}
