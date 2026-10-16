pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// Whether the app launcher is open (qs ipc call launcher toggle), and the recently launched apps
// (desktop entry ids, newest first), kept in Quickshell's state dir across restarts
Singleton {
  id: root

  property bool open: false
  property alias recent: adapter.recent
  property int maxRecent: 20

  function toggle() {
    open = !open
  }

  function close() {
    open = false
  }

  function remember(id) {
    adapter.recent = [id].concat(adapter.recent.filter(other => other !== id)).slice(0, maxRecent)
    file.writeAdapter()
  }

  FileView {
    id: file

    path: Quickshell.statePath("launcher.json")

    // First start: no file yet
    onLoadFailed: error => {
      if (error === FileViewError.FileNotFound) writeAdapter()
    }

    JsonAdapter {
      id: adapter
      property list<string> recent: []
    }
  }
}
