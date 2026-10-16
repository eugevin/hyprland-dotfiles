pragma Singleton

import Quickshell
import Quickshell.Services.Pipewire
import QtQuick

// Default output: volume, mute and the device list
Singleton {
  id: root

  property int step: 5

  // Hi-res wheels and touchpads send small deltas; one step per 120 (one notch)
  property real wheelDelta: 0

  property var sink: Pipewire.defaultAudioSink
  property var audio: sink ? sink.audio : null
  property real volume: audio ? Math.min(1, audio.volume) : 0
  property bool muted: audio ? audio.muted : false

  property var sinks: Pipewire.nodes.values.filter(node => node.isSink && !node.isStream && node.audio)

  function setVolume(percent) {
    if (audio) audio.volume = Math.max(0, Math.min(100, Math.round(percent))) / 100
  }

  function toggleMute() {
    if (audio) audio.muted = !audio.muted
  }

  function scroll(delta) {
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
}
