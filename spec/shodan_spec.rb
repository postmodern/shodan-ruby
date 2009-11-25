require 'shodan/shodan'
require 'shodan/version'

require 'spec_helper'

describe "Shodan" do
  it "should have a VERSION constant" do
    Shodan.const_defined?('VERSION').should == true
  end

  describe "User-Agent support" do
    it "should have a default User-Agent string" do
      Shodan.user_agent.should_not be_nil
    end
  end

  describe "Proxy support" do
    it "should provide a :host key" do
      Shodan.proxy.has_key?(:host).should == true
    end

    it "should provide a :port key" do
      Shodan.proxy.has_key?(:port).should == true
    end

    it "should provide a :user key" do
      Shodan.proxy.has_key?(:user).should == true
    end

    it "should provide a :password key" do
      Shodan.proxy.has_key?(:password).should == true
    end
  end
end
