require "#{File.dirname(__FILE__)}/../../../../spec_helper"

describe Spec::Client::Http::Request do
  attr_reader :url, :params, :headers, :request
  before do
    @url = "http://www.example.com"
    @params = { "some[param]" => "encode me", "ok" => "done" }
    @headers = { "Cookie", "hey=now" }
    @request = Spec::Client::Http::Request.new(url, params, headers)
  end

  describe "#initialize" do
    it "populates the readers" do
      request.url == url
      request.params == params
      request.headers == headers
    end
  end

  describe "#url_encode_params" do
    describe "when there are params" do
      it "creates a url encoded query string" do
        request.url_encode_params.should include("some%5Bparam%5D=encode+me")
        request.url_encode_params.should include("ok=done")
        request.url_encode_params.should include("&")
      end
    end

    describe "when there are no params" do
      it "returns nil" do
        request = Spec::Client::Http::Request.new(url, {}, headers)
        request.url_encode_params.should be_nil
      end
    end
  end

  describe "#execute" do
    it "makes an http request via the driver mixin" do
      mock(request).driver_execute(url, "GET", headers, params)
      response = request.execute
    end
  end

  describe "#execute_http_driver_request" do
    it "raises a NotImplementedError" do
      lambda { request.driver_execute }.should raise_error(NotImplementedError)
    end
  end
end