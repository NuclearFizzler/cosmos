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
# All changes Copyright 2022, OpenC3, Inc.
# All Rights Reserved
#
# This file may also be used under the terms of a commercial license
# if purchased from OpenC3, Inc.
-->

<template>
  <div ref="container" :style="computedStyle">
    <!-- The widget-index is the order in the widget name: VALUELIMITSCOLUMN -->
    <limitscolumn-widget
      v-bind="$attrs"
      :parameters="parameters"
      :settings="[...appliedSettings]"
      :screen-values="screenValues"
      :widget-index="1"
      :line="line"
      :lineNumber="lineNumber"
    />
    <value-widget
      v-bind="$attrs"
      :parameters="parameters"
      :settings="[...appliedSettings]"
      :screen-values="screenValues"
      :screen-time-zone="screenTimeZone"
      :widget-index="0"
    />
  </div>
</template>

<script>
import ValueWidget from './ValueWidget.vue'
import LimitscolumnWidget from './LimitscolumnWidget.vue'
import Widget from './Widget'

export default {
  mixins: [Widget],
  components: {
    ValueWidget,
    LimitscolumnWidget,
  },
}
</script>
