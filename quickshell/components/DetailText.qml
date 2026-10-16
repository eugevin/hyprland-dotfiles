import QtQuick

import "../theme.js" as Theme

// Text inside an Expandable panel; dim for labels
Text {
  property bool dim: false

  font.family: Theme.font.family
  font.pixelSize: Theme.font.sizeSmall
  font.weight: Theme.font.weight

  color: dim ? Theme.colors.textDim : Theme.colors.text
}
