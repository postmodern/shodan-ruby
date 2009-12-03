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

require 'shodan/host'

module Shodan
  class Page < Array

    #
    # Creates a new Page object.
    #
    # @param [Array] hosts
    #   The initial hosts.
    #
    # @yield [page]
    #   If a block is given, it will be passed the page.
    #
    # @yieldparam [Page] page
    #   The newly created Page object.
    #
    def initialize(hosts=[],&block)
      super(hosts)

      block.call(self) if block
    end

    #
    # Maps the hosts within the page.
    #
    # @yield [host]
    #   The given block will be used to map each host in the page.
    #
    # @yieldparam [Host] host
    #   A host within the page.
    #
    # @return [Array]
    #   The resulting mapped Array.
    #
    # @example
    #   page.map
    #   # => #<Page: ...>
    #
    # @example
    #   page.map { |host| host.ip }
    #   # => [...]
    #
    def map(&block)
      return self unless block

      mapped = []

      each { |element| mapped << block.call(element) }
      return mapped
    end

    #
    # Selects the hosts within the page.
    #
    # @yield [host]
    #   The given block will be used to select hosts from the page.
    #
    # @yieldparam [Host] host
    #   A host in the page.
    #
    # @return [Page]
    #   A sub-set of the hosts within the page.
    #
    # @example
    #   page.select { |host| host.headers['Server'] =~ /IIS/ }
    #
    def select(&block)
      self.class.new(super(&block))
    end

    alias hosts_with select

    #
    # Iterates over the IP addresses of every host in the page.
    #
    # @yield [ip]
    #   If a block is given, it will be passed the IP addresses of every
    #   host.
    #
    # @yieldparam [String] ip
    #   An IP address of a host.
    #
    # @return [self]
    #
    def each_ip(&block)
      each do |host|
        block.call(host.ip) if block
      end
    end

    #
    # Selects the hosts with the matching IP address.
    #
    # @param [Regexp, String] ip
    #   The IP address to search for.
    #
    # @yield [host]
    #   If a block is also given, it will be passed every matching host.
    #
    # @yieldparam [Host] host
    #   A host with the matching IP address.
    #
    # @return [Array<Host>]
    #   The hosts with the matching IP address.
    #
    def hosts_with_ip(ip,&block)
      hosts_with do |host|
        if host.ip.match(ip)
          block.call(host) if block
          
          true
        end
      end
    end

    #
    # The IP addresses of the hosts in the page.
    #
    # @return [Array<String>]
    #   The IP addresses.
    #
    def ips
      Enumerator.new(self,:each_ip).to_a
    end

    #
    # Iterates over the host names of every host in the page.
    #
    # @yield [hostname]
    #   If a block is given, it will be passed the host names of every host.
    #
    # @yieldparam [String] hostname
    #   A host name.
    #
    # @return [self]
    #
    def each_hostname(&block)
      each do |host|
        block.call(host.hostname) if (block && host.hostname)
      end
    end

    #
    # Selects the hosts with the matching host name.
    #
    # @param [Regexp, String] hostname
    #   The host name to search for.
    #
    # @yield [host]
    #   If a block is also given, it will be passed every matching host.
    #
    # @yieldparam [Host] host
    #   A host with the matching host name.
    #
    # @return [Array<Host>]
    #   The hosts with the matching host name.
    #
    def hosts_with_name(name,&block)
      hosts_with do |host|
        if (host.hostname && host.hostname.match(name))
          block.call(host) if block

          true
        end
      end
    end

    #
    # The names of the hosts in the page.
    #
    # @return [Array<String>]
    #   The host names.
    #
    def hostnames
      Enumerator.new(self,:each_hostname).to_a
    end

    #
    # Iterates over the dates that each host was added.
    #
    # @yield [date]
    #   If a block is given, it will be passed the dates that each host was
    #   added.
    #
    # @yieldparam [Date] date
    #   A date that a host was added.
    #
    # @return [self]
    #
    def each_date(&block)
      each do |host|
        block.call(host.date) if block
      end
    end

    #
    # The dates that the hosts were added.
    #
    # @return [Array<Date>]
    #   The dates.
    #
    def dates
      Enumerator.new(self,:each_date).to_a
    end

    #
    # Iterates over the responses of each host in the page.
    #
    # @yield [response]
    #   If a block is given, it will be passed the responses of each host.
    #
    # @yieldparam [String] response
    #   The initial response of a host.
    #
    # @return [self]
    #
    def each_response(&block)
      each do |host|
        block.call(host.response) if block
      end
    end

    #
    # Selects the hosts with the matching response.
    #
    # @param [Regexp, String] pattern
    #   The response pattern to search for.
    #
    # @yield [host]
    #   If a block is also given, it will be passed every matching host.
    #
    # @yieldparam [Host] host
    #   A host with the matching response.
    #
    # @return [Array<Host>]
    #   The hosts with the matching response.
    #
    def responses_with(pattern,&block)
      hosts_with do |host|
        if host.response.match(pattern)
          block.call(host) if block

          true
        end
      end
    end

    #
    # The responses of the hosts in the page.
    #
    # @return [Array<String>]
    #   The responses.
    #
    def responses(&block)
      Enumerator.new(self,:each_response).to_a
    end

    def each_http_version(&block)
      each do |host|
        block.call(host.http_version) if block
      end
    end

    def http_versions
      Enumerator.new(self,:each_http_version).to_a
    end

    def each_http_code(&block)
      each do |host|
        block.call(host.http_code) if block
      end
    end

    def http_codes
      Enumerator.new(self,:each_http_code).to_a
    end

    def each_http_status(&block)
      each do |host|
        block.call(host.http_status) if block
      end
    end

    def http_statuses
      Enumerator.new(self,:each_http_status).to_a
    end

    #
    # Itereates over the HTTP headers of each host in the page.
    #
    # @yield [headers]
    #   If a block is given, it will be passed the headers from each host
    #   in the page.
    #
    # @yieldparam [Hash] headers
    #   The headers from a host in the page.
    #
    # @return [self]
    #
    def each_http_headers(&block)
      each do |host|
        block.call(host.http_headers) if block
      end
    end

    #
    # The HTTP headers from the hosts in the page.
    #
    # @return [Array<Hash>]
    #   The HTTP headers.
    #
    def http_headers
      Enumerator.new(self,:each_http_headers).to_a
    end

  end
end
