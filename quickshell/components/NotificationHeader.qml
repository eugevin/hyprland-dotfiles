import QtQuick

import qs.services

// Top line of a notification (toast, history entry): app name, and the time that turns into ×
// while `hovered`. Clicking × emits closeClicked()
Item {
  id: root

  property var notification: null
  property bool hovered: false

  signal closeClicked()

  height: appName.height

  DetailText {
    id: appName
    width: parent.width - side.width - 8
    elide: Text.ElideRight
    text: root.notification ? root.notification.appName : ""
    dim: true
  }

  DetailText {
    id: side
    anchors.right: parent.right
    text: root.hovered ? "\uf00d" : Notifs.time(root.notification)
    dim: !closeHover.hovered

    HoverHandler {
      id: closeHover
    }

    TapHandler {
      // Exclusive grab, so the click doesn't also hit the notification underneath
      gesturePolicy: TapHandler.ReleaseWithinBounds
      onTapped: root.closeClicked()
    }
  }
}
