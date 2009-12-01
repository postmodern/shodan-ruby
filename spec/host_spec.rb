require 'shodan/host'

require 'spec_helper'

describe Host do
  describe "non-HTTP host" do
    before(:all) do
      @host = Host.new('127.0.0.1','16.11.2009','SSH-2.0-OpenSSH_4.2')
    end

    it "should parse the date" do
      @host.date.class.should == Date
    end

    it "should not have a HTTP version" do
      @host.http_version.should be_nil
    end

    it "should not have a HTTP status code" do
      @host.http_code.should be_nil
    end

    it "should not have a HTTP status message" do
      @host.http_status.should be_nil
    end

    it "should not have HTTP response headers" do
      @host.http_headers.should == {}
    end

    it "should not have a HTTP response body" do
      @host.http_body.should be_nil
    end
  end

  describe "HTTP host" do
    before(:all) do
      @host = Host.new(
        '127.0.0.1',
        '16.11.2009',
        %{
HTTP/1.0 200 OK
X-powered-by: PHP/5.3.0
Transfer-encoding: chunked
X-gpg-key: http://chrislea.com/gpgkey.txt http://chrislea.com/gpgkey-virb.txt
Vary: Cookie
X-ssh-key: http://chrislea.com/sshkey.txt
Server: nginx/0.8.24
Connection: keep-alive
Date: Fri, 20 Nov 2009 00:52:24 GMT
X-the-question: Quis custodiet ipsos custodes?
Content-type: text/html; charset=UTF-8
X-pingback: http://chrislea.com/xmlrpc.php

<HTML>
</HTML>
      }.strip
      )
    end

    it "should parse the date" do
      @host.date.class.should == Date
    end

    it "should not have a HTTP version" do
      @host.http_version.should == '1.0'
    end

    it "should not have a HTTP status code" do
      @host.http_code.should == 200
    end

    it "should not have a HTTP status message" do
      @host.http_status.should == 'OK'
    end

    it "should not have HTTP response headers" do
      @host.http_headers.should == {
        'X-powered-by' => 'PHP/5.3.0',
        'Transfer-encoding' => 'chunked',
        'X-gpg-key' => 'http://chrislea.com/gpgkey.txt http://chrislea.com/gpgkey-virb.txt',
        'Vary' => 'Cookie',
        'X-ssh-key' => 'http://chrislea.com/sshkey.txt',
        'Server' => 'nginx/0.8.24',
        'Connection' => 'keep-alive',
        'Date' => 'Fri, 20 Nov 2009 00:52:24 GMT',
        'X-the-question' => 'Quis custodiet ipsos custodes?',
        'Content-type' => 'text/html; charset=UTF-8',
        'X-pingback' => 'http://chrislea.com/xmlrpc.php'
      }
    end

    it "should provide a server name" do
      @host.server_name.should == 'nginx'
    end

    it "should provide a server version" do
      @host.server_version.should == '0.8.24'
    end

    it "should provide transparent access to the HTTP response headers" do
      @host.x_the_question.should == 'Quis custodiet ipsos custodes?'
    end

    it "should raise a NoMethodError when accessing missing headers" do
      lambda {
        @host.lol
      }.should raise_error(NoMethodError)
    end

    it "should not have a HTTP response body" do
      @host.http_body.should == "<HTML>\n</HTML>"
    end
  end
end
