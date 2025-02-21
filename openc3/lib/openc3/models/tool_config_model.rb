# encoding: ascii-8bit

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

require 'openc3/utilities/local_mode'

module OpenC3
  class ToolConfigModel
    def self.config_tool_names(scope: $openc3_scope)
      _, keys = Store.scan(0, match: "#{scope}__config__*", type: 'hash', count: 100)
      # Just return the tool name that is used in the other APIs
      return keys.map! { |key| key.split('__')[2] }.sort
    end

    def self.list_configs(tool, scope: $openc3_scope)
      Store.hkeys("#{scope}__config__#{tool}")
    end

    def self.load_config(tool, name, scope: $openc3_scope)
      Store.hget("#{scope}__config__#{tool}", name)
    end

    def self.save_config(tool, name, data, local_mode: true, scope: $openc3_scope)
      Store.hset("#{scope}__config__#{tool}", name, data)
      LocalMode.save_tool_config(scope, tool, name, data) if local_mode
    end

    def self.delete_config(tool, name, local_mode: true, scope: $openc3_scope)
      Store.hdel("#{scope}__config__#{tool}", name)
      LocalMode.delete_tool_config(scope, tool, name) if local_mode
    end
  end
end
