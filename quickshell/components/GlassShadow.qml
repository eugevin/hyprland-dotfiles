import QtQuick
import QtQuick.Effects

import "../theme.js" as Theme

// Soft shadow under a glass shape, so it reads on the bright parts of the wallpaper too.
// Put it before the shape and fill it: GlassShadow { anchors.fill: shape; radius: shape.radius }
RectangularShadow {
  offset.y: 6
  blur: 28
  spread: -2
  color: Theme.colors.shadow
}
