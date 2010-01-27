require "rubygems"
require "rspec-performance"

describe "unit test" do
  perform "basic" do

  end
end

class PerformanceHttpClient
  def initialize
    @cookies = {}
    @headers = {}
  end

  def get;
  end

  def post(url, params)
  end
end

class CometPerformanceClient < PerformanceHttpClient
  def connect
  end

  def subscribe
  end

  def publish
  end

  def unsubscribe
  end

  def disconnect
  end
end

class GrockitPerformanceClient < CometPerformanceClient
  def login_as(username, password)
    response = post("http://localhost/login", :username => username, :password => password)
    response.should be_success
  end
end

Spec::Performance::Configuration.configure |conf|
  conf.driver = GrockitHttpClient
  conf.mean_iteration_interval = 1
end

describe "app_server - basic page request - reentrant page request" do
  before do
    driver.login_as "bob", "password"
  end

  perform "a basic single page load test" do
    driver.get "http://localhost/dashboard"
  end

  perform "a concurrent single page load test", :concurrency => 2 do
    driver.get "http://localhost/dashboard"
  end
end

describe "app_server - more involved setup - non-reentrant page request" do
  describe "when the order params are correct" do
    attr_reader :valid_order_params
    before do
      @valid_order_params = { :credit_card => 4111111111111111, :full_name => "Bob Bing Bong", :ccv => 123 }
      driver.login_as "bob", "password"

      # If this is mixed in with rspec-rails, can we use actual rails paths created from the router?
      driver.order_new_path
    end

    # Time to run this should not count against example_run_time
    after_iteration do
      order_id = driver.find_order_id
      Order.destroy! order_id
    end

    perform "correct credit cards", :concurrency => 2 do
      driver.post "http://localhost/orders"
    end
  end
end

describe "game_server - basic game operation" do
  before do
  end

  # Interface 1
  perform "answering a question with multiple users" do
    concurrently do
      as "bob" do
      end

      as "bill" do
      end
    end
  end

  # Interface 2
  concurrently "answering a question with multiple users" do
    as "bob" do
    end

    as "bill" do
    end
  end
end