require "#{File.dirname(__FILE__)}/../../../../spec_helper"

describe Spec::Performance::Client::HttpClient do
  attr_reader :client

  before do
    IntegrationServer.start
    @client = Spec::Performance::Client::HttpClient.new("http://localhost")
  end

  after do
    IntegrationServer.kill
  end

  describe "#initialize" do
    it "initializes the cookie jar" do
      client.cookies.should be_a(Hash)
    end
  end

  describe "#post" do
    attr_reader :uri, :params
    before do
      @uri = URI.join(IntegrationServer.base_url, "hello")
      @params = { :foo => "bar", :baz => "quux" }
    end

    it "makes an HTTP post" do
      mock.instance_of(Net::HTTP).request(anything) do |request|
        request.should be_a(Net::HTTP::Post)
        stub(Net::HTTPResponse.new(1.1, 200, nil)).body { "stubbed response body" }        
      end
      client.post(uri, params).should be_success
    end

    it "returns a response object" do
      client.post(uri, params).should be_a(Spec::Performance::Client::Response)
    end

    describe "when the client is recording" do
      before do
        @uri = URI.join(IntegrationServer.base_url, "cookie_echo")
        client.should be_recording
      end

      it "captures the cookie from the response" do
        client.post(uri, params).should be_success
        client.cookies[:foo].value.first.should == "bar"
        client.cookies[:baz].value.first.should == "quux"
      end
    end

    describe "when the client is not recording" do
      before do
        @uri = URI.join(IntegrationServer.base_url, "cookie_echo")
        client.recording = false
        client.should_not be_recording
      end

      it "does not capture cookies" do
        client.post(uri, params).should be_success
        client.cookies.should_not have_key(:foo)
        client.cookies.should_not have_key(:baz)
      end
    end
  end

  describe "#get" do
    attr_reader :uri, :params
    before do
      @params = { :monster_truck => "Truckasaurus", :us_president => "Grover Cleveland" }
      @uri = URI.join(IntegrationServer.base_url, "hello")
    end

    it "sends an HTTP get request, sending the current cookies" do
      expected_cookie  = CGI::Cookie.new("cookie-name", "cookie-value")
      expected_headers = { "Cookie" => expected_cookie.to_s }
      client.cookies   = { "cookie-name".to_sym => expected_cookie }

      mock_http = Object.new
      mock(Net::HTTP).start("localhost", 8888) { mock_http }
      mock(mock_http).get(anything, expected_headers) do |request_uri, headers|
        request_uri.index("/hello?").should == 0
        request_uri.should include("monster_truck=Truckasaurus")
        request_uri.should include("us_president=Grover+Cleveland")
        request_uri.should include("&")

        stub(Net::HTTPResponse.new(1.1, 200, nil)).body { "stubbed response body" }
      end
      mock(mock_http).finish

      response = client.get(uri, params)
    end

    it "returns a response object" do
      response = client.get(uri, params)
      response.should be_a(Spec::Performance::Client::Response)
      response.should be_success
    end

    describe "when the client is recording" do
      it "captures the cookie from the response" do
      end
    end

    describe "when the client is not recording" do
      it "does not capture" do
      end
    end
  end

  describe "#restore" do
    it "resets after each run" do
    end
  end

end
