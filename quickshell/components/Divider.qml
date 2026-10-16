import QtQuick

import "../theme.js" as Theme

// Thin vertical line between parts of a capsule's top row (date | time, volume | layout)
Rectangle {
  width: 2
  height: Math.round(Theme.font.size * 0.8)
  radius: 1
  color: Theme.colors.line
}
