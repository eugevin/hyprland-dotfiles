import Quickshell.Widgets
import Quickshell.Services.Notifications
import QtQuick

import qs.components
import qs.services

import "../theme.js" as Theme

// One notification card in the glass style of the bar. Slides in from the right, hides after its
// timeout (paused while hovered) but stays in the history. Click = default action, × = hide.
// Critical ones stay until clicked and get a terracotta edge
Item {
  id: root

  property int nid: -1
  property var notification: Notifs.byId[nid] ?? null
  property bool critical: notification !== null && notification.urgency === NotificationUrgency.Critical
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

  height: card.height

  opacity: shown ? 1 : 0
  Behavior on opacity {
    NumberAnimation { duration: Theme.duration; easing.type: Easing.OutQuint }
  }

  transform: Translate {
    x: root.shown ? 0 : 60
    Behavior on x {
      NumberAnimation { duration: Theme.duration; easing.type: Easing.OutQuint }
    }
  }

  Component.onCompleted: shown = true

  Timer {
    interval: root.timeout
    running: root.shown && !root.critical && !hover.hovered
    onTriggered: root.hide()
  }

  Timer {
    id: removeTimer
    interval: Theme.duration
    onTriggered: Notifs.removePopup(root.nid)
  }

  GlassShadow {
    anchors.fill: card
    radius: card.radius
  }

  Rectangle {
    id: card

    width: parent.width
    height: content.height + 32

    radius: Theme.radiusLarge
    color: Theme.colors.bg
    border.width: 1
    border.color: root.critical ? Theme.colors.danger : Theme.colors.line

    HoverHandler {
      id: hover
      cursorShape: Qt.PointingHandCursor
    }

    TapHandler {
      onTapped: if (root.notification) Notifs.activate(root.notification)
    }

    Row {
      id: content

      x: 18
      y: 16
      width: parent.width - 36
      spacing: 14

      // App icon, or a bell when the app has none
      Rectangle {
        width: 44
        height: 44
        radius: Theme.radius
        color: Theme.colors.surface

        IconImage {
          anchors.centerIn: parent
          visible: root.icon !== ""
          implicitSize: 30
          source: root.icon
        }

        Text {
          anchors.centerIn: parent
          visible: root.icon === ""
          text: "\uf0f3"
          font.family: Theme.font.family
          font.pixelSize: 20
          color: root.critical ? Theme.colors.danger : Theme.colors.accent
        }
      }

      Column {
        width: parent.width - 44 - parent.spacing
        spacing: 4

        // × hides the toast; the notification stays in the history
        NotificationHeader {
          width: parent.width
          notification: root.notification
          hovered: hover.hovered
          onCloseClicked: root.hide()
        }

        DetailText {
          width: parent.width
          wrapMode: Text.Wrap
          maximumLineCount: 2
          elide: Text.ElideRight
          text: root.notification ? root.notification.summary : ""
          font.weight: Theme.font.weightBold
          color: Theme.colors.textBright
        }

        DetailText {
          visible: text !== ""
          width: parent.width
          wrapMode: Text.Wrap
          maximumLineCount: 4
          elide: Text.ElideRight
          textFormat: Text.StyledText
          text: root.notification ? root.notification.body : ""
        }

        // App actions other than the default one (that's the click)
        Flow {
          visible: actions.count > 0
          width: parent.width
          topPadding: 6
          spacing: 6

          Repeater {
            id: actions
            model: root.notification ? root.notification.actions.filter(action => action.identifier !== "default") : []

            TextButton {
              text: modelData.text
              onClicked: modelData.invoke()
            }
          }
        }
      }
    }
  }
}
