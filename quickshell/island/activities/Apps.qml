import Quickshell
import Quickshell.Widgets
import QtQuick

import qs.island
import qs.components
import qs.services

import "../../theme.js" as Theme

// App launcher (qs ipc call launcher toggle): the top row turns into a search field, matching
// apps open under it. Up/Down/Tab = select, Enter or click = launch, Esc = close
Activity {
  id: root

  property string query: ""
  property int selected: 0
  property int maxResults: 8

  // Name matches first, then the rest (generic name, keywords); within each, recently launched
  // first, then alphabetical. With no query that's simply the recent apps on top
  property var results: {
    const q = query.trim().toLowerCase()
    const apps = DesktopEntries.applications.values.filter(app => !app.noDisplay)
    const matches = q === "" ? apps : apps.filter(app =>
      [app.name, app.genericName, app.comment, ...(app.keywords || [])]
        .some(text => text && text.toLowerCase().includes(q)))

    const recent = Launcher.recent
    const rank = app => {
      const i = recent.indexOf(app.id)
      return i < 0 ? Infinity : i
    }

    return matches.sort((a, b) => {
      const aName = a.name.toLowerCase().includes(q)
      const bName = b.name.toLowerCase().includes(q)
      if (aName !== bName) return aName ? -1 : 1
      if (rank(a) !== rank(b)) return rank(a) < rank(b) ? -1 : 1
      return a.name.localeCompare(b.name)
    }).slice(0, maxResults)
  }

  function move(step) {
    if (results.length) selected = (selected + step + results.length) % results.length
  }

  function launch(app) {
    Launcher.remember(app.id)
    app.execute()
    Launcher.close()
  }

  priority: 4
  active: Launcher.open
  keepOpen: true
  hideTrailing: true

  onQueryChanged: selected = 0

  compact: Row {
    spacing: 10

    // A fresh search every time it opens
    Connections {
      target: root

      function onShownChanged() {
        if (!root.shown) return
        input.text = ""
        input.forceActiveFocus()
      }
    }

    BarText {
      text: "\uf002"
      color: Theme.colors.accent
    }

    Item {
      width: 360
      height: input.height

      TextInput {
        id: input

        width: parent.width
        clip: true

        font.family: Theme.font.family
        font.pixelSize: Theme.font.size
        font.weight: Theme.font.weight
        color: Theme.colors.textBright
        selectionColor: Theme.colors.accent

        onTextChanged: root.query = text
        onAccepted: if (root.results.length) root.launch(root.results[root.selected])

        Keys.onPressed: event => {
          if (event.key === Qt.Key_Escape) Launcher.close()
          else if (event.key === Qt.Key_Down || event.key === Qt.Key_Tab) root.move(1)
          else if (event.key === Qt.Key_Up || event.key === Qt.Key_Backtab) root.move(-1)
          else return
          event.accepted = true
        }
      }

      BarText {
        visible: input.text === ""
        text: "Search..."
        color: Theme.colors.textDim
      }
    }
  }

  full: Column {
    width: 420
    spacing: 4

    DetailText {
      visible: root.results.length === 0
      text: "No matches"
      dim: true
    }

    Repeater {
      model: root.results

      Rectangle {
        id: row

        property bool current: index === root.selected
        property string iconPath: Quickshell.iconPath(modelData.icon, true)

        width: parent.width
        height: 40

        radius: Theme.radius
        color: current ? Theme.colors.accent : "transparent"

        Row {
          anchors.verticalCenter: parent.verticalCenter
          x: 10
          spacing: 12

          Item {
            anchors.verticalCenter: parent.verticalCenter
            width: 26
            height: 26

            IconImage {
              visible: row.iconPath !== ""
              anchors.fill: parent
              source: row.iconPath
            }

            // No icon in the theme: a tile with the first letter
            Rectangle {
              visible: row.iconPath === ""
              anchors.fill: parent
              radius: 8
              color: row.current ? Theme.colors.onAccent : Theme.colors.surfaceHover

              DetailText {
                anchors.centerIn: parent
                text: modelData.name.charAt(0).toUpperCase()
                font.weight: Theme.font.weightBold
                color: Theme.colors.accent
              }
            }
          }

          DetailText {
            anchors.verticalCenter: parent.verticalCenter
            text: modelData.name
            color: row.current ? Theme.colors.onAccent : Theme.colors.text
          }
        }

        HoverHandler {
          cursorShape: Qt.PointingHandCursor
          onHoveredChanged: if (hovered) root.selected = index
        }

        TapHandler {
          onTapped: root.launch(modelData)
        }
      }
    }
  }
}
