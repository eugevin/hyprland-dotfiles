import Quickshell
import QtQuick

// Pill that opens on hover: the bar's single morph shape (MorphHost) grows out of it.
// Children go into the panel. Moving to another Expandable morphs the same shape over to it.
Pill {
  id: root

  default property alias content: details.data

  property int padding: 16

  property var host: Popups.host
  property bool active: host !== null && host.current === root
  property bool shown: active && host.expanded
  property bool hovered: pillHover.hovered

  // Panel size; same parity as the pill width so both center on the same pixel
  property int panelWidth: {
    const w = Math.max(Math.ceil(details.width) + padding * 2, width)
    return w + (w - width) % 2
  }
  property int panelHeight: Math.ceil(details.height) + padding

  // Window coordinates, updated by updateGeometry() when opening
  property int pillX: 0
  property int pillY: 0
  property int panelX: 0

  signal collapsed()

  // Clicks and wheel on the pill; MorphHost forwards them while its shape covers the pill
  signal tapped()
  signal scrolled(real delta)

  function updateGeometry() {
    const window = QsWindow.window
    const pos = window.contentItem.mapFromItem(root, 0, 0)
    pillX = Math.round(pos.x)
    pillY = Math.round(pos.y)

    // Centered under the pill, kept inside the bar window
    const centered = pillX + (width - panelWidth) / 2
    panelX = Math.max(0, Math.min(window.width - panelWidth, centered))
  }

  onHostChanged: if (host) host.register(root)
  Component.onCompleted: if (host) host.register(root)

  onHoveredChanged: if (host) hovered ? host.hover(root) : host.leave(root)
  onShownChanged: if (!shown) collapsed()

  HoverHandler {
    id: pillHover
  }

  TapHandler {
    onTapped: root.tapped()
  }

  // WheelHandler never gets wheel events here; MouseArea does. No buttons, so taps and hover pass through
  MouseArea {
    anchors.fill: parent
    acceptedButtons: Qt.NoButton
    onWheel: wheel => root.scrolled(wheel.angleDelta.y)
  }

  // Lives in the host's popup, in window coordinates; the morph shape reveals it
  Item {
    id: details

    parent: root.host ? root.host.contentLayer : root

    x: root.panelX + Math.round((root.panelWidth - width) / 2)
    y: root.pillY + root.height + root.padding / 2

    width: childrenRect.width
    height: childrenRect.height

    opacity: root.shown ? 1 : 0
    visible: opacity > 0
    Behavior on opacity {
      NumberAnimation { duration: root.host ? root.host.duration : 200 }
    }
  }
}
