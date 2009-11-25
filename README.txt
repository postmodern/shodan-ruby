= shodanrb

* http://github.com/postmodern/shodanrb

== DESCRIPTION:

A Ruby interface to SHODAN, a computer search engine.

== FEATURES/PROBLEMS:

* Supports basic queries.
* Supports +country+ search operator.
* Supports +hostname+ search operator.
* Supports +net+ search operator.
* Supports +port+ search operator.

== EXAMPLES:

* Basic query:

    require 'shodan'

    q = Shodan.query(:query => 'ssh')

* Advanced query:

    q = Shodan.query(:query => 'login') do |q|
      q.ports += [21, 23, 80, 25]
      q.networks << '112.0.0.0/8'
    end

* Queries from URLs:

    q = Shodan::Query.from_url('http://shodan.surtri.com/?q=login+port%3A21+port%3A23')

    q.query
    # => "login port:21 port:23"

* Getting the search results:

    q.first_page.select do |host|
      host.response =~ /HTTP\1.[01] 200/
    end

    q.page(2).map do |host|
      host.headers['Server']
    end

    q.result_at(21)

    q.top_result

* A Host object contains the IP address, Date added, Hostname, Response
  recorded and parsed HTTP version, HTTP code, HTTP status
  and HTTP headers.

    page = q.page(2)

    page.ips #=> [...]
    page.hostnames => [...]
    page.dates => [...]
    page.responses => [...]
    page.http_versions => [...]
    page.http_codes => [...]
    page.http_statuses=> [...]
    page.http_headers => [...]

* Iterating over the search results:

    q.each_on_page(2) do |host|
      puts host.ip
    end

    page.each do |host|
      puts "#{host.date} #{host.ip}"
    end

== REQUIREMENTS:

* {mechanize}[http://mechanize.rubyforge.org] >= 0.9.3

== INSTALL:

  $ sudo gem install shodanrb

== LICENSE:

shodanrb - A Ruby interface to SHODAN, a computer search engine.

Copyright (c) 2009 Hal Brodigan (postmodern.mod3 at gmail.com)

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
