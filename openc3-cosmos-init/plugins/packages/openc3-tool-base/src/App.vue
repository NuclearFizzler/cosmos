<!--
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
-->

<template>
  <v-app id="app" :style="classificationStyles">
    <app-nav class="d-print-none" />

    <!-- Sizes your content based upon application components -->
    <v-main :style="mainStyle" min-height="100vh">
      <v-container fluid height="100%">
        <div><router-view /></div>
        <div id="openc3-tool" style="overflow: auto"></div>
      </v-container>
    </v-main>
    <app-footer app class="d-print-none" />
    <time-check />
  </v-app>
</template>

<script>
import {
  AppFooter,
  AppNav,
  ClassificationBanners,
  TimeCheck,
} from '@openc3/vue-common/tools/base'

export default {
  components: {
    AppFooter,
    AppNav,
    TimeCheck,
  },
  mixins: [ClassificationBanners],
  data() {
    return {
      mainStyle: {},
    }
  },
  created() {
    if (this.$route.query.chromeless) {
      this.mainStyle = { 'padding-top': '0px !important' }
    }
  },
}
</script>

<style>
#openc3-tool {
  height: 100%;
}
</style>
