# chef-handler-spinup-complete.rb
# 
# Author: Simple Finance <ops@simple.com>
# License: Apache License, Version 2.0
#
# Copyright 2014 Simple Finance Technology Corporation.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Notifies you of deployment events

require 'chef'
require 'chef/handler'
require 'json'
require 'socket'

class Chef
  class Handler
    class SpinupComplete < Chef::Handler

      def initialize(opts={})
        @handlers = opts.fetch(:handlers, ['default'])
      end

      def report
        begin
          sock = TCPSocket.new('127.0.0.1', 3030)
          sock.write(warn_first)
          sock.write(ok_second)
          sock.close
        rescue Errno::ECONNREFUSED
          Chef::Log.error("Couldn't write to the Sensu client socket")
        end
      end

      private

      def warn_first
        stringify = run_status.success? ? "spunup successfully" : "failed to spinup"
        sensu_payload = {
          handlers: @handlers,
          name: 'spinup',
          output: "#{node.name} #{stringify}",
          status: 1 }
        return JSON.generate(sensu_payload)
      end

      def ok_second
        sensu_payload = {
          handlers: ['nil'],
          name: 'spinup',
          output: "Resolving spinup notification",
          status: 0 }
        return JSON.generate(sensu_payload)
      end
    end
  end
end
