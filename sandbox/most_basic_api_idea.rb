Spec::Performance::Configuration.configure do |conf|
  conf.driver = GrockitHttpClient
  conf.max_acceptable_iteration_time = 1.second
#  conf.mean_iteration_interval = 1
  conf.iterations = 20
end

describe "app_server - more involved setup - non-reentrant page request" do
  before do
    response = driver.post "http://localhost/login", "username", "password"
    response.should be_success
  end

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
      # driver.restore - this restores the drivers last known state
    end

    perform "correct credit cards" do
      response = driver.post "http://localhost/orders", :valid_order_params
      response.should be_success
    end

    perform "clean slate" do
      driver
    end
  end
end
