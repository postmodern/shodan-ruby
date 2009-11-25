require 'shodan/query'

require 'spec_helper'
require 'has_pages_examples'

describe Query do
  before(:all) do
    @query = Query.new(:query => 'ssh')
    @page = @query.first_page
  end

  it_should_behave_like "has Pages"

  describe "query expression" do
    it "should support basic queries" do
      q = Query.new(:query => 'ssh')

      q.expression.should == 'ssh'
    end

    it "should support the country search operator" do
      q = Query.new(
        :query => 'ssh', :countries => [
          Countries::Mexico,
          Countries::Nicaragua
        ]
      )

      q.expression.should == 'ssh country:MX country:NI'
    end

    it "should support host search operator" do
      q = Query.new(
        :query => 'http',
        :hostnames => ['www.wired.com']
      )

      q.expression.should == 'http hostname:www.wired.com'
    end

    it "should support the net search operator" do
      q = Query.new(
        :query => 'ssh',
        :networks => ['112.0.0.0/8']
      )

      q.expression.should == 'ssh net:112.0.0.0/8'
    end

    it "should support the port search operator" do
      q = Query.new(
        :query => 'login',
        :ports => [21, 23]
      )

      q.expression.should == 'login port:21 port:23'
    end
  end

  describe "search URL" do
    before(:all) do
      @uri = @query.search_url
    end

    it "should be a valid HTTP URI" do
      @uri.class.should == URI::HTTP
    end

    it "should have a 'q' query-param" do
      @uri.query_params['q'].should == @query.query
    end
  end

  describe "page specific URLs" do
    before(:all) do
      @uri = @query.page_url(2)
    end

    it "should have a 'page' query-param" do
      @uri.query_params['page'].should == 2
    end
  end

  describe "queries from search URLs" do
    before(:all) do
      @query = Query.from_url("http://shodan.surtri.com/?q=login+port%3A21+port%3A23")
    end

    it "should have a query" do
      @query.query.should == 'login port:21 port:23'
    end
  end
end
