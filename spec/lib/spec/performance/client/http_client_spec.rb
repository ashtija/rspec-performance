require "#{File.dirname(__FILE__)}/../../../../spec_helper"

describe Spec::Performance::Client::HttpClient do
  attr_reader :client

  before do
    IntegrationServer.start
    @client = Spec::Performance::Client::HttpClient.new
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
      @uri = URI.parse(File.join(IntegrationServer.base_url, "hello"))
      @params = { :foo => "bar", :baz => "quux" }
    end

    it "makes an HTTP post" do
      mock.proxy(Net::HTTP).post_form(uri, params)
      client.post(uri, params).should be_success
    end

    it "returns a response object" do
      client.post(uri, params).should be_a(Spec::Performance::Client::Response)
    end

    describe "when the client is recording" do
      before do
        @uri = URI.parse(File.join(IntegrationServer.base_url, "cookie_echo"))
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
        @uri = URI.parse(File.join(IntegrationServer.base_url, "cookie_echo"))
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
    before do
      @params = {}
    end

    it "makes an HTTP get" do
      # sends the cookies that have been recorded
      # sends the current headers
      # sends the params that we specified
    end

    it "returns a response object" do
    end

    describe "when the client is recording" do
      it "captures the cookie from the response" do
      end
    end

    describe "when the client is not recording" do
      it "it does not capture" do
      end
    end
  end

  describe "#restore" do
    it "resets after each run" do
    end
  end

end
