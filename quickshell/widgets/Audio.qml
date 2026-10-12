import Quickshell
import Quickshell.Services.Pipewire
import QtQuick

import "../shared.js" as Shared

// Default sink volume. Click = mute, wheel = volume; opens into a volume slider and output picker
Expandable {
  id: root

  property int step: 5

  // Hi-res wheels and touchpads send small deltas; one step per 120 (one notch)
  property real wheelDelta: 0

  property var sink: Pipewire.defaultAudioSink
  property var audio: sink ? sink.audio : null
  property real volume: audio ? Math.min(1, audio.volume) : 0

  property var sinks: Pipewire.nodes.values.filter(node => node.isSink && !node.isStream && node.audio)

  function setVolume(percent) {
    if (audio) audio.volume = Math.max(0, Math.min(100, Math.round(percent))) / 100
  }

  sizeText: "Muted"
  value: !audio ? "-" : audio.muted ? "Muted" : `${Math.round(audio.volume * 100)}%`

  onTapped: if (audio) audio.muted = !audio.muted

  onScrolled: delta => {
    wheelDelta += delta
    const notches = Math.trunc(wheelDelta / 120)
    if (notches === 0) return
    wheelDelta -= notches * 120

    setVolume(volume * 100 + notches * step)
  }

  // Volume/mute are only live on tracked nodes
  PwObjectTracker {
    objects: [root.sink]
  }

  Column {
    width: 260
    spacing: 8

    // Volume slider
    Item {
      width: parent.width
      height: 20

      Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: 8
        radius: 4
        color: Shared.colors.track

        Rectangle {
          width: parent.width * root.volume
          height: parent.height
          radius: parent.radius
          color: root.audio && root.audio.muted ? Shared.colors.textDim : Shared.colors.bgActive
        }
      }

      Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        x: (parent.width - width) * root.volume
        width: 16
        height: 16
        radius: 8
        color: Shared.colors.textWhite
      }

      MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        function apply(x) {
          root.setVolume(x / width * 100)
        }

        onPressed: mouse => apply(mouse.x)
        onPositionChanged: mouse => apply(mouse.x)
      }
    }

    DetailText {
      text: "Output"
      dim: true
    }

    Repeater {
      model: root.sinks

      Rectangle {
        property bool current: modelData === root.sink

        width: parent.width
        height: name.height + 8

        radius: Shared.radius / 2
        color: current ? Shared.colors.bgActive : hover.hovered ? Shared.colors.track : "transparent"

        DetailText {
          id: name

          anchors.verticalCenter: parent.verticalCenter
          x: 8
          width: parent.width - 16
          elide: Text.ElideRight

          text: modelData.nickname || modelData.description || modelData.name
          color: parent.current ? Shared.colors.textWhite : Shared.colors.text
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
