require "#{File.dirname(__FILE__)}/../../../../spec_helper"

describe Spec::Client::Http::Response do
  describe "#cookies" do
    attr_reader :response
    before do
      @response = Spec::Client::Http::Response.new("http://www.example.com")
      response.headers = { "Set-Cookie" => ["foo=bar", "baz=bang; domain=.example.com"] }
    end

    def assert_cookies_equal(actual, expected)
      actual.name.should == expected.name
      actual.value.should == expected.value
      actual.domain.should == expected.domain
      actual.path.should == expected.path
      actual.expires.should == expected.expires
    end

    it "returns an array of cookies" do
      response.cookies.size.should == 2
      assert_cookies_equal(response.cookies.first, Mechanize::Cookie::parse(URI::parse("http://www.example.com"), "foo=bar") {|c| c}.first)
      assert_cookies_equal(response.cookies.last, Mechanize::Cookie::parse(URI::parse("http://www.example.com"), "baz=bang; domain=.example.com"){|c| c}.first)
    end
  end
end
