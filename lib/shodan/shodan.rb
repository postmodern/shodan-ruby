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
  # Returns the +Hash+ of proxy information.
  #
  def Shodan.proxy
    @@shodan_proxy ||= {:host => nil, :port => COMMON_PROXY_PORT, :user => nil, :password => nil}
  end

  #
  # Creates a HTTP URI based from the given _proxy_info_ hash. The
  # _proxy_info_ hash defaults to Web.proxy, if not given.
  #
  # _proxy_info_ may contain the following keys:
  # <tt>:host</tt>:: The proxy host.
  # <tt>:port</tt>:: The proxy port. Defaults to COMMON_PROXY_PORT,
  #                  if not specified.
  # <tt>:user</tt>:: The user-name to login as.
  # <tt>:password</tt>:: The password to login with.
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
  # Returns the supported Shodan User-Agent Aliases.
  #
  def Shodan.user_agent_aliases
    WWW::Mechanize::AGENT_ALIASES
  end

  #
  # Returns the Shodan User-Agent
  #
  def Shodan.user_agent
    @@shodan_user_agent ||= Shodan.user_agent_aliases['Windows IE 6']
  end

  #
  # Sets the Shodan User-Agent to the specified _agent_.
  #
  def Shodan.user_agent=(agent)
    @@shodan_user_agent = agent
  end

  #
  # Sets the Shodan User-Agent using the specified user-agent alias
  # _name_.
  # 
  def Shodan.user_agent_alias=(name)
    @@shodan_user_agent = Shodan.user_agent_aliases[name.to_s]
  end

  #
  # Creates a new WWW::Mechanize agent with the given _options_.
  #
  # _options_ may contain the following keys:
  # <tt>:user_agent_alias</tt>:: The User-Agent Alias to use.
  # <tt>:user_agent</tt>:: The User-Agent string to use.
  # <tt>:proxy</tt>:: A +Hash+ of proxy information which may
  #                   contain the following keys:
  #                   <tt>:host</tt>:: The proxy host.
  #                   <tt>:port</tt>:: The proxy port.
  #                   <tt>:user</tt>:: The user-name to login as.
  #                   <tt>:password</tt>:: The password to login with.
  #
  #   Shodan.web_agent
  #
  #   Shodan.web_agent(:user_agent_alias => 'Linux Mozilla')
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

  def Shodan.query(options={},&block)
    Query.new(options,&block)
  end
end
