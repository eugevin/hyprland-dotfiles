import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications
import QtQuick

import "../shared.js" as Shared

// One notification toast. Hides after its timeout but stays in the history.
// Click = default action, × = hide, hover pauses the timeout.
Rectangle {
  id: root

  property int nid: -1
  property var notification: Notifs.byId[nid]
  property bool critical: notification && notification.urgency === NotificationUrgency.Critical
  property string icon: Notifs.icon(notification)

  // expireTimeout is in seconds; <= 0 means "server decides"
  property int timeout: notification && notification.expireTimeout > 0
    ? Math.min(30, notification.expireTimeout) * 1000
    : 5000

  property bool shown: false

  function hide() {
    shown = false
    removeTimer.start()
  }

  height: content.height + 24

  radius: Shared.radius
  color: Shared.colors.bg
  border.width: critical ? 2 : 0
  border.color: Shared.colors.danger

  // Slides in from the right, fades out
  opacity: shown ? 1 : 0
  transform: Translate {
    x: root.shown ? 0 : 40
    Behavior on x {
      NumberAnimation { duration: 200; easing.type: Easing.OutCubic }
    }
  }
  Behavior on opacity {
    NumberAnimation { duration: 200 }
  }

  Component.onCompleted: shown = true

  // Critical ones stay until clicked
  Timer {
    interval: root.timeout
    running: root.shown && !root.critical && !hover.hovered
    onTriggered: root.hide()
  }

  Timer {
    id: removeTimer
    interval: 200
    onTriggered: Notifs.removePopup(root.nid)
  }

  HoverHandler {
    id: hover
    cursorShape: Qt.PointingHandCursor
  }

  TapHandler {
    onTapped: if (root.notification) Notifs.activate(root.notification)
  }

  Row {
    id: content

    x: 12
    y: 12
    width: parent.width - 24
    spacing: 12

    IconImage {
      id: appIcon
      visible: root.icon !== ""
      implicitSize: 36
      source: root.icon
    }

    Column {
      width: parent.width - (appIcon.visible ? appIcon.width + parent.spacing : 0)
      spacing: 4

      Item {
        width: parent.width
        height: appName.height

        DetailText {
          id: appName
          width: parent.width - close.width - 8
          elide: Text.ElideRight
          text: root.notification ? root.notification.appName : ""
          dim: true
        }

        // × hides the toast; the notification stays in the history
        DetailText {
          id: close
          anchors.right: parent.right
          text: "\uf00d"
          dim: !closeHover.hovered

          HoverHandler {
            id: closeHover
          }

          TapHandler {
            // Exclusive grab, so the click doesn't also hit the notification underneath
            gesturePolicy: TapHandler.ReleaseWithinBounds
            onTapped: root.hide()
          }
        }
      }

      DetailText {
        width: parent.width
        wrapMode: Text.Wrap
        maximumLineCount: 2
        elide: Text.ElideRight
        text: root.notification ? root.notification.summary : ""
      }

      DetailText {
        visible: text !== ""
        width: parent.width
        wrapMode: Text.Wrap
        maximumLineCount: 4
        elide: Text.ElideRight
        textFormat: Text.StyledText
        text: root.notification ? root.notification.body : ""
        color: Shared.colors.textWhite
      }

      // App actions other than the default one (that's the click)
      Flow {
        width: parent.width
        spacing: 6
        visible: actions.count > 0

        Repeater {
          id: actions
          model: root.notification ? root.notification.actions.filter(action => action.identifier !== "default") : []

          Rectangle {
            width: actionText.width + 20
            height: actionText.height + 8
            radius: Shared.radius / 2
            color: actionHover.hovered ? Shared.colors.bgActive : Shared.colors.track

            DetailText {
              id: actionText
              anchors.centerIn: parent
              text: modelData.text
              color: actionHover.hovered ? Shared.colors.textWhite : Shared.colors.text
            }

            HoverHandler {
              id: actionHover
            }

            TapHandler {
              // Exclusive grab, so the click doesn't also hit the notification underneath
              gesturePolicy: TapHandler.ReleaseWithinBounds
              onTapped: modelData.invoke()
            }
          }
        }
      }
    }
  }
}
