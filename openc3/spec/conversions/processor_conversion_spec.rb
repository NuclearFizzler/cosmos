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
# All changes Copyright 2024, OpenC3, Inc.
# All Rights Reserved
#
# This file may also be used under the terms of a commercial license
# if purchased from OpenC3, Inc.

require 'spec_helper'
require 'openc3/conversions/processor_conversion'

module OpenC3
  describe PolynomialConversion do
    describe "initialize" do
      it "takes processor_name, result_name, converted_type, and converted_bit_size" do
        c = ProcessorConversion.new('TEST', 'TEST', 'FLOAT', '64', '128')
        expect(c.instance_variable_get("@processor_name")).to eql 'TEST'
        expect(c.instance_variable_get("@result_name")).to eql :TEST
        expect(c.converted_type).to eql :FLOAT
        expect(c.converted_bit_size).to eql 64
        expect(c.converted_array_size).to eql 128
      end
    end

    describe "call" do
      it "retrieves the result from the processor" do
        c = ProcessorConversion.new('TEST', 'TEST', 'FLOAT', '64')
        packet = Packet.new("tgt", "pkt")
        packet.append_item('ITEM1', 64, :FLOAT)
        packet.processors['TEST'] = double("processor", :results => { :TEST => 6.0 })
        expect(c.call(1, packet, nil)).to eql 6.0
      end
    end

    describe "to_s" do
      it "returns the equation" do
        expect(ProcessorConversion.new('TEST1', 'TEST2', 'FLOAT', '64', '128').to_s).to eql "ProcessorConversion TEST1 TEST2"
      end
    end

    describe "as_json" do
      it "creates a reproducible format" do
        pc = ProcessorConversion.new('TEST1', 'TEST2', 'FLOAT', '64', '128')
        json = pc.as_json
        expect(json['class']).to eql "OpenC3::ProcessorConversion"
        expect(json['converted_type']).to eql :FLOAT
        expect(json['converted_bit_size']).to eql 64
        expect(json['converted_array_size']).to eql 128
        expect(json['params']).to eql ['TEST1', 'TEST2', "FLOAT", 64, 128]
        new_pc = OpenC3::const_get(json['class']).new(*json['params'])
        packet = Packet.new("tgt", "pkt")
        packet.append_item('ITEM1', 64, :FLOAT)
        packet.processors['TEST1'] = double("processor", :results => { :TEST2 => 6.0 })
        expect(pc.call(1, packet, nil)).to eql new_pc.call(1, packet, nil)
      end
    end
  end
end
