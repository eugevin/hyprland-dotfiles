import QtQuick

import qs.components

import "../theme.js" as Theme

// A glass capsule that morphs. Its top row holds the current activity's compact view and
// `trailing` (e.g. date and time), split by a divider. On hover (or `pinned`) it grows down and
// sideways into a full view: the current activity's, or trailingActivity's while the pointer is
// over the trailing part. Of the active activities, the highest priority is shown.
// Contents live in this item's coordinates, so they stay put while the shape animates around them.
// Click on the compact view goes to the current activity, the wheel comes out as scrolled(delta).
// align: "center" (grows both ways) or "right" (sits at the right edge, grows to the left)
Item {
  id: root

  property list<QtObject> activities
  property string align: "center"
  property alias trailing: trailingSlot.data
  property var trailingActivity: null

  property var best: activities.reduce(
    (best, activity) => activity.active && (!best || activity.priority > best.priority) ? activity : best,
    null)

  // While open, the island sticks to what it shows until that ends (or the launcher takes over)
  property var current: null

  // The full view on show: trailingActivity while opened from the trailing part, else current
  property var override: null
  property var panel: open && override && !(current && current.keepOpen) ? override : current

  property bool pinned: false
  property bool hoverOpen: false
  property bool open: pinned || hoverOpen || (current !== null && current.keepOpen)

  property alias shape: shape

  // repeater.count makes these re-evaluate once the delegates exist
  property var view: views.count && current ? views.itemAt(activities.indexOf(current)) : null
  property var panelView: views.count && panel ? views.itemAt(activities.indexOf(panel)) : null

  // Closed it's a capsule, so the ends get more room than the gap around the divider
  property int sidePadding: 20
  property int dividerGap: 14

  // Nothing to show in the middle (idle clock): no divider before the trailing part
  property bool compactEmpty: !view || view.compactWidth === 0
  property bool showTrailing: trailingSlot.width > 0 && !(current && current.hideTrailing)
  property real trailingWidth: !showTrailing ? 0
    : compactEmpty ? trailingSlot.width
    : trailingSlot.width + dividerGap * 2 + divider.width

  property real compactWidth: view ? sidePadding * 2 + view.compactWidth + trailingWidth : 0
  property real compactHeight: Math.max(trailingSlot.height, view ? view.compactHeight : 0) + Theme.rowPadding

  // Closed width, animated like the shape; the top row is laid out against it
  property real shownCompactWidth: compactWidth
  Behavior on shownCompactWidth {
    NumberAnimation { duration: Theme.duration; easing.type: Easing.OutQuint }
  }

  property int rowX: placeX(shownCompactWidth)
  property int compactX: rowX + sidePadding
  property int trailingX: Math.round(rowX + shownCompactWidth - sidePadding - trailingSlot.width)

  signal scrolled(real delta)

  // Left edge of something `w` wide, by `align`
  function placeX(w) {
    return align === "right" ? Math.round(width - w) : Math.round((width - w) / 2)
  }

  function update() {
    if (!open || (best && best.keepOpen)) override = null
    if (!open || !current || !current.active || (best && best.keepOpen && best !== current)) current = best
  }

  // Pointer in shape coordinates: over the trailing part opens trailingActivity, over the
  // compact view goes back to the current activity
  function pointAt(x, y) {
    if (!open || (current && current.keepOpen) || y >= compactHeight) return

    const windowX = x + shape.x
    if (showTrailing && windowX >= trailingX - dividerGap) override = trailingActivity
    else override = null
  }

  onBestChanged: update()
  onOpenChanged: update()
  Component.onCompleted: update()

  GlassShadow {
    anchors.fill: shape
    radius: shape.radius
  }

  Rectangle {
    id: shape

    property real animWidth: !root.panelView ? 0
      : root.open ? Math.max(root.compactWidth, root.panelView.fullWidth + Theme.padding * 2)
      : root.compactWidth
    property real animHeight: !root.panelView ? 0
      : root.open ? root.compactHeight + root.panelView.fullHeight + Theme.padding * 2
      : root.compactHeight

    // Animated as reals, applied rounded so the contents don't jitter
    x: root.placeX(animWidth)
    width: Math.round(animWidth)
    height: Math.round(animHeight)

    // A capsule while closed, big soft corners when open
    radius: root.open ? Theme.radiusLarge : root.compactHeight / 2
    color: Theme.colors.bg
    border.width: 1
    border.color: Theme.colors.line
    clip: true

    // Fast start, soft stop, no overshoot
    Behavior on animWidth {
      NumberAnimation { duration: Theme.duration; easing.type: Easing.OutQuint }
    }
    Behavior on animHeight {
      NumberAnimation { duration: Theme.duration; easing.type: Easing.OutQuint }
    }
    Behavior on radius {
      NumberAnimation { duration: Theme.duration; easing.type: Easing.OutQuint }
    }

    // Hairline between the top row and the opened view
    Rectangle {
      x: Theme.padding
      y: root.compactHeight
      width: parent.width - Theme.padding * 2
      height: 1
      color: Theme.colors.line

      opacity: root.open ? 1 : 0
      Behavior on opacity {
        NumberAnimation { duration: Theme.durationFast }
      }
    }

    // Takes clicks and wheel on the whole shape, so they don't reach the windows below.
    // Controls in the full view sit above it and get their clicks first
    MouseArea {
      anchors.fill: parent

      onClicked: mouse => {
        const windowX = mouse.x + shape.x
        const compactEnd = root.showTrailing ? root.trailingX - root.dividerGap : Infinity
        if (mouse.y < root.compactHeight && windowX < compactEnd && root.current) root.current.tapped()
      }
      onWheel: wheel => root.scrolled(wheel.angleDelta.y)
    }

    // Short delay before opening, so passing the mouse over the bar doesn't pop it
    HoverHandler {
      id: hover

      onHoveredChanged: {
        if (hovered) {
          closeTimer.stop()
          openTimer.restart()
        } else {
          openTimer.stop()
          closeTimer.restart()
        }
      }

      onPointChanged: root.pointAt(point.position.x, point.position.y)
    }

    Timer {
      id: openTimer
      interval: 60
      onTriggered: {
        root.hoverOpen = true
        root.pointAt(hover.point.position.x, hover.point.position.y)
      }
    }

    // A brief slip off the shape doesn't close it
    Timer {
      id: closeTimer
      interval: 300
      onTriggered: root.hoverOpen = false
    }

    // Back in the island's coordinates; the shape clips it
    Item {
      x: -shape.x
      y: -shape.y
      width: root.width
      height: root.height

      Divider {
        id: divider

        x: root.trailingX - root.dividerGap - width
        y: Math.round((root.compactHeight - height) / 2)

        opacity: root.showTrailing && !root.compactEmpty ? 1 : 0
        visible: opacity > 0
        Behavior on opacity {
          NumberAnimation { duration: Theme.durationFast }
        }
      }

      Item {
        id: trailingSlot

        x: root.trailingX
        y: Math.round((root.compactHeight - height) / 2)
        width: childrenRect.width
        height: childrenRect.height

        // Fades out quickly, so it doesn't overlap the compact view while the shape shrinks
        opacity: root.showTrailing ? 1 : 0
        visible: opacity > 0
        Behavior on opacity {
          NumberAnimation { duration: Theme.durationFast }
        }
      }

      Repeater {
        id: views
        model: root.activities

        Item {
          id: view

          required property var modelData
          property bool isCurrent: modelData === root.current

          property real compactWidth: compactLoader.width
          property real compactHeight: compactLoader.height
          property real fullWidth: fullLoader.width
          property real fullHeight: fullLoader.height

          anchors.fill: parent

          Binding {
            target: view.modelData
            property: "shown"
            value: view.isCurrent
          }

          Binding {
            target: view.modelData
            property: "opened"
            value: view.modelData === root.panel && root.open
          }

          Loader {
            id: compactLoader

            x: root.compactX
            y: Math.round((root.compactHeight - height) / 2)

            sourceComponent: view.modelData.compact

            opacity: view.isCurrent ? 1 : 0
            visible: opacity > 0
            Behavior on opacity {
              NumberAnimation { duration: Theme.durationFast; easing.type: Easing.OutCubic }
            }
          }

          Loader {
            id: fullLoader

            x: root.align === "right" ? root.width - Theme.padding - width : Math.round((root.width - width) / 2)
            y: Math.round(root.compactHeight + Theme.padding)

            sourceComponent: view.modelData.full

            opacity: view.modelData.opened ? 1 : 0
            visible: opacity > 0
            Behavior on opacity {
              NumberAnimation { duration: Theme.durationFast; easing.type: Easing.OutCubic }
            }
          }
        }
      }
    }
  }
}
