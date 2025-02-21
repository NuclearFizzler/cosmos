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
# All changes Copyright 2022, OpenC3, Inc.
# All Rights Reserved
#
# This file may also be used under the terms of a commercial license
# if purchased from OpenC3, Inc.
*/

import axios from 'axios'

const axiosInstance = axios.create({
  baseURL: location.origin,
  timeout: 60000,
  params: {},
})

axiosInstance.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response) {
      if (error.response.status === 401) {
        OpenC3Auth.updateToken(OpenC3Auth.defaultMinValidity, true).then(
          function (refreshed) {
            if (refreshed) {
              OpenC3Auth.setTokens()
            }
          },
        )
      }
      // Individual tools can set 'Ignore-Errors' to an error code
      // they potentially expect, e.g. '500', in which case we ignore it
      // For example in CommandSender.vue:
      // obs = this.api.cmd(targetName, commandName, paramList, {
      //   headers: {
      //     'Ignore-Errors': '404',
      //   },
      // })
      if (
        error.response.config.headers['Ignore-Errors'] &&
        error.response.config.headers['Ignore-Errors'].includes(
          error.response.status.toString(),
        )
      ) {
        return Promise.reject(error)
      }
      let body = `HTTP ${error.response.status} - `
      if (error.response?.statusText) {
        body += `${error.response.statusText} `
      }
      if (error.response?.config?.data) {
        body += `${error.response.config.data} `
      }
      if (error.response?.data?.message) {
        body += `${error.response.data.message}`
      } else if (error.response?.data?.exception) {
        body += `${error.response.data.exception}`
      } else if (error.response?.data?.error?.message) {
        if (error.response.data.error.class) {
          body += `${error.response.data.error.class} `
        }
        body += `${error.response.data.error.message}`
      } else {
        body += `${error.response?.data}`
      }
      const { $cosmosNotify } = window
      if ($cosmosNotify) {
        $cosmosNotify.serious({
          title: 'Network error',
          body,
        })
      }
      throw error
    } else {
      throw error
    }
  },
)

export default axiosInstance
