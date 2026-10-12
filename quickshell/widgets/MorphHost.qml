import Quickshell
import QtQuick

import "../shared.js" as Shared

// One popup over the whole bar with a single shape that morphs out of the hovered Expandable
// and slides over to the next one. Put it inside the bar's PanelWindow.
Item {
  id: host

  property int duration: 200

  // Hover this long before the shape opens, so passing the mouse over the bar doesn't pop it
  property int openDelay: 150
  property var pending: null

  property var items: []
  property var current: null
  property bool expanded: false
  property bool animate: true

  property bool hovered: morphHover.hovered

  // The bar window; null for a moment while it's being created
  property var window: QsWindow.window

  property alias contentLayer: contentLayer

  function register(item) {
    if (!items.includes(item)) items = items.concat([item])
  }

  // Opening from closed waits for openDelay; moving between pills while open is instant
  function hover(item) {
    if (popup.visible) {
      open(item)
    } else {
      pending = item
      openTimer.restart()
    }
  }

  function open(item) {
    openTimer.stop()
    pending = null
    closeTimer.stop()
    hideTimer.stop()
    item.updateGeometry()

    if (!popup.visible) {
      // Start exactly on the pill, without animating from wherever the shape was last
      animate = false
      current = item
      expanded = false
      animate = true
      popup.visible = true
    }

    current = item
    expanded = true
  }

  function leave(item) {
    if (item === pending) {
      openTimer.stop()
      pending = null
    }
    if (item === current) closeTimer.restart()
  }

  function close() {
    expanded = false
    hideTimer.restart()
  }

  Component.onCompleted: Popups.host = host

  onHoveredChanged: hovered ? closeTimer.stop() : closeTimer.restart()

  Timer {
    id: openTimer
    interval: host.openDelay
    onTriggered: if (host.pending && host.pending.hovered) host.open(host.pending)
  }

  // Small delay so a brief slip off the shape doesn't close it
  Timer {
    id: closeTimer
    interval: 300
    onTriggered: {
      if (!host.hovered && !(host.current && host.current.hovered)) host.close()
    }
  }

  // Unmap the popup only after the collapse animation is done
  Timer {
    id: hideTimer
    interval: host.duration
    onTriggered: {
      popup.visible = false
      host.current = null
    }
  }

  PopupWindow {
    id: popup

    // Covers the bar window exactly, so popup coordinates = bar window coordinates
    anchor.window: host.window
    anchor.rect.x: 0
    anchor.rect.y: 0
    anchor.edges: Edges.Top | Edges.Left
    anchor.gravity: Edges.Bottom | Edges.Right

    implicitWidth: host.window ? host.window.width : 1
    implicitHeight: host.window && host.window.screen ? host.window.screen.height / 2 : 1

    color: "transparent"
    visible: false

    // Input only over the current pill and the part of the shape below the bar row. The rest of
    // the top row covers the neighbours visually but lets the pointer reach them.
    mask: Region {
      item: pillArea

      Region {
        item: belowArea
      }
    }

    Item {
      id: pillArea

      x: host.current ? host.current.pillX : 0
      y: host.current ? host.current.pillY : 0
      width: host.current ? host.current.width : 0
      height: host.current ? host.current.height : 0

      // The shape covers the real pill, so pass its clicks and wheel on
      TapHandler {
        onTapped: if (host.current) host.current.tapped()
      }

      // WheelHandler never gets wheel events here; MouseArea does
      MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.NoButton
        onWheel: wheel => {
          if (host.current) host.current.scrolled(wheel.angleDelta.y)
        }
      }
    }

    Item {
      id: belowArea

      x: morph.x
      y: pillArea.y + pillArea.height
      width: morph.width
      height: Math.max(0, morph.y + morph.height - y)
    }

    Rectangle {
      id: morph

      property var item: host.current

      // Animated as reals, applied rounded: fractional positions make text inside jitter by a pixel
      property real animX: !item ? 0 : host.expanded ? item.panelX : item.pillX
      property real animY: item ? item.pillY : 0
      property real animWidth: !item ? 0 : host.expanded ? item.panelWidth : item.width
      property real animHeight: !item ? 0 : host.expanded ? item.height + item.panelHeight : item.height

      x: Math.round(animX)
      y: Math.round(animY)
      width: Math.round(animWidth)
      height: Math.round(animHeight)

      radius: Shared.radius
      color: Shared.colors.bg
      clip: true

      Behavior on animX {
        enabled: host.animate
        NumberAnimation { duration: host.duration; easing.type: Easing.OutCubic }
      }
      Behavior on animY {
        enabled: host.animate
        NumberAnimation { duration: host.duration; easing.type: Easing.OutCubic }
      }
      Behavior on animWidth {
        enabled: host.animate
        NumberAnimation { duration: host.duration; easing.type: Easing.OutCubic }
      }
      Behavior on animHeight {
        enabled: host.animate
        NumberAnimation { duration: host.duration; easing.type: Easing.OutCubic }
      }

      HoverHandler {
        id: morphHover
      }

      // Window coordinates inside the clipped shape; Expandables put their panel content here
      Item {
        id: contentLayer

        x: -morph.x
        y: -morph.y
        width: popup.width
        height: popup.height
      }
    }

    // Pill text copies on top of the shape. The current one is shown at once; the one the shape
    // just left fades out instead of vanishing while the shape still covers its pill.
    Repeater {
      model: host.items

      Item {
        id: copy

        property bool active: modelData === host.current

        x: modelData.pillX
        y: modelData.pillY
        width: modelData.width
        height: modelData.height

        opacity: 0

        onActiveChanged: {
          fade.stop()
          if (active) opacity = 1
          else fade.start()
        }

        NumberAnimation {
          id: fade
          target: copy
          property: "opacity"
          to: 0
          duration: host.duration
        }

        // Centered the same way as in Pill (anchors round differently than Math.round would)
        Text {
          anchors.centerIn: parent

          text: modelData.format(modelData.value)

          font.family: Shared.font.family
          font.pixelSize: Shared.font.size
          font.weight: Shared.font.weight

          color: Shared.colors.text
        }
      }
    }
  }
}
