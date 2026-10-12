import Quickshell
import Quickshell.Widgets
import QtQuick

import "../shared.js" as Shared

// Notification count; opens into the history, newest first.
// Click an entry = default action, × = dismiss, Clear = dismiss all.
Expandable {
  id: root

  icon: "\uf0f3"
  value: `${Notifs.count}`
  sizeText: "99"

  Column {
    width: 340
    spacing: 8

    Item {
      width: parent.width
      height: clearButton.height

      DetailText {
        anchors.verticalCenter: parent.verticalCenter
        text: "Notifications"
        dim: true
      }

      Rectangle {
        id: clearButton

        anchors.right: parent.right
        visible: Notifs.count > 0
        width: clearText.width + 20
        height: clearText.height + 8

        radius: Shared.radius / 2
        color: clearHover.hovered ? Shared.colors.bgActive : Shared.colors.track

        DetailText {
          id: clearText
          anchors.centerIn: parent
          text: "Clear"
          color: clearHover.hovered ? Shared.colors.textWhite : Shared.colors.text
        }

        HoverHandler {
          id: clearHover
          cursorShape: Qt.PointingHandCursor
        }

        TapHandler {
          onTapped: Notifs.clear()
        }
      }
    }

    DetailText {
      visible: Notifs.count === 0
      text: "Nothing here"
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

        radius: Shared.radius / 2
        color: entryHover.hovered ? Shared.colors.track : "transparent"

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

            Item {
              width: parent.width
              height: appName.height

              DetailText {
                id: appName
                width: parent.width - side.width - 8
                elide: Text.ElideRight
                text: modelData.appName
                dim: true
              }

              // Time, or × to dismiss while hovered
              DetailText {
                id: side
                anchors.right: parent.right
                text: entryHover.hovered ? "\uf00d" : Notifs.time(modelData)
                dim: !dismissHover.hovered

                HoverHandler {
                  id: dismissHover
                }

                TapHandler {
                  // Exclusive grab, so the click doesn't also hit the notification underneath
                  gesturePolicy: TapHandler.ReleaseWithinBounds
                  onTapped: modelData.dismiss()
                }
              }
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
              color: Shared.colors.textWhite
            }
          }
        }
      }
    }
  }
}
