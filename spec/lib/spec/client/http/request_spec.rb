require "#{File.dirname(__FILE__)}/../../../../spec_helper"

describe Spec::Client::Http::Request do
  attr_reader :url, :params, :headers, :request
  before do
    @url = "http://www.example.com"
    @params = { "some[param]" => "encode me", "ok" => "done" }
    @headers = { "Cookie", "hey=now" }
    @request = Spec::Client::Http::Request.new(url, "GET", params, headers)
  end

  describe "#initialize" do
    it "populates the readers" do
      request.url == url
      request.params == params
      request.headers == headers
    end
  end

  describe "#execute" do
    it "makes an http request via the driver" do
      mock(request).driver_execute(url, "GET", headers, params)
      response = request.execute
    end
  end
end
