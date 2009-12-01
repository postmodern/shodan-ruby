#
# shodan-ruby - A Ruby interface to SHODAN, a computer search engine.
#
# Copyright (c) 2009 Hal Brodigan (postmodern.mod3 at gmail.com)
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
#

module Shodan
  class Host

    # The IP of the host
    attr_reader :ip

    # The date the host was added
    attr_reader :date

    # The host-name of the host
    attr_reader :hostname

    # The response returned by the host
    attr_reader :response

    # The HTTP version supported by the host
    attr_reader :http_version

    # The HTTP status code in the response
    attr_reader :http_code

    # The HTTP status string in the response
    attr_reader :http_status

    # The HTTP headers included in the response
    attr_reader :http_headers

    # The body of the HTTP response
    attr_reader :http_body

    #
    # Creates a new host with the given _ip_, _data_, _response_ and _hostname_.
    #
    def initialize(ip,date,response,hostname=nil)
      @ip = ip
      @date = Date.parse(date)
      @response = response
      @hostname = hostname

      @http_version = nil
      @http_code = nil
      @http_status = nil
      @http_headers = {}
      @http_body = nil

      if response =~ /^HTTP\/?/
        lines = response.split(/[\r\n]/)
        match = lines.first.split(/\s+/,3)

        if match[0].include?('/')
          @http_version = match[0].split('/').last
        end

        if match[1]
          @http_code = match[1].to_i
        end

        @http_status = match[2]
        @http_body = ''

        lines[1..-1].each_with_index do |line,index|
          if line.empty?
            @http_body = lines[(index+2)..-1].join("\n")
            break
          end

          name, value = line.chomp.split(/:\s+/,2)

          @http_headers[name] = value
        end
      end
    end

    #
    # Returns the Server software name.
    #
    def server_name
      if (server = @http_headers['Server'])
        return server.split('/',2).first
      end
    end

    #
    # Returns the Server software version.
    #
    def server_version
      if (server = @http_headers['Server'])
        return server.split('/',2).last
      end
    end

    protected

    #
    # Provides transparent access to the values in +headers+.
    #
    def method_missing(sym,*args,&block)
      if (args.empty? && block.nil?)
        name = sym.id2name.sub('_','-').capitalize

        return @http_headers[name] if @http_headers.key?(name)
      end

      return super(sym,*args,&block)
    end

  end
end
