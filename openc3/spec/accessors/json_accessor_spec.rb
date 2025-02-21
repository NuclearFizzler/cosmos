# encoding: ascii-8bit

# Copyright 2024 OpenC3, Inc.
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
#
# This file may also be used under the terms of a commercial license
# if purchased from OpenC3, Inc.

require 'spec_helper'
require 'openc3'
require 'openc3/accessors/json_accessor'

module OpenC3
  describe JsonAccessor do
    before(:each) do
      @data1 = '{ "packet": {"item1": 1, "item2": 1.234, "item3": "a string", "item4": [1, 2, 3, 4], "item5": {"another": "object"}, "item6": {"json_class": "String", "raw": [195, 40]}, "item7": {"json_class":"Float","raw":"NaN"}, "item8": {"json_class":"Float","raw":"Infinity"}, "item9": {"json_class":"Float","raw":"-Infinity"} } }'
      @data2 = '[ { "packet": {"item1": 1, "item2": 1.234, "item3": "a string", "item4": [1, 2, 3, 4], "item5": {"another": "object"}} }, { "packet": {"item1": 2, "item2": 2.234, "item3": "another string", "item4": [5, 6, 7, 8], "item5": {"another": "packet"}} }]'
      @hash_data = '{"test":"one"}'
      @array_data = '[4, 3, 2, 1]'
    end

    describe "read_item" do
      it "should return nil for an item that does not exist" do
        item = OpenStruct.new
        item.key = "$.packet.nope"
        item.data_type = :INT
        item.array_size = nil
        expect(JsonAccessor.read_item(item, @hash_data)).to eq(nil)
      end

      it "should read a top level hash" do
        item = OpenStruct.new
        item.key = "$"
        item.data_type = :OBJECT
        item.array_size = nil
        expect(JsonAccessor.read_item(item, @hash_data)).to eq({'test' => 'one'})
      end

      it "should read a top level array" do
        item = OpenStruct.new
        item.key = "$"
        item.data_type = :INT
        item.array_size = 32
        expect(JsonAccessor.read_item(item, @array_data)).to eq([4, 3, 2, 1])
      end

      it "should handle various keys" do
        item = OpenStruct.new
        item.key = '$.packet.item1'
        item.data_type = :INT
        item.array_size = nil
        expect(JsonAccessor.read_item(item, @data1)).to eq 1
        item.data_type = :FLOAT
        expect(JsonAccessor.read_item(item, @data1)).to eq 1.0
        item.data_type = :STRING
        expect(JsonAccessor.read_item(item, @data1)).to eq '1'

        item = OpenStruct.new
        item.key = '$.packet.item2'
        item.data_type = :FLOAT
        item.array_size = nil
        expect(JsonAccessor.read_item(item, @data1)).to eq 1.234

        item = OpenStruct.new
        item.key = '$.packet.item3'
        item.data_type = :STRING
        item.array_size = nil
        expect(JsonAccessor.read_item(item, @data1)).to eq "a string"

        item = OpenStruct.new
        item.key = '$.packet.item4'
        item.data_type = :INT
        item.array_size = 32
        expect(JsonAccessor.read_item(item, @data1)).to eq [1, 2, 3, 4]

        item = OpenStruct.new
        item.key = '$.packet.item5'
        item.data_type = :OBJECT
        item.array_size = nil
        expect(JsonAccessor.read_item(item, @data1)).to eq({'another' => 'object'})

        item = OpenStruct.new
        item.key = '$.packet.item5.another'
        item.data_type = :STRING
        item.array_size = nil
        expect(JsonAccessor.read_item(item, @data1)).to eq "object"

        item = OpenStruct.new
        item.key = '$.packet.item4[3]'
        item.data_type = :INT
        item.array_size = nil
        expect(JsonAccessor.read_item(item, @data1)).to eq 4

        item = OpenStruct.new
        item.key = '$.packet.item6'
        item.data_type = :BLOCK
        item.array_size = nil
        expect(JsonAccessor.read_item(item, @data1)).to eq "\xC3\x28"

        item = OpenStruct.new
        item.key = '$.packet.item7'
        item.data_type = :FLOAT
        item.array_size = nil
        expect(JsonAccessor.read_item(item, @data1).nan?).to eq true

        item = OpenStruct.new
        item.key = '$.packet.item8'
        item.data_type = :FLOAT
        item.array_size = nil
        expect(JsonAccessor.read_item(item, @data1)).to eq Float::INFINITY

        item = OpenStruct.new
        item.key = '$.packet.item9'
        item.data_type = :FLOAT
        item.array_size = nil
        expect(JsonAccessor.read_item(item, @data1)).to eq(-Float::INFINITY)

        item = OpenStruct.new
        item.key = '$[0].packet.item1'
        item.data_type = :UINT
        item.array_size = nil
        expect(JsonAccessor.read_item(item, @data2)).to eq 1

        item = OpenStruct.new
        item.key = '$[0].packet.item2'
        item.data_type = :FLOAT
        item.array_size = nil
        expect(JsonAccessor.read_item(item, @data2)).to eq 1.234

        item = OpenStruct.new
        item.key = '$[0].packet.item3'
        item.data_type = :STRING
        item.array_size = nil
        expect(JsonAccessor.read_item(item, @data2)).to eq "a string"

        item = OpenStruct.new
        item.key = '$[0].packet.item4'
        item.data_type = :INT
        item.array_size = 32
        expect(JsonAccessor.read_item(item, @data2)).to eq [1, 2, 3, 4]

        item = OpenStruct.new
        item.key = '$[0].packet.item5'
        item.data_type = :OBJECT
        item.array_size = nil
        expect(JsonAccessor.read_item(item, @data2)).to eq({'another' => 'object'})

        item = OpenStruct.new
        item.key = '$[0].packet.item5.another'
        item.data_type = :STRING
        item.array_size = nil
        expect(JsonAccessor.read_item(item, @data2)).to eq "object"

        item = OpenStruct.new
        item.key = '$[0].packet.item4[3]'
        item.data_type = :INT
        item.array_size = nil
        expect(JsonAccessor.read_item(item, @data2)).to eq 4

        item = OpenStruct.new
        item.key = '$[1].packet.item1'
        item.data_type = :UINT
        item.array_size = nil
        expect(JsonAccessor.read_item(item, @data2)).to eq 2

        item = OpenStruct.new
        item.key = '$[1].packet.item2'
        item.data_type = :FLOAT
        item.array_size = nil
        expect(JsonAccessor.read_item(item, @data2)).to eq 2.234

        item = OpenStruct.new
        item.key = '$[1].packet.item3'
        item.data_type = :STRING
        item.array_size = nil
        expect(JsonAccessor.read_item(item, @data2)).to eq "another string"

        item = OpenStruct.new
        item.key = '$[1].packet.item4'
        item.data_type = :INT
        item.array_size = 32
        expect(JsonAccessor.read_item(item, @data2)).to eq [5, 6, 7, 8]

        item = OpenStruct.new
        item.key = '$[1].packet.item5'
        item.data_type = :OBJECT
        item.array_size = nil
        expect(JsonAccessor.read_item(item, @data2)).to eq({'another' => 'packet'})

        item = OpenStruct.new
        item.key = '$[1].packet.item5.another'
        item.data_type = :STRING
        item.array_size = nil
        expect(JsonAccessor.read_item(item, @data2)).to eq "packet"

        item = OpenStruct.new
        item.key = '$[1].packet.item4[3]'
        item.data_type = :INT
        item.array_size = nil
        expect(JsonAccessor.read_item(item, @data2)).to eq 8
      end
    end

    describe "read_items" do
      it "should read a collection of items" do
        item1 = OpenStruct.new
        item1.name = 'ITEM1'
        item1.key = '$.packet.item1'
        item1.data_type = :INT
        item1.array_size = nil
        item2 = OpenStruct.new
        item2.name = 'ITEM2'
        item2.key = '$.packet.item2'
        item2.data_type = :FLOAT
        item2.array_size = nil
        item3 = OpenStruct.new
        item3.name = 'ITEM3'
        item3.key = '$.packet.item3'
        item3.data_type = :STRING
        item3.array_size = nil
        item4 = OpenStruct.new
        item4.name = 'ITEM4'
        item4.key = '$.packet.item4'
        item4.data_type = :INT
        item4.array_size = 32
        item5 = OpenStruct.new
        item5.name = 'ITEM5'
        item5.key = '$.packet.item5'
        item5.data_type = :OBJECT
        item5.array_size = nil
        item6 = OpenStruct.new
        item6.name = 'ITEM6'
        item6.key = '$.packet.item5.another'
        item6.data_type = :STRING
        item6.array_size = nil
        item7 = OpenStruct.new
        item7.name = 'ITEM7'
        item7.key = '$.packet.item4[3]'
        item7.data_type = :INT
        item7.array_size = nil

        result = JsonAccessor.read_items([item1, item2, item3, item4, item5, item6, item7], @data1)
        expect(result.length).to eq 7
        expect(result['ITEM1']).to eq 1
        expect(result['ITEM2']).to eq 1.234
        expect(result['ITEM3']).to eq "a string"
        expect(result['ITEM4']).to eq [1, 2, 3, 4]
        expect(result['ITEM5']).to eq({'another' => 'object'})
        expect(result['ITEM6']).to eq "object"
        expect(result['ITEM7']).to eq 4

        item1 = OpenStruct.new
        item1.name = 'ITEM1'
        item1.key = '$[0].packet.item1'
        item1.data_type = :INT
        item1.array_size = nil
        item2 = OpenStruct.new
        item2.name = 'ITEM2'
        item2.key = '$[0].packet.item2'
        item2.data_type = :FLOAT
        item2.array_size = nil
        item3 = OpenStruct.new
        item3.name = 'ITEM3'
        item3.key = '$[0].packet.item3'
        item3.data_type = :STRING
        item3.array_size = nil
        item4 = OpenStruct.new
        item4.name = 'ITEM4'
        item4.key = '$[0].packet.item4'
        item4.data_type = :INT
        item4.array_size = 32
        item5 = OpenStruct.new
        item5.name = 'ITEM5'
        item5.key = '$[0].packet.item5'
        item5.data_type = :OBJECT
        item5.array_size = nil
        item6 = OpenStruct.new
        item6.name = 'ITEM6'
        item6.key = '$[0].packet.item5.another'
        item6.data_type = :STRING
        item6.array_size = nil
        item7 = OpenStruct.new
        item7.name = 'ITEM7'
        item7.key = '$[0].packet.item4[3]'
        item7.data_type = :INT
        item7.array_size = nil
        item8 = OpenStruct.new
        item8.name = 'ITEM8'
        item8.key = '$[1].packet.item1'
        item8.data_type = :INT
        item8.array_size = nil
        item9 = OpenStruct.new
        item9.name = 'ITEM9'
        item9.key = '$[1].packet.item2'
        item9.data_type = :FLOAT
        item9.array_size = nil
        item10 = OpenStruct.new
        item10.name = 'ITEM10'
        item10.key = '$[1].packet.item3'
        item10.data_type = :STRING
        item10.array_size = nil
        item11 = OpenStruct.new
        item11.name = 'ITEM11'
        item11.key = '$[1].packet.item4'
        item11.data_type = :INT
        item11.array_size = 32
        item12 = OpenStruct.new
        item12.name = 'ITEM12'
        item12.key = '$[1].packet.item5'
        item12.data_type = :OBJECT
        item12.array_size = nil
        item13 = OpenStruct.new
        item13.name = 'ITEM13'
        item13.key = '$[1].packet.item5.another'
        item13.data_type = :STRING
        item13.array_size = nil
        item14 = OpenStruct.new
        item14.name = 'ITEM14'
        item14.key = '$[1].packet.item4[3]'
        item14.data_type = :INT
        item14.array_size = nil

        result = JsonAccessor.read_items([item1, item2, item3, item4, item5, item6, item7, item8, item9, item10, item11, item12, item13, item14], @data2)
        expect(result.length).to eq 14
        expect(result['ITEM1']).to eq 1
        expect(result['ITEM2']).to eq 1.234
        expect(result['ITEM3']).to eq "a string"
        expect(result['ITEM4']).to eq [1, 2, 3, 4]
        expect(result['ITEM5']).to eq({'another' => 'object'})
        expect(result['ITEM6']).to eq "object"
        expect(result['ITEM7']).to eq 4
        expect(result['ITEM8']).to eq 2
        expect(result['ITEM9']).to eq 2.234
        expect(result['ITEM10']).to eq "another string"
        expect(result['ITEM11']).to eq [5, 6, 7, 8]
        expect(result['ITEM12']).to eq({'another' => 'packet'})
        expect(result['ITEM13']).to eq "packet"
        expect(result['ITEM14']).to eq 8
      end
    end

    describe "write_item" do
      it "should write different types" do
        item = OpenStruct.new
        item.key = '$.packet.item1'
        # DERIVED items aren't actually written
        item.data_type = :DERIVED
        item.array_size = nil
        expect(JsonAccessor.write_item(item, 3, @data1)).to be nil
        # Reading DERIVED items always returns None
        expect(JsonAccessor.read_item(item, @data1)).to eq nil
        json = JSON.parse(@data1)
        expect(json['packet']['item1']).to eql 1

        item = OpenStruct.new
        item.key = '$.packet.item1'
        item.data_type = :UINT
        item.array_size = nil
        JsonAccessor.write_item(item, 3, @data1)
        expect(JsonAccessor.read_item(item, @data1)).to eq 3
        json = JSON.parse(@data1)
        expect(json['packet']['item1']).to eql 3

        item = OpenStruct.new
        item.key = '$.packet.item1'
        item.data_type = :FLOAT
        item.array_size = nil
        JsonAccessor.write_item(item, 3, @data1)
        expect(JsonAccessor.read_item(item, @data1)).to eq 3.0
        json = JSON.parse(@data1)
        expect(json['packet']['item1']).to eql 3.0

        item = OpenStruct.new
        item.key = '$.packet.item1'
        item.data_type = :STRING
        item.array_size = nil
        JsonAccessor.write_item(item, 3, @data1)
        expect(JsonAccessor.read_item(item, @data1)).to eq '3'
        json = JSON.parse(@data1)
        expect(json['packet']['item1']).to eql '3'

        item = OpenStruct.new
        item.key = '$.packet.item2'
        item.data_type = :FLOAT
        item.array_size = nil
        JsonAccessor.write_item(item, 3.14, @data1)
        expect(JsonAccessor.read_item(item, @data1)).to eq 3.14

        item = OpenStruct.new
        item.key = '$.packet.item2'
        item.data_type = :FLOAT
        item.array_size = nil
        JsonAccessor.write_item(item, Float::NAN, @data1)
        expect(JsonAccessor.read_item(item, @data1).nan?).to be true

        item = OpenStruct.new
        item.key = '$.packet.item2'
        item.data_type = :FLOAT
        item.array_size = nil
        JsonAccessor.write_item(item, Float::INFINITY, @data1)
        expect(JsonAccessor.read_item(item, @data1)).to eq Float::INFINITY

        item = OpenStruct.new
        item.key = '$.packet.item2'
        item.data_type = :FLOAT
        item.array_size = nil
        JsonAccessor.write_item(item, -Float::INFINITY, @data1)
        expect(JsonAccessor.read_item(item, @data1)).to eq(-Float::INFINITY)

        item = OpenStruct.new
        item.key = '$.packet.item3'
        item.data_type = :STRING
        item.array_size = nil
        JsonAccessor.write_item(item, "something different", @data1)
        expect(JsonAccessor.read_item(item, @data1)).to eq "something different"

        item = OpenStruct.new
        item.key = '$.packet.item3'
        item.data_type = :BLOCK
        item.array_size = nil
        JsonAccessor.write_item(item, "\xC3\x28", @data1)
        expect(JsonAccessor.read_item(item, @data1)).to eq "\xC3\x28"

        item = OpenStruct.new
        item.key = '$.packet.item4'
        item.array_size = 32
        item.data_type = :INT
        item.array_size = 32
        JsonAccessor.write_item(item, [7,8,9,10], @data1)
        expect(JsonAccessor.read_item(item, @data1)).to eq [7,8,9,10]

        item = OpenStruct.new
        item.key = '$.packet.item4'
        item.array_size = 32
        item.data_type = :FLOAT
        item.array_size = 32
        JsonAccessor.write_item(item, [7,8,9,10], @data1)
        expect(JsonAccessor.read_item(item, @data1)).to eq [7.0,8.0,9.0,10.0]

        item = OpenStruct.new
        item.key = '$.packet.item4'
        item.array_size = 32
        item.data_type = :STRING
        item.array_size = 32
        JsonAccessor.write_item(item, [7,8,9,10], @data1)
        expect(JsonAccessor.read_item(item, @data1)).to eq ['7','8','9','10']

        item = OpenStruct.new
        item.key = '$.packet.item5'
        item.data_type = :OBJECT
        item.array_size = nil
        JsonAccessor.write_item(item, {'good' => 'times'}, @data1)
        expect(JsonAccessor.read_item(item, @data1)).to eq({'good' => 'times'})

        item = OpenStruct.new
        item.key = '$.packet.item5.good'
        item.data_type = :STRING
        item.array_size = nil
        JsonAccessor.write_item(item, 'friends', @data1)
        expect(JsonAccessor.read_item(item, @data1)).to eq "friends"

        item = OpenStruct.new
        item.key = '$.packet.item4[3]'
        item.data_type = :INT
        item.array_size = nil
        JsonAccessor.write_item(item, 15, @data1)
        expect(JsonAccessor.read_item(item, @data1)).to eq 15

        item = OpenStruct.new
        item.key = '$[0].packet.item1'
        item.data_type = :INT
        item.array_size = nil
        JsonAccessor.write_item(item, 5, @data2)
        expect(JsonAccessor.read_item(item, @data2)).to eq 5

        item = OpenStruct.new
        item.key = '$[0].packet.item2'
        item.data_type = :FLOAT
        item.array_size = nil
        JsonAccessor.write_item(item, 5.05, @data2)
        expect(JsonAccessor.read_item(item, @data2)).to eq 5.05

        item = OpenStruct.new
        item.key = '$[0].packet.item3'
        item.data_type = :STRING
        item.array_size = nil
        JsonAccessor.write_item(item, "something", @data2)
        expect(JsonAccessor.read_item(item, @data2)).to eq "something"

        item = OpenStruct.new
        item.key = '$[0].packet.item4'
        item.data_type = :STRING
        item.array_size = nil
        JsonAccessor.write_item(item, 'string', @data2)
        expect(JsonAccessor.read_item(item, @data2)).to eq 'string'

        item = OpenStruct.new
        item.key = '$[0].packet.item5'
        item.data_type = :OBJECT
        item.array_size = nil
        JsonAccessor.write_item(item, {'bill' => 'ted'}, @data2)
        expect(JsonAccessor.read_item(item, @data2)).to eq({'bill' => 'ted'})

        item = OpenStruct.new
        item.key = '$[0].packet.item5.another'
        item.data_type = :STRING
        item.array_size = nil
        JsonAccessor.write_item(item, 'money', @data2)
        expect(JsonAccessor.read_item(item, @data2)).to eq "money"

        item = OpenStruct.new
        item.key = '$[0].packet.item4[3]'
        item.data_type = :INT
        item.array_size = nil
        JsonAccessor.write_item(item, 25, @data2)
        expect(JsonAccessor.read_item(item, @data2)).to eq 25

        item = OpenStruct.new
        item.key = '$[1].packet.item1'
        item.data_type = :UINT
        item.array_size = nil
        JsonAccessor.write_item(item, 7, @data2)
        expect(JsonAccessor.read_item(item, @data2)).to eq 7

        item = OpenStruct.new
        item.key = '$[1].packet.item2'
        item.data_type = :FLOAT
        item.array_size = nil
        JsonAccessor.write_item(item, 3.13, @data2)
        expect(JsonAccessor.read_item(item, @data2)).to eq 3.13

        item = OpenStruct.new
        item.key = '$[1].packet.item3'
        item.data_type = :STRING
        item.array_size = nil
        JsonAccessor.write_item(item, "small", @data2)
        expect(JsonAccessor.read_item(item, @data2)).to eq "small"

        item = OpenStruct.new
        item.key = '$[1].packet.item4'
        item.data_type = :INT
        item.array_size = 32
        JsonAccessor.write_item(item, [101, 102, 103, 104], @data2)
        expect(JsonAccessor.read_item(item, @data2)).to eq [101, 102, 103, 104]

        item = OpenStruct.new
        item.key = '$[1].packet.item5'
        item.data_type = :OBJECT
        item.array_size = nil
        JsonAccessor.write_item(item, {'happy' => 'sad'}, @data2)
        expect(JsonAccessor.read_item(item, @data2)).to eq({'happy' => 'sad'})

        item = OpenStruct.new
        item.key = '$[1].packet.item5.another'
        item.data_type = :STRING
        item.array_size = nil
        JsonAccessor.write_item(item, "art", @data2)
        expect(JsonAccessor.read_item(item, @data2)).to eq "art"

        item = OpenStruct.new
        item.key = '$[1].packet.item4[3]'
        item.data_type = :INT
        item.array_size = nil
        JsonAccessor.write_item(item, 14, @data2)
        expect(JsonAccessor.read_item(item, @data2)).to eq 14
      end
    end

    describe "write_items" do
      it "should write multiple items" do
        item1 = OpenStruct.new
        item1.key = '$.packet.item1'
        item1.data_type = :INT
        item1.array_size = nil
        item2 = OpenStruct.new
        item2.key = '$.packet.item2'
        item2.data_type = :FLOAT
        item2.array_size = nil
        item3 = OpenStruct.new
        item3.key = '$.packet.item3'
        item3.data_type = :STRING
        item3.array_size = nil
        item4 = OpenStruct.new
        item4.key = '$.packet.item4'
        item4.data_type = :INT
        item4.array_size = 32
        item5 = OpenStruct.new
        item5.key = '$.packet.item5'
        item5.data_type = :OBJECT
        item5.array_size = nil
        item6 = OpenStruct.new
        item6.key = '$.packet.item5.good'
        item6.data_type = :STRING
        item6.array_size = nil
        item7 = OpenStruct.new
        item7.key = '$.packet.item4[3]'
        item7.data_type = :UINT
        item7.array_size = nil

        items = [item1, item2, item3, item4, item5, item6, item7]
        values = [3, 3.14, "something different", [7,8,9,10], {'good' => 'friends'}, 'friends', 15]
        JsonAccessor.write_items(items, values, @data1)
        expect(JsonAccessor.read_item(item1, @data1)).to eq 3
        expect(JsonAccessor.read_item(item2, @data1)).to eq 3.14
        expect(JsonAccessor.read_item(item3, @data1)).to eq "something different"
        expect(JsonAccessor.read_item(item4, @data1)).to eq [7,8,9,15]
        expect(JsonAccessor.read_item(item5, @data1)).to eq({'good' => 'friends'})
        expect(JsonAccessor.read_item(item6, @data1)).to eq "friends"
        expect(JsonAccessor.read_item(item7, @data1)).to eq 15

        item1 = OpenStruct.new
        item1.key = '$[0].packet.item1'
        item1.data_type = :INT
        item1.array_size = nil
        item2 = OpenStruct.new
        item2.key = '$[0].packet.item2'
        item2.data_type = :FLOAT
        item2.array_size = nil
        item3 = OpenStruct.new
        item3.key = '$[0].packet.item3'
        item3.data_type = :STRING
        item3.array_size = nil
        item4 = OpenStruct.new
        item4.key = '$[0].packet.item4'
        item4.data_type = :INT
        item4.array_size = 32
        item5 = OpenStruct.new
        item5.key = '$[0].packet.item5'
        item5.data_type = :OBJECT
        item5.array_size = nil
        item6 = OpenStruct.new
        # Select item5.bill because we write {"bill": "ted"}
        item6.key = '$[0].packet.item5.bill'
        item6.data_type = :STRING
        item6.array_size = nil
        item7 = OpenStruct.new
        item7.key = '$[0].packet.item4[3]'
        item7.data_type = :INT
        item7.array_size = nil
        item8 = OpenStruct.new
        item8.key = '$[1].packet.item1'
        item8.data_type = :UINT
        item8.array_size = nil
        item9 = OpenStruct.new
        item9.key = '$[1].packet.item2'
        item9.data_type = :FLOAT
        item9.array_size = nil
        item10 = OpenStruct.new
        item10.key = '$[1].packet.item3'
        item10.data_type = :STRING
        item10.array_size = nil
        item11 = OpenStruct.new
        item11.key = '$[1].packet.item4'
        item11.data_type = :INT
        item11.array_size = 32
        item12 = OpenStruct.new
        item12.key = '$[1].packet.item5'
        item12.data_type = :OBJECT
        item12.array_size = nil
        item13 = OpenStruct.new
        # Select item5.happy because we write {"happy": "sad"}
        item13.key = '$[1].packet.item5.happy'
        item13.data_type = :STRING
        item13.array_size = nil
        item14 = OpenStruct.new
        item14.key = '$[1].packet.item4[3]'
        item14.data_type = :INT
        item14.array_size = nil

        items = [item1, item2, item3, item4, item5, item6, item7, item8, item9, item10, item11, item12, item13, item14]
        values = [5, 5.05, "something", [1,2,3,4], {'bill' => 'ted'}, 'money', 25, 7, 3.13, "small", [101, 102, 103, 104], {'happy' => 'sad'}, "art", 14]
        JsonAccessor.write_items(items, values, @data2)
        expect(JsonAccessor.read_item(item1, @data2)).to eq 5
        expect(JsonAccessor.read_item(item2, @data2)).to eq 5.05
        expect(JsonAccessor.read_item(item3, @data2)).to eq "something"
        # Item7 writes 25 over the 4 in the array
        expect(JsonAccessor.read_item(item4, @data2)).to eq [1, 2, 3, 25]
        expect(JsonAccessor.read_item(item5, @data2)).to eq({'bill' => 'money'})
        expect(JsonAccessor.read_item(item6, @data2)).to eq "money"
        expect(JsonAccessor.read_item(item7, @data2)).to eq 25
        expect(JsonAccessor.read_item(item8, @data2)).to eq 7
        expect(JsonAccessor.read_item(item9, @data2)).to eq 3.13
        expect(JsonAccessor.read_item(item10, @data2)).to eq "small"
        expect(JsonAccessor.read_item(item11, @data2)).to eq [101, 102, 103, 14]
        expect(JsonAccessor.read_item(item12, @data2)).to eq({'happy' => 'art'})
        expect(JsonAccessor.read_item(item13, @data2)).to eq "art"
        expect(JsonAccessor.read_item(item14, @data2)).to eq 14
      end
    end
  end
end
