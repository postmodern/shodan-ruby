require 'shodan/page'

require 'spec_helper'

describe Page do
  before(:all) do
    @host_one = Host.new('127.0.0.1','16.11.2009','SSH-2.0-OpenSSH_4.2')
    @host_two = Host.new('192.168.1.1','06.11.2009','SSH-2.0-Sun_SSH_1.1','lol.cats.net')

    @page = Page.new([@host_one, @host_two])
  end

  it "should map the Page to an Array" do
    @page.map { |host| host.ip }.should == [
      '127.0.0.1',
      '192.168.1.1'
    ]
  end

  it "should select hosts from the Page into another Page" do
    @page.select { |host| true }.class.should == Page
  end

  it "should allow the enumeration of the IP addresses of hosts" do
    ips = []

    @page.each_ip do |ip|
      ips << ip
    end

    ips.should == ['127.0.0.1', '192.168.1.1']
  end

  it "should select hosts based on their IP address" do
    @page.hosts_with_ip('127.0.0.1').should == [@host_one]
  end

  it "should provide the IP addresses of hosts" do
    @page.ips.should == ['127.0.0.1', '192.168.1.1']
  end

  it "should allow the enumerations of hostnames" do
    names = []

    @page.each_hostname { |name| names << name }

    names.should == ['lol.cats.net']
  end

  it "should select hosts based on their hostname" do
    @page.hosts_with_name('lol.cats.net').should == [@host_two]
  end

  it "should provide the hostnames" do
    @page.hostnames.should == ['lol.cats.net']
  end

  it "should allow the enumeration of the dates of added hosts" do
    dates = []

    @page.each_date { |date| dates << date }

    dates.should == [@host_one.date, @host_two.date]
  end

  it "should provide the dates hosts were added on" do
    @page.dates.should == [@host_one.date, @host_two.date]
  end

  it "should allow the enumeration of responses" do
    responses = []

    @page.each_response { |resp| responses << resp }

    responses.should == [
      'SSH-2.0-OpenSSH_4.2',
      'SSH-2.0-Sun_SSH_1.1'
    ]
  end

  it "should select the hosts with certain responses" do
    @page.responses_with('Sun').should == [@host_two]
  end

  it "should provide the responses of hosts" do
    @page.responses.should == [
      'SSH-2.0-OpenSSH_4.2',
      'SSH-2.0-Sun_SSH_1.1'
    ]
  end
end
