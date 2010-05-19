require "#{File.dirname(__FILE__)}/../../../spec_helper"

describe Spec::Client::HttpClient do

  describe "#full_url" do
    it "creates a full url from base_uri and a path" do
      full_url = Spec::Client::HttpClient.new("http://example.com").full_url("foo")
      full_url.should == "http://example.com/foo"
    end
  end

  describe "#new_session" do
    it "empties cookies" do
      client = Spec::Client::HttpClient.new("http://example.com")
      client.session.cookie_jar.add(URI::parse("http://example.com"),Mechanize::Cookie::parse(URI::parse("http://example.com"), "foo=bar") {|c| c}.first)
      client.session.cookie_jar.cookies(URI::parse("http://example.com")).should_not be_empty
      client.new_session()
      client.session.cookie_jar.cookies(URI::parse("http://example.com")).should be_empty
    end
  end
end
