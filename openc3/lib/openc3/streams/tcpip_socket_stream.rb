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

require 'socket'
require 'thread' # For Mutex
require 'timeout' # For Timeout::Error
require 'openc3/streams/stream'
require 'openc3/config/config_parser'

module OpenC3
  # Data {Stream} which reads and writes from Tcpip Sockets.
  class TcpipSocketStream < Stream
    attr_reader :write_socket

    # @param write_socket [Socket] Socket to write
    # @param read_socket [Socket] Socket to read
    # @param write_timeout [Float] Seconds to wait before aborting writes
    # @param read_timeout [Float|nil] Seconds to wait before aborting reads.
    #   Pass nil to block until the read is complete.
    def initialize(write_socket, read_socket, write_timeout, read_timeout)
      super()

      @write_socket  = write_socket
      @read_socket   = read_socket
      @write_timeout = ConfigParser.handle_nil(write_timeout)
      if @write_timeout
        @write_timeout = @write_timeout.to_f
      else
        Logger.warn("Warning: To avoid interface lock, write_timeout can not be nil. Setting to 10 seconds.")
        @write_timeout = 10.0
      end
      @read_timeout  = ConfigParser.handle_nil(read_timeout)
      @read_timeout  = @read_timeout.to_f if @read_timeout

      # Mutex on write is needed to protect from commands coming in from more
      # than one tool
      @write_mutex = Mutex.new
      @pipe_reader, @pipe_writer = IO.pipe
      @connected = false
    end

    # Connect the stream
    def connect
      # If called directly this class is acting as a server and does not need to connect the sockets
      @connected = true
    end

    # @return [Boolean] Whether the sockets are connected
    def connected?
      @connected
    end

    # Disconnect by closing the sockets
    def disconnect
      OpenC3.close_socket(@write_socket)
      OpenC3.close_socket(@read_socket)
      @pipe_writer.write('.')
      @connected = false
    end

    # @return [String] Returns a binary string of data from the socket
    def read
      raise "Attempt to read from write only stream" unless @read_socket

      # No read mutex is needed because reads happen serially
      begin
        while true # Loop until we get some data
          data = @read_socket.read_nonblock(65535, exception: false)
          raise EOFError, 'end of file reached' unless data

          if data == :wait_readable
            # Wait for the socket to be ready for reading or for the timeout
            begin
              result = IO.fast_select([@read_socket, @pipe_reader], nil, nil, @read_timeout)
              # If select returns something it means the socket is now available for
              # reading so retry the read. If it returns nil it means we timed out.
              # If the pipe is present that means we closed the socket
              if result
                if result.include?(@pipe_reader)
                  raise IOError
                else
                  next
                end
              else
                raise Timeout::Error, "Read Timeout"
              end
            rescue IOError, Errno::ENOTSOCK
              # These can happen with the socket being closed while waiting on select
              data = ''
            end
          end
          break
        end
      rescue Errno::ECONNRESET, Errno::ECONNABORTED, IOError, Errno::ENOTSOCK
        data = ''
      end
      data
    end

    # @return [String] Returns a binary string of data from the socket. Always returns immediately
    def read_nonblock
      # No read mutex is needed because reads happen serially
      begin
        data = @read_socket.read_nonblock(65535, exception: false)
        raise EOFError, 'end of file reached' unless data
        data = '' if data == :wait_readable
      rescue Errno::EAGAIN, Errno::EWOULDBLOCK, Errno::ECONNRESET, Errno::ECONNABORTED, IOError
        data = ''
      end
      data
    end

    # @param data [String] A binary string of data to write to the socket
    def write(data)
      raise "Attempt to write to read only stream" unless @write_socket

      @write_mutex.synchronize do
        num_bytes_to_send = data.length
        total_bytes_sent = 0
        bytes_sent = 0
        data_to_send = data

        loop do
          begin
            bytes_sent = @write_socket.write_nonblock(data_to_send)
          rescue Errno::EAGAIN, Errno::EWOULDBLOCK
            # Wait for the socket to be ready for writing or for the timeout
            result = IO.fast_select(nil, [@write_socket], nil, @write_timeout)
            # If select returns something it means the socket is now available for
            # writing so retry the write. If it returns nil it means we timed out.
            if result
              retry
            else
              raise Timeout::Error, "Write Timeout"
            end
          end
          total_bytes_sent += bytes_sent
          break if total_bytes_sent >= num_bytes_to_send

          data_to_send = data[total_bytes_sent..-1]
        end
      end
    end

    def set_option(option_name, option_values)
      option_name_upcase = option_name.upcase

      case option_name_upcase
      when 'KEEPALIVE'
        @write_socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_KEEPALIVE, true)
        @read_socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_KEEPALIVE, true)
      when 'KEEPCNT'
        @write_socket.setsockopt(Socket::SOL_TCP, Socket::TCP_KEEPCNT, Integer(option_values[0]))
        @read_socket.setsockopt(Socket::SOL_TCP, Socket::TCP_KEEPCNT, Integer(option_values[0]))
      when 'KEEPIDLE'
        @write_socket.setsockopt(Socket::SOL_TCP, Socket::TCP_KEEPIDLE, Integer(option_values[0]))
        @read_socket.setsockopt(Socket::SOL_TCP, Socket::TCP_KEEPIDLE, Integer(option_values[0]))
      when 'KEEPINTVL'
        @write_socket.setsockopt(Socket::SOL_TCP, Socket::TCP_KEEPINTVL, Integer(option_values[0]))
        @read_socket.setsockopt(Socket::SOL_TCP, Socket::TCP_KEEPINTVL, Integer(option_values[0]))
      end
    end
  end
end
