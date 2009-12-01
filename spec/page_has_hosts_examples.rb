require 'shodan/page'

require 'spec_helper'

shared_examples_for "Page has Hosts" do
  it "should have hosts" do
    @page.length.should_not == 0
  end

  it "should have the maximum amount of hosts per page" do
    @page.length.should == @query.results_per_page
  end

  it "should have IP addresses" do
    @page.ips.should_not be_empty
  end

  it "should have valid IP addresses" do
    @page.each_ip do |ip|
      ip =~ /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/
    end
  end

  it "should have dates" do
    @page.dates.should_not be_empty
  end

  it "should have responses" do
    @page.responses.should_not be_empty
  end
end
