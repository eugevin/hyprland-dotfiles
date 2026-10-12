import QtQuick

import "../shared.js" as Shared

// Text inside an Expandable panel; dim for labels
Text {
  property bool dim: false

  font.family: Shared.font.family
  font.pixelSize: Shared.font.sizeSmall
  font.weight: Shared.font.weight

  color: dim ? Shared.colors.textDim : Shared.colors.text
}
