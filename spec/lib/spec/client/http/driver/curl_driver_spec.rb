require "#{File.dirname(__FILE__)}/../../../../../spec_helper"

describe Spec::Client::Http::Driver::CurlDriver do
  attr_reader :url, :params, :headers, :driver
  before do
    @url = "http://www.example.com"
    @params = { "some[param]" => "encode me", "ok" => "done" }
    @headers = { "Cookie", "hey=now" }
    @driver = Spec::Client::Http::Driver::CurlDriver.new()
  end

  describe "#url_encode_params" do
    describe "when there are params" do
      it "creates a url encoded query string" do
        @driver.url_encode_params(params).should include("some%5Bparam%5D=encode+me")
        @driver.url_encode_params(params).should include("ok=done")
        @driver.url_encode_params(params).should include("&")
      end
    end

    describe "when there are no params" do
      it "returns nil" do
        @driver.url_encode_params({}).should be_nil
      end
    end
  end

  describe "#execute" do
    describe "when the request is a GET" do
      it "makes a get request"
#        mock(Curl::Easy::http_get)
#        driver.execute(url, "GET", headers, params)
    end
    describe "when the request is a POST" do
      it "makes a post request"
    end    
  end
end
