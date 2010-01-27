require "#{File.dirname(__FILE__)}/../../../../spec_helper"

describe Spec::Performance::Client::HttpClient do
  before do
    IntegrationServer.start
  end

  after do
    IntegrationServer.kill
  end

  describe "#initialize" do
    it "initializes the cookie jar" do
    end
  end

  describe "#post" do
    attr_reader :uri, :params
    before do
      @uri = URI.parse(File.join(IntegrationServer.base_url, "hello"))
      @params = { :foo => "bar", :baz => "quux" }
    end

    it "makes an HTTP post" do
      # sends the cookies that have been recorded
      # sends the current headers
      # sends the params that we specified

      client = Spec::Performance::Client::HttpClient.new
      mock.proxy(Net::HTTP).post_form(uri, params)
      client.post(uri, params)
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
