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

require 'openc3/conversions/conversion'

module OpenC3
  # Retrieves the result from an item processor
  class ProcessorConversion < Conversion
    # @param processor_name [String] The name of the associated processor
    # @param result_name [String] The name of the associated result in the processor
    # @param converted_type [String or nil] The datatype of the result of the processor
    # @param converted_bit_size [Integer or nil] The bit size of the result of the processor
    # @param converted_array_size [Integer or nil] The total array bit size of the result of the processor
    def initialize(processor_name, result_name, converted_type = nil, converted_bit_size = nil, converted_array_size = nil)
      super()
      @processor_name = processor_name.to_s.upcase
      @result_name = result_name.to_s.upcase.intern
      @params = [@processor_name, @result_name]
      if ConfigParser.handle_nil(converted_type)
        @converted_type = converted_type.to_s.upcase.intern
        raise ArgumentError, "Unknown converted type: #{converted_type}" if !BinaryAccessor::DATA_TYPES.include?(@converted_type)
        @params << @converted_type
      end
      if ConfigParser.handle_nil(converted_bit_size)
        @converted_bit_size = Integer(converted_bit_size)
        @params << @converted_bit_size
      end
      if ConfigParser.handle_nil(converted_array_size)
        @converted_array_size = Integer(converted_array_size)
        @params << @converted_array_size
      end
    end

    # @param (see Conversion#call)
    # @return [Varies] The result of the associated processor
    def call(value, packet, buffer)
      packet.processors[@processor_name].results[@result_name] || 0 # Never return nil
    end

    # @return [String] The type of processor
    def to_s
      "ProcessorConversion #{@processor_name} #{@result_name}"
    end

    # @param (see Conversion#to_config)
    # @return [String] Config fragment for this conversion
    def to_config(read_or_write)
      config = "    #{read_or_write}_CONVERSION #{self.class.name.class_name_to_filename} #{@processor_name} #{@result_name}"
      config << " #{@converted_type}" if @converted_type
      config << " #{@converted_bit_size}" if @converted_bit_size
      config << " #{@converted_array_size}" if @converted_array_size
      config << "\n"
      config
    end
  end
end
