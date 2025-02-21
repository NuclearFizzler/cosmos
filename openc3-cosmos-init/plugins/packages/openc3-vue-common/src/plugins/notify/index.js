/*
# Copyright 2022 Ball Aerospace & Technologies Corp.
# All Rights Reserved.
#
# This program is free software; you can modify and/or redistribute it
# under the terms of the GNU Affero General Public License
# as published by the Free Software Foundation; version 3 with
# attribution addendums as found in the LICENSE.txt
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.

# Modified by OpenC3, Inc.
# All changes Copyright 2024, OpenC3, Inc.
# All Rights Reserved
#
# This file may also be used under the terms of a commercial license
# if purchased from OpenC3, Inc.
*/

import { createApp } from 'vue'
import { vuetify } from '@/plugins'
import Toast from './Toast.vue'

class Notify {
  /*
   * This gets called by the `install()` function below
   */
  constructor(options = {}) {
    this.$store = options.store
    this.mounted = false
    this.$root = null
    if (window.$cosmosNotify?.$root) {
      this.mounted = true
      this.$root = window.$cosmosNotify.$root
    } else {
      window.$cosmosNotify = this
    }
  }

  /*
   * This gets called each time `open()` is invoked by an app in COSMOS.
   * It puts the element into the DOM that allows toasts to be shown.
   */
  mount() {
    if (this.mounted) return

    const app = createApp(Toast)
    app.use(vuetify)

    const el = document.createElement('div')
    document.querySelector('#openc3-app-toolbar > div').appendChild(el)
    this.$root = app.mount(el)
    this.mounted = true
  }

  open({
    method,
    title,
    body,
    message,
    level,
    duration,
    type = 'alert',
    logToConsole = false,
    saveToHistory = true,
  }) {
    this.mount()
    if (logToConsole) {
      if (message) {
        // eslint-disable-next-line no-console
        console.log(`${level.toUpperCase()} - ${message}`)
      } else {
        // eslint-disable-next-line no-console
        console.log(`${level.toUpperCase()} - ${title}: ${body}`)
      }
    }
    if (saveToHistory) {
      this.$store.commit('notifyAddHistory', { title, body, message, level })
    }
    this[method]({ title, body, message, level, duration, type })
  }

  toast({ title, body, message, level, duration, type }) {
    this.$root.toast(
      {
        title,
        body,
        message,
        level,
        type,
      },
      duration,
    )
  }

  critical({
    title,
    body,
    message,
    type,
    duration,
    logToConsole,
    saveToHistory,
  }) {
    this.open({
      method: 'toast',
      level: 'critical',
      title,
      body,
      message,
      type,
      duration,
      logToConsole,
      saveToHistory,
    })
  }
  FATAL(options) {
    this.critical(options)
  }
  ERROR(options) {
    this.critical(options)
  }

  serious({
    title,
    body,
    message,
    type,
    duration,
    logToConsole,
    saveToHistory,
  }) {
    this.open({
      method: 'toast',
      level: 'serious',
      title,
      body,
      message,
      type,
      duration,
      logToConsole,
      saveToHistory,
    })
  }
  caution({
    title,
    body,
    message,
    type,
    duration,
    logToConsole,
    saveToHistory,
  }) {
    this.open({
      method: 'toast',
      level: 'caution',
      title,
      body,
      message,
      type,
      duration,
      logToConsole,
      saveToHistory,
    })
  }
  WARN(options) {
    this.caution(options)
  }

  normal({
    title,
    body,
    message,
    type,
    duration,
    logToConsole,
    saveToHistory,
  }) {
    this.open({
      method: 'toast',
      level: 'normal',
      title,
      body,
      message,
      type,
      duration,
      logToConsole,
      saveToHistory,
    })
  }
  INFO(options) {
    this.normal(options)
  }
  DEBUG(options) {
    this.normal(options)
  }

  standby({
    title,
    body,
    message,
    type,
    duration,
    logToConsole,
    saveToHistory,
  }) {
    this.open({
      method: 'toast',
      level: 'standby',
      title,
      body,
      message,
      type,
      duration,
      logToConsole,
      saveToHistory,
    })
  }

  off({ title, body, message, type, duration, logToConsole, saveToHistory }) {
    this.open({
      method: 'toast',
      level: 'off',
      title,
      body,
      message,
      type,
      duration,
      logToConsole,
      saveToHistory,
    })
  }
}

export default {
  /*
   * This gets called by the Vue runtime when you have `app.use(Notify)` in that app's main .js file.
   */
  install(app, options) {
    const notify = new Notify(options)
    app.provide('notify', notify) // Allows for injection
    if (!app.config.globalProperties.hasOwnProperty('$notify')) {
      app.config.globalProperties.$notify = notify // Allows for `this.$notify`
    }
  },
}
