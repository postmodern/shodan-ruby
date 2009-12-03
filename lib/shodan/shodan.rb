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

require 'shodan/query'

require 'mechanize'

module Shodan
  # Common proxy port.
  COMMON_PROXY_PORT = 8080

  #
  # The proxy information used by {Query}.
  #
  # @return [Hash]
  #   The proxy information.
  #
  def Shodan.proxy
    @@shodan_proxy ||= {:host => nil, :port => COMMON_PROXY_PORT, :user => nil, :password => nil}
  end

  #
  # Creates a HTTP URI based from the given proxy information.
  #
  # @param [Hash] proxy_info (Shodan.proxy)
  #   The proxy information.
  #
  # @option proxy_info [String] :host
  #   The host of the proxy.
  #
  # @option proxy_info [Integer] :port (COMMON_PROXY_PORT)
  #   The port of the proxy.
  #
  # @option proxy_info [String] :user
  #   The user name to authenticate as.
  #
  # @option proxy_info [String] :password
  #   The password to authenticate with.
  #
  def Shodan.proxy_uri(proxy_info=Shodan.proxy)
    if Shodan.proxy[:host]
      return URI::HTTP.build(
        :host => Shodan.proxy[:host],
        :port => Shodan.proxy[:port],
        :userinfo => "#{Shodan.proxy[:user]}:#{Shodan.proxy[:password]}",
        :path => '/'
      )
    end
  end
  
  #
  # The supported Shodan User-Agent Aliases.
  #
  # @return [Hash{String => String}]
  #   The User-Agent aliases and strings.
  #
  def Shodan.user_agent_aliases
    WWW::Mechanize::AGENT_ALIASES
  end

  #
  # The default Shodan User-Agent
  #
  # @return [String]
  #   The default User-Agent string used by Shodan.
  #
  def Shodan.user_agent
    @@shodan_user_agent ||= Shodan.user_agent_aliases['Windows IE 6']
  end

  #
  # Sets the default Shodan User-Agent.
  #
  # @param [String] agent
  #   The User-Agent string to use.
  #
  # @return [String]
  #   The new User-Agent string.
  #
  def Shodan.user_agent=(agent)
    @@shodan_user_agent = agent
  end

  #
  # Sets the default Shodan User-Agent alias.
  #
  # @param [String] name
  #   The alias of the User-Agent string to use.
  #
  # @return [String]
  #   The new User-Agent string.
  # 
  def Shodan.user_agent_alias=(name)
    @@shodan_user_agent = Shodan.user_agent_aliases[name.to_s]
  end

  #
  # Creates a new WWW::Mechanize agent.
  #
  # @param [Hash] options
  #   Additional options.
  #
  # @option options [String] :user_agent_alias
  #   The User-Agent alias to use.
  #
  # @option options [String] :user_agent (Shodan.user_agent)
  #   The User-Agent string to use.
  #
  # @option options [Hash] :proxy (Shodan.proxy)
  #   The proxy information to use.
  #
  # @option :proxy [String] :host
  #   The host of the proxy.
  #
  # @option :proxy [Integer] :port
  #   The port of the proxy.
  #
  # @option :proxy [String] :user
  #   The user to authenticate as.
  #
  # @option :proxy [String] :password
  #   The password to authenticate with.
  #
  # @example Creating a new Mechanize agent.
  #   Shodan.web_agent
  #
  # @example Creating a new Mechanize agent with a User-Agent alias.
  #   Shodan.web_agent(:user_agent_alias => 'Linux Mozilla')
  #
  # @example Creating a new Mechanize agent with a User-Agent string.
  #   Shodan.web_agent(:user_agent => 'Google Bot')
  #
  def Shodan.web_agent(options={},&block)
    agent = WWW::Mechanize.new

    if options[:user_agent_alias]
      agent.user_agent_alias = options[:user_agent_alias]
    elsif options[:user_agent]
      agent.user_agent = options[:user_agent]
    elsif Shodan.user_agent
      agent.user_agent = Shodan.user_agent
    end

    proxy = (options[:proxy] || Shodan.proxy)
    if proxy[:host]
      agent.set_proxy(proxy[:host],proxy[:port],proxy[:user],proxy[:password])
    end

    block.call(agent) if block
    return agent
  end

  #
  # Creates a new Query object.
  #
  # @param [Hash] options
  #   Additional options.
  #
  # @option options [String] :query
  #   The query expression.
  #
  # @option options [Array<String>] :countries
  #   The Country Codes to search within.
  #
  # @option options [String] :country
  #   A Country Code to search within.
  #
  # @option options [Array<String>] :hostnames
  #   The host names to search for.
  #
  # @option options [String] :hostname
  #   A host name to search for.
  #
  # @option options [Array<String>] :networks
  #   The CIDR network blocks to search within.
  #
  # @option options [String] :network
  #   A CIDR network blocks to search within.
  #
  # @option options [Array<Integer>] :ports
  #   The ports to search for.
  #
  # @option options [Integer] :port
  #   A port to search for.
  #
  # @yield [query]
  #   If a block is given, it will be passed the newly created Query
  #   object.
  #
  # @yieldparam [Query] query
  #   The newly created Query object.
  #
  # @return [Query]
  #   The new Query object.
  #
  def Shodan.query(options={},&block)
    Query.new(options,&block)
  end
end
