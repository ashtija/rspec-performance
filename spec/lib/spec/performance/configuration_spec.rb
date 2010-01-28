require "#{File.dirname(__FILE__)}/../../../spec_helper"

describe Spec::Performance::Configuration do
  describe ".default_options" do
    it "has correct configuration keys" do
      options = Spec::Performance::Configuration.default_options
      options.has_key?(:concurrency)
      options.has_key?(:iterations)
      options.has_key?(:iterations_per_second)
      options.has_key?(:mean_iteration_iterval)
      options.has_key?(:performance_driver_class)
    end
  end

  describe ".configure" do
    it "sets a the options of Configuration singleton" do
      Spec::Performance::Configuration.configure do |config|
        config.concurrency = 10000
        config.iterations_per_second = 20000
      end

      default_options = Spec::Performance::Configuration.default_options
      configured_options = Spec::Performance::Configuration.instance.options
      configured_options[:concurrency].should == 10000
      configured_options[:iterations_per_second].should == 20000
      configured_options[:mean_iteration_iterval].should == default_options[:mean_iteration_iterval]
      configured_options[:iterations].should == default_options[:iterations]
      configured_options[:performance_driver_class].should == default_options[:performance_driver_class]
    end
  end

  describe ".configured_options" do
    it "returns the configured options" do
      Spec::Performance::Configuration.instance.options.should == Spec::Performance::Configuration.configured_options
    end
  end
end
