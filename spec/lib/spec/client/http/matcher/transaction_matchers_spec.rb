require "#{File.dirname(__FILE__)}/../../../../../spec_helper"

describe Spec::Client::Http::Matcher::TransactionMatchers do
  attr_reader :transaction, :matcher

  describe "DerivedVerboseHttpMatcher" do
    before do
      class DerivedVerboseHttpMatcher < Spec::Client::Http::Matcher::TransactionMatchers::VerboseHttpMatcher
        def matches?(transaction)
          super(transaction) && true
        end
      end
      # make a transaction for testing
      url = "http://www.example.com"
      params = { "some[param]" => "encode me", "ok" => "done" }
      headers = { "Cookie", "hey=now" }
      driver = Spec::Client::Http::Driver::CurlDriver.new()
      request = Spec::Client::Http::Request.new(url, "GET", params, {})
      @transaction = Spec::Client::Http::Transaction.new(request)
      transaction.execute
      @matcher = DerivedVerboseHttpMatcher.new
      matcher.matches?(transaction)
    end

    describe "#transaction_info" do
      it "returns a string with information about the http transaction" do
        matcher.transaction_info.include?("Request: #{transaction.request.url} using #{transaction.request.request_method}").should be_true
        matcher.transaction_info.include?("  sent headers: #{transaction.request.headers}").should be_true
        matcher.transaction_info.include?("Response code: #{transaction.response.code}").should be_true
        matcher.transaction_info.include?("  with cookies: #{transaction.response.cookies}").should be_true
      end
    end

    describe "#failure_message" do
      it "contains the transaction info" do
        matcher.failure_message.include?(matcher.transaction_info).should be_true
      end
    end

    describe "#negative_failure_message" do
      it "contains the transaction info" do
        matcher.negative_failure_message.include?(matcher.transaction_info).should be_true
      end
    end
  end

  describe "BeRedirect" do
    before do
      # make a transaction for testing
      url = "http://www.example.com"
      params = { "some[param]" => "encode me", "ok" => "done" }
      headers = { "Cookie", "hey=now" }
      driver = Spec::Client::Http::Driver::CurlDriver.new()
      request = Spec::Client::Http::Request.new(url, "GET", params, {})
      @transaction = Spec::Client::Http::Transaction.new(request)
      transaction.execute
      @matcher = Spec::Client::Http::Matcher::TransactionMatchers::BeRedirect.new
      matcher.matches?(transaction)
    end

    describe "#matches?" do
      describe "transaction is a redirect" do
        it "returns true" do
          stub(transaction).redirect? {true}
          matcher.matches?(transaction).should be_true
        end
      end
      describe "transaction is not a redirect" do
        it "returns false" do
          stub(transaction).redirect? {false}
          matcher.matches?(transaction).should be_false
        end
      end
    end

    describe "#failure_message" do
      it "contains the transaction info" do
        matcher.failure_message.include?(matcher.transaction_info).should be_true
      end
    end

    describe "#negative_failure_message" do
      it "contains the transaction info" do
        matcher.negative_failure_message.include?(matcher.transaction_info).should be_true
      end
    end
  end

  describe "BeSuccess" do
    before do
      # make a transaction for testing
      url = "http://www.example.com"
      params = { "some[param]" => "encode me", "ok" => "done" }
      headers = { "Cookie", "hey=now" }
      driver = Spec::Client::Http::Driver::CurlDriver.new()
      request = Spec::Client::Http::Request.new(url, "GET", params, {})
      @transaction = Spec::Client::Http::Transaction.new(request)
      transaction.execute
      @matcher = Spec::Client::Http::Matcher::TransactionMatchers::BeSuccess.new
      matcher.matches?(transaction)
    end

    describe "#matches?" do
      describe "transaction is successful" do
        it "returns true" do
          stub(transaction).success? {true}
          matcher.matches?(transaction).should be_true
        end
      end
      describe "transaction is not successful" do
        it "returns false" do
          stub(transaction).success? {false}
          matcher.matches?(transaction).should be_false
        end
      end
    end

    describe "#failure_message" do
      it "contains the transaction info" do
        matcher.failure_message.include?(matcher.transaction_info).should be_true
      end
    end

    describe "#negative_failure_message" do
      it "contains the transaction info" do
        matcher.negative_failure_message.include?(matcher.transaction_info).should be_true
      end
    end
  end
end
