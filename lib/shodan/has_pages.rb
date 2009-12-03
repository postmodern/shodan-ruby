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
  module HasPages
    include Enumerable

    #
    # The first page.
    #
    # @return [Page]
    #   The first page.
    #
    def first_page
      page_cache[1]
    end

    #
    # The page at a given index.
    #
    # @param [Integer] index
    #   The index to request a page for.
    #
    # @return [Page]
    #   The page at the specified index.
    #
    def [](index)
      page_cache[index]
    end

    #
    # The pages at the given indices.
    #
    # @param [Range, Array<Integer>]
    #   The indices to request pages for.
    #
    # @return [Array<Page>]
    #   The pages at the specified indices.
    #
    def pages(indices)
      indices.map { |index| page_cache[index] }
    end

    #
    # Iterates over the pages at given indices.
    #
    # @param [Range, Array<Integer>]
    #   The indices to request pages for.
    #
    # @yield [page]
    #   The given block will be passed each page at one of the specified
    #   indices.
    #
    # @yieldparam [Page] page
    #   The page at one of the specified indices.
    #
    # @return [self]
    #
    def each_page(indices,&block)
      indices.map { |index| block.call(page_cache[index]) }
      return self
    end

    #
    # Iterates over every page, until an empty page is encountered.
    #
    # @yield [page]
    #   The given block will receive every non-empty page.
    #
    # @yieldparam [Page] page
    #   A non-empty page.
    #
    # @return [self]
    #
    def each(&block)
      index = 1

      until ((next_page = page_cache[index]).empty?) do
        block.call(next_page)
        index = index + 1
      end

      return self
    end

    #
    # Iterates over every host.
    #
    # @yield [host]
    #   If a block is given, it will be passed every host from every page.
    #
    # @yieldparam [Host] host
    #   A host.
    #
    # @return [self]
    #
    def each_host(&block)
      each { |page| page.each(&block) }
    end

    #
    # Iterates over the hosts in a page at a given index.
    #
    # @param [Integer] index
    #   The index of the page to iterate over.
    #
    # @yield [host]
    #   If a block is given, it will be passed every host on the page at
    #   the specified index.
    #
    # @yieldparam [Host] host
    #   A host on the page at the specified index.
    #
    def each_on_page(index,&block)
      page_cache[index].each(&block)
    end

    #
    # Iterates over each host on the pages at the given indices.
    #
    # @param [Range, Array<Integer>] indices
    #   The indices of the pages.
    #
    # @yield [host]
    #   If a block is given, it will be passed ever host on the pages
    #   at the specified indices.
    #
    # @yieldparam [Host] host
    #   A host on one of the pages at the specified indices.
    #
    # @return [self]
    #
    def each_on_pages(indices,&block)
      each_page(indices) { |page| page.each(&block) }
    end

    #
    # The first host on the first page.
    #
    # @return [Host]
    #   The first host.
    #
    def first_host
      first_page.first
    end

    #
    # Returns the host at a given index.
    #
    # @param [Integer] index
    #   The index to request the host at.
    #
    # @return [Host]
    #   The host at the given index.
    #
    def host_at(index)
      page(page_index_of(index))[result_index_of(index)]
    end

    protected

    #
    # Calculates the page index for a given result rank.
    #
    # @param [Integer]
    #   The rank of a result within the total results.
    #
    # @return [Integer]
    #   The index of the page that will contain the result, with the
    #   specified rank.
    #
    def page_index_of(rank)
      (((rank.to_i - 1) / results_per_page.to_i) + 1)
    end

    #
    # Calculates the result rank of the first result on the page at the
    # given index.
    #
    # @param [Integer] page_index
    #   The index of a page.
    #
    # @return [Integer]
    #   The rank of the first result on the page, with the specified index.
    #
    def result_offset_of(page_index)
      ((page_index.to_i - 1) * results_per_page.to_i)
    end

    #
    # Calculates the in-page index of a given result rank.
    #
    # @param [Integer] rank
    #   The result rank.
    #
    # @return [Integer]
    #   The index of the result, within the page that will contain the
    #   result.
    #
    def result_index_of(rank)
      ((rank.to_i - 1) % results_per_page.to_i)
    end

    #
    # The page cache.
    #
    # @return [Hash{Integer => Page}]
    #   A persistant Hash of pages.
    #
    def page_cache
      @page_cache ||= Hash.new { |hash,key| hash[key] = page(key.to_i) }
    end
  end
end
