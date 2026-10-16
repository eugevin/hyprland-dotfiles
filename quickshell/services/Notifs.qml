pragma Singleton

import Quickshell
import Quickshell.Services.Notifications
import QtQuick

// Notification daemon. Every notification stays in the history until dismissed;
// new ones are also queued in `popups` for the toasts on the right.
Singleton {
  id: root

  property var list: server.trackedNotifications.values
  property int count: list.length

  // Notifications don't carry their arrival time; keyed by id
  property var times: ({})
  property var byId: ({})

  // Toasts on screen, newest first; entries are { nid }. A ListModel, so the toasts already on
  // screen keep their delegates (timers, animations) when one is added or removed
  property ListModel popups: ListModel {}
  property int maxPopups: 4

  function removePopup(id) {
    for (let i = 0; i < popups.count; i++) {
      if (popups.get(i).nid === id) {
        popups.remove(i)
        return
      }
    }
  }

  function clear() {
    for (const notification of list.slice()) notification.dismiss()
  }

  // Click: run the app's default action if it has one, otherwise just dismiss
  function activate(notification) {
    const action = notification.actions.find(action => action.identifier === "default")
    if (action) action.invoke()
    else notification.dismiss()
  }

  function icon(notification) {
    if (!notification) return ""
    if (notification.image) return notification.image

    const icon = notification.appIcon
    if (!icon) return ""
    if (icon.startsWith("/")) return `file://${icon}`
    if (icon.includes("://")) return icon
    return Quickshell.iconPath(icon, true)
  }

  function time(notification) {
    const date = notification ? times[notification.id] : null
    return date ? Qt.formatDateTime(date, "HH:mm") : ""
  }

  NotificationServer {
    id: server

    keepOnReload: true
    persistenceSupported: true
    bodySupported: true
    bodyMarkupSupported: true
    actionsSupported: true
    imageSupported: true

    onNotification: notification => {
      const id = notification.id
      notification.tracked = true

      root.times[id] = new Date()
      root.byId[id] = notification

      // Carried over from before a reload: already seen, don't pop it up again
      if (!notification.lastGeneration) {
        root.popups.insert(0, { nid: id })
        if (root.popups.count > root.maxPopups) root.popups.remove(root.maxPopups, root.popups.count - root.maxPopups)
      }

      notification.closed.connect(() => {
        root.removePopup(id)
        delete root.byId[id]
        delete root.times[id]
      })
    }
  }
}
