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

require 'shodan/extensions/uri'
require 'shodan/countries'
require 'shodan/has_pages'
require 'shodan/page'
require 'shodan/shodan'

require 'net/http'
require 'nokogiri'

module Shodan
  class Query

    include HasPages

    # Search URL
    SEARCH_URL = 'http://shodan.surtri.com/'

    # Results per page
    RESULTS_PER_PAGE = 20

    # Search query
    attr_accessor :query

    # Countries to search within
    attr_accessor :countries

    # Hostnames to search for
    attr_accessor :hostnames

    # CIDR Network blocks to search within
    attr_accessor :networks

    # Ports to search for
    attr_accessor :ports

    def initialize(options={},&block)
      @agent = Shodan.web_agent
      @query = options[:query]

      @countries = []

      if options[:countries]
        @countries += options[:countries]
      elsif options[:country]
        @countries << option[:country]
      end

      @hostnames = []

      if options[:hostnames]
        @hostnames += options[:hostnames]
      elsif options[:hostname]
        @hostnames << options[:hostname]
      end

      @networks = []

      if options[:networks]
        @networks += options[:networks]
      elsif options[:network]
        @networks << options[:network]
      end

      @ports = []

      if options[:ports]
        @ports += options[:ports]
      elsif options[:port]
        @ports << options[:port]
      end

      block.call(self) if block
    end

    def self.from_url(url)
      url = URI(url.to_s)

      return self.new(
        :query => url.query_params['q'].gsub('+',' ')
      )
    end

    def results_per_page
      RESULTS_PER_PAGE
    end

    def expression
      expr = []

      expr << @query if @query

      expr += @countries.map { |code| "country:#{code}" }
      expr += @hostnames.map { |host| "host:#{host}" }
      expr += @networks.map { |net| "net:#{net}" }
      expr += @ports.map { |port| "port:#{port}" }

      return expr.join(' ')
    end

    def search_url
      url = URI(SEARCH_URL)

      url.query_params['q'] = expression
      return url
    end

    def page_url(index)
      url = search_url

      unless index == 1
        url.query_params['page'] = index
      end

      return url
    end

    def page(index)
      Page.new do |new_page|
        doc = @agent.get(page_url(index))

        doc.search('#search/div.result').each do |result|
          div = result.at('div')

          ip = if (a = div.at('a'))
                 a.inner_text
               else
                 div.children.first.inner_text
               end

          hostname = if (host_node = result.at('div/a:last'))
                       host_node.inner_text
                     end

          date = result.at('div/span').inner_text.split(' ').last
          response = result.at('p').inner_text.strip

          new_page << Host.new(ip,date,response,hostname)
        end
      end
    end

  end
end
