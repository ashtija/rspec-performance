require "#{File.dirname(__FILE__)}/../../../../spec_helper"

describe Spec::Client::Http::Session do
  class TestClient
    def intialize
    end

    def get(url, params = {})
    end

    def post(url, params = {})
    end
  end

  class TestRequest < Spec::Client::Http::Request
    def driver_execute(url,method,headers,params)
      Spec::Client::Http::Response.new(url)
    end
  end

  attr_reader :client
  before do
    @client = TestClient.new
  end

  describe "#intialize" do
    it "creates a new cookie jar" do
      session = Spec::Client::Http::Session.new(client)
      session.client.should == client
      session.cookie_jar.should be_a(Mechanize::CookieJar)
    end
  end

  describe "#get" do
    it "calls execute with a new get request" do
      session = Spec::Client::Http::Session.new(client)
      mock(session).execute(anything) do |request|
        request.should be_a(Spec::Client::Http::Request)
        request.request_method.should == "GET"
      end

      session.get("http://127.0.0.1", {})
    end
  end

  describe "#post" do
    it "calls execute with a new post request" do
      session = Spec::Client::Http::Session.new(client)
      mock(session).execute(anything) do |request|
        request.should be_a(Spec::Client::Http::Request)
        request.request_method.should == "POST"        
      end
      session.post("http://127.0.0.1", {})
    end
  end

  describe "#execute" do
    it "makes a request and returns the Transaction" do
#      mock.instance_of(Spec::Client::Http::Transaction).execute
      session = Spec::Client::Http::Session.new(client)
      transaction = session.execute(TestRequest.new("http://127.0.0.1/", "GET", {}, {}))
    end
  end
end
