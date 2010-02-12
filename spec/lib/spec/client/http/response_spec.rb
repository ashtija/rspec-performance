require "#{File.dirname(__FILE__)}/../../../../spec_helper"

describe Spec::Client::Http::Response do
  describe "#cookies" do
    attr_reader :response
    before do
      @response = Spec::Client::Http::Response.new
      response.headers = { "Set-Cookie" => ["foo=bar", "baz=bang; domain=.example.com"] }
    end

    def assert_cookies_equal(actual, expected)
      actual.name.should == expected.name
      actual.value.should == expected.value
      actual.domain.should == expected.domain
      actual.path.should == expected.path
      actual.expires.should == expected.expires
    end

    it "returns an array of Spec::Client::Http::Cookies" do
      response.cookies.size.should == 2
      assert_cookies_equal(response.cookies.first, Spec::Client::Http::Cookie.parse("foo=bar"))
      assert_cookies_equal(response.cookies.last, Spec::Client::Http::Cookie.parse("baz=bang; domain=.example.com"))
    end
  end
end