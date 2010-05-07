require "#{File.dirname(__FILE__)}/../../../../spec_helper"

describe Spec::Client::Http::Transaction do
  attr_reader :request, :response
  before do
    @request = Spec::Client::Http::Request.new("http://example.com", "GET", {}, {})
    @response = Spec::Client::Http::Response.new(@request.url)
  end

  describe "#execute" do
    it "executes the request and sets the response" do
      mock(request).execute { "foo" }

      transaction = Spec::Client::Http::Transaction.new(request)
      transaction.execute.should == transaction
      transaction.response.should == "foo"
    end
  end

  describe "#success?" do
    describe "when the response code is an http success code" do
      before do
        response.code = 201
        mock(request).execute { response }
      end

      it "returns true" do
        transaction = Spec::Client::Http::Transaction.new(request)
        transaction.execute
        transaction.should be_success
      end
    end

    describe "when the response code is NOT an http success code" do
      before do
        response.code = 300
        mock(request).execute { response }
      end

      it "returns false" do
        transaction = Spec::Client::Http::Transaction.new(request)
        transaction.execute
        transaction.should_not be_success
      end
    end
  end

  describe "#redirect?" do
     describe "when the response code is an http redirect code" do
      before do
        response.code = 302
        mock(request).execute { response }
      end

      it "returns true" do
        transaction = Spec::Client::Http::Transaction.new(request)
        transaction.execute
        transaction.should be_redirect
      end
    end

    describe "when the response code is NOT an http redirect code" do
      before do
        response.code = 400
        mock(request).execute { response }
      end

      it "returns false" do
        transaction = Spec::Client::Http::Transaction.new(request)
        transaction.execute
        transaction.should_not be_redirect
      end
    end

  end
end
