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

require 'spec_helper'
require 'openc3/api/target_api'
require 'openc3/script/extract'
require 'openc3/utilities/authorization'
require 'openc3/topics/command_topic'
require 'openc3/topics/telemetry_topic'

module OpenC3
  describe Api do
    class ApiTest
      include Extract
      include Api
      include Authorization
    end

    before(:each) do
      mock_redis()
      setup_system()

      model = InterfaceModel.new(name: "INST_INT", scope: "DEFAULT", target_names: ["INST"], config_params: ["interface.rb"])
      model.create
      %w(INST EMPTY SYSTEM).each do |target|
        model = TargetModel.new(folder_name: target, name: target, scope: "DEFAULT")
        model.create
        model.update_store(System.new([target], File.join(SPEC_DIR, 'install', 'config', 'targets')))
      end

      @api = ApiTest.new
    end

    describe "get_target_names" do
      it "gets an empty array for an unknown scope" do
        expect(@api.get_target_names(scope: "UNKNOWN")).to be_empty
      end

      it "gets the list of targets" do
        expect(@api.get_target_names(scope: "DEFAULT")).to contain_exactly("EMPTY", "INST", "SYSTEM")
      end
    end

    describe "get_target" do
      it "returns nil if the target doesn't exist" do
        expect(@api.get_target("BLAH", scope: "DEFAULT")).to be_nil
      end

      it "gets a target hash" do
        tgt = @api.get_target("INST", scope: "DEFAULT")
        expect(tgt).to be_a Hash
        expect(tgt['name']).to eql "INST"
      end
    end

    describe "get_target_interfaces" do
      it "gets target name, interface names" do
        info = @api.get_target_interfaces(scope: "DEFAULT")
        expect(info[0][0]).to eq "EMPTY"
        expect(info[0][1]).to eq ""
        expect(info[1][0]).to eq "INST"
        expect(info[1][1]).to eq "INST_INT"
        expect(info[2][0]).to eq "SYSTEM"
        expect(info[2][1]).to eq ""
      end

      it "gets target name, interface names" do
        # Override InterfaceModel with INST having two interfaces
        interfaces = [
          ["INST", {'target_names' => ["INST"], 'name' => 'INST_ONE'}],
          ["INST", {'target_names' => ["INST"], 'name' => 'INST_TWO'}],
        ]
        allow(InterfaceModel).to receive(:all).and_return(interfaces)
        info = @api.get_target_interfaces(scope: "DEFAULT")
        expect(info[0][0]).to eq "EMPTY"
        expect(info[0][1]).to eq ""
        expect(info[1][0]).to eq "INST"
        expect(info[1][1]).to eq "INST_ONE,INST_TWO"
        expect(info[2][0]).to eq "SYSTEM"
        expect(info[2][1]).to eq ""
      end
    end
  end
end
