require "#{File.dirname(__FILE__)}/../../../../spec_helper"

describe Spec::Performance::Example::PerformanceExampleGroup do
  with_sandboxed_options do

    attr_reader :example_group, :fake_run_options, :spec_options
    before do
      @spec_options = { :iterations => 1, :concurrency => 1, :mean_iteration_interval => 1, :iterations_per_second => 1 }
      @example_group = Class.new(Spec::Performance::Example::PerformanceExampleGroup)
      @fake_run_options = ::Spec::Runner::Options.new(StringIO.new, StringIO.new)
      Spec::Performance::Runner::TestReporter.new(fake_run_options)

      fake_run_options.reporter.reset
    end

    it "sets a performance_driver attribute once to an instance of the configured class before running each spec" do
      driver_instance_in_before_block = nil
      driver_instance_in_first_perform_block = nil
      driver_instance_in_second_perform_block = nil

      example_group.before do
        driver_instance_in_before_block = performance_driver
      end

      example_group.perform "some description", spec_options do
        driver_instance_in_first_perform_block = performance_driver
      end

      example_group.perform "some other description", spec_options do
        driver_instance_in_second_perform_block = performance_driver
      end

      example_group.run(fake_run_options)
      fake_run_options.reporter.example_failures.should be_empty

      driver_instance_in_first_perform_block.should be_a(Spec::Performance::Client::HttpClient)
      driver_instance_in_second_perform_block.should be_a(Spec::Performance::Client::HttpClient)
      driver_instance_in_first_perform_block.eql?(driver_instance_in_second_perform_block).should be_false

      # the performance_driver from the before block retains the last value it was set to
      driver_instance_in_before_block.eql?(driver_instance_in_second_perform_block).should be_true
    end
  end
end
