import Quickshell.Widgets
import QtQuick

import qs.services

import "../theme.js" as Theme

// Notification history, newest first. Click an entry = default action, × = dismiss, Clear = all.
// When empty, a quiet bell in the middle of `fillHeight`
Column {
  id: root

  property real fillHeight: 0

  width: 340
  spacing: 8

  Item {
    width: parent.width
    height: title.height

    SectionTitle {
      id: title
      text: "Notifications"
    }

    TextButton {
      id: clearButton
      anchors.right: parent.right
      anchors.verticalCenter: parent.verticalCenter
      visible: Notifs.count > 0
      text: "Clear"
      onClicked: Notifs.clear()
    }
  }

  // Empty: a quiet bell in the middle of the column
  Item {
    visible: Notifs.count === 0
    width: parent.width
    height: Math.max(160, root.fillHeight - title.height - root.spacing)

    Column {
      anchors.centerIn: parent
      spacing: 10

      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: "\uf1f6"
        font.family: Theme.font.family
        font.pixelSize: 40
        color: Theme.colors.surfaceHover
      }

      DetailText {
        anchors.horizontalCenter: parent.horizontalCenter
        text: "All caught up"
        dim: true
      }
    }
  }

  ListView {
    id: list

    visible: Notifs.count > 0
    width: parent.width
    height: Math.min(contentHeight, 420)

    clip: true
    spacing: 4
    interactive: contentHeight > height
    boundsBehavior: Flickable.StopAtBounds

    model: Notifs.list.slice().reverse()

    delegate: Rectangle {
      id: entry

      property string icon: Notifs.icon(modelData)

      width: list.width
      height: entryContent.height + 16

      radius: Theme.radius
      color: entryHover.hovered ? Theme.colors.surface : "transparent"

      HoverHandler {
        id: entryHover
        cursorShape: Qt.PointingHandCursor
      }

      TapHandler {
        onTapped: Notifs.activate(modelData)
      }

      Row {
        id: entryContent

        x: 8
        y: 8
        width: parent.width - 16
        spacing: 10

        IconImage {
          id: entryIcon
          visible: entry.icon !== ""
          implicitSize: 24
          source: entry.icon
        }

        Column {
          width: parent.width - (entryIcon.visible ? entryIcon.width + parent.spacing : 0)
          spacing: 2

          NotificationHeader {
            width: parent.width
            notification: modelData
            hovered: entryHover.hovered
            onCloseClicked: modelData.dismiss()
          }

          DetailText {
            width: parent.width
            elide: Text.ElideRight
            text: modelData.summary
          }

          DetailText {
            visible: text !== ""
            width: parent.width
            wrapMode: Text.Wrap
            maximumLineCount: 2
            elide: Text.ElideRight
            textFormat: Text.StyledText
            text: modelData.body
            color: Theme.colors.textBright
          }
        }
      }
    }
  }
}
