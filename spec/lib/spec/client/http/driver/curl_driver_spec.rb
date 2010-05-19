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
      it "makes a get request" do
        curler = mock(Curl::Easy.new(@url))
        stub(Curl::Easy).new {curler}
        curler.http_get
        driver.execute(url, "GET", headers, params)
      end
    end
    describe "when the request is a POST" do
      it "makes a post request" do
        curler = mock(Curl::Easy.new(@url))
        stub(Curl::Easy).new {curler}
        curler.http_post(anything)
        driver.execute(url, "POST", headers, params)
      end
    end    
  end
end
