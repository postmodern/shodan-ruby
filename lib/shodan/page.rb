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
    # Creates a new Page object with the given _hosts_. If a _block_
    # is given, it will be passed the newly created Page object.
    #
    def initialize(hosts=[],&block)
      super(hosts)

      block.call(self) if block
    end

    #
    # Returns a mapped Array of the hosts within the Page using the
    # given _block_. If the _block_ is not given, the page will be
    # returned.
    #
    #   page.map
    #   # => #<Page: ...>
    #
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
    # Selects the hosts within the Page which match the given _block_.
    #
    #   page.select { |host| host.headers['Server'] =~ /IIS/ }
    #
    def select(&block)
      self.class.new(super(&block))
    end

    alias hosts_with select

    def each_ip(&block)
      each do |host|
        block.call(host.ip) if block
      end
    end

    def hosts_with_ip(ip,&block)
      hosts_with do |host|
        if host.ip.match(ip)
          block.call(host) if block
          
          true
        end
      end
    end

    def ips
      Enumerator.new(self,:each_ip).to_a
    end

    def each_hostname(&block)
      each do |host|
        block.call(host.name) if (block && host.name)
      end
    end

    def hosts_with_name(name,&block)
      hosts_with do |host|
        if (host.name && host.name.match(name))
          block.call(host) if block

          true
        end
      end
    end

    def hostnames
      Enumerator.new(self,:each_hostname)
    end

    def each_date(&block)
      each do |host|
        block.call(host.date) if block
      end
    end

    def dates
      Enumerator.new(self,:each_date).to_a
    end

    def each_response(&block)
      each do |host|
        block.call(host.response) if block
      end
    end

    def responses_with(pattern,&block)
      hosts_with do |host|
        if host.response.match(pattern)
          block.call(host) if block

          true
        end
      end
    end

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

    def each_headers(&block)
      each do |host|
        block.call(host.headers) if block
      end
    end

    def headers
      Enumerator.new(self,:each_headers).to_a
    end

  end
end
