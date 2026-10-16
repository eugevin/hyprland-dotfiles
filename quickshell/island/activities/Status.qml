import Quickshell.Services.Pipewire
import QtQuick

import qs.island
import qs.components
import qs.services

import "../../theme.js" as Theme

// Right capsule: volume and keyboard layout; opens into the volume slider and the output picker.
// Click = mute, wheel (set up in shell.qml) = volume
Activity {
  onTapped: Audio.toggleMute()

  // Volume | layout, split like the island's date | time
  compact: Row {
    spacing: 14

    Row {
      spacing: 10

      BarText {
        text: Audio.muted ? "\uf026" : "\uf028"
        color: Audio.muted ? Theme.colors.textDim : Theme.colors.accent
      }

      BarText {
        id: percent

        // Width of "100%", so the capsule doesn't twitch while scrolling
        width: Math.ceil(metrics.width)
        text: Audio.muted ? "Off" : `${Math.round(Audio.volume * 100)}%`
        color: Audio.muted ? Theme.colors.textDim : Theme.colors.text

        TextMetrics {
          id: metrics
          font: percent.font
          text: "100%"
        }
      }
    }

    Divider {
      anchors.verticalCenter: parent.verticalCenter
    }

    BarText {
      text: Keyboard.layout.toUpperCase()
    }
  }

  full: Column {
    width: 300
    spacing: 12

    SectionTitle {
      text: "Volume"
    }

    VolumeSlider {
      width: parent.width
      interactive: true
    }

    SectionTitle {
      text: "Output"
    }

    Column {
      width: parent.width
      spacing: 4

      Repeater {
        model: Audio.sinks

        Rectangle {
          property bool current: modelData === Audio.sink

          width: parent.width
          height: name.height + 16

          radius: Theme.radius
          color: current ? Theme.colors.accent : hover.hovered ? Theme.colors.surface : "transparent"

          DetailText {
            id: name

            anchors.verticalCenter: parent.verticalCenter
            x: 12
            width: parent.width - 24
            elide: Text.ElideRight

            text: modelData.nickname || modelData.description || modelData.name
            color: parent.current ? Theme.colors.onAccent : Theme.colors.text
          }

          HoverHandler {
            id: hover
            cursorShape: Qt.PointingHandCursor
          }

          TapHandler {
            onTapped: Pipewire.preferredDefaultAudioSink = modelData
          }
        }
      }
    }
  }
}
