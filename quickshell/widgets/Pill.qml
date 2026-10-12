import QtQuick

import "../shared.js" as Shared

// Base pill: background + "icon  value" text.
// sizeText reserves width for the widest expected value, so the pill doesn't jitter.
Item {
  id: root

  property string icon: ""
  property string value: ""
  property string sizeText: ""

  function format(value) {
    return root.icon ? `${root.icon}  ${value}` : value
  }

  width: Math.ceil(Math.max(label.width, metrics.width)) + 24
  height: Math.ceil(label.height) + 12

  Rectangle {
    anchors.fill: parent
    radius: Shared.radius
    color: Shared.colors.bg
  }

  TextMetrics {
    id: metrics
    font: label.font
    text: root.sizeText ? root.format(root.sizeText) : ""
  }

  Text {
    id: label
    anchors.centerIn: parent

    text: root.format(root.value)

    font.family: Shared.font.family
    font.pixelSize: Shared.font.size
    font.weight: Shared.font.weight

    color: Shared.colors.text
  }
}
