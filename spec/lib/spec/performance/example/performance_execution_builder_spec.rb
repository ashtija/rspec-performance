require "#{File.dirname(__FILE__)}/../../../../spec_helper"
require "spec/performance/example/performance_execution_builder"

describe Spec::Performance::Example::PerformanceExecutionBuilder do
  attr_reader :spec_options
  with_sandboxed_options do

    describe ".performance_proc" do
      context "performance loop" do
        before do
          @spec_options = { :concurrency => 2, :iterations => 10, :iterations_per_second => nil, :mean_iteration_iterval => nil }
        end

        it "runs the performance loop N times where N is equal to iterations divided by concurrency" do
          call_count = 0
          expected_call_count = spec_options[:iterations] / spec_options[:concurrency]

          builder = Spec::Performance::Example::PerformanceExecutionBuilder.new(spec_options) { call_count += 1 }
          builder.performance_proc.call

          call_count.should == expected_call_count
        end

        it "extends the ExampleGroup prior to test execution" do
          builder = Spec::Performance::Example::PerformanceExecutionBuilder.new(spec_options) {}
          mock(Spec::Performance::Example::PerformanceExecutionBuilder::PerformanceHelpers).extended(builder) {}
          builder.performance_proc.call
        end
      end

      context "extended tests" do
        describe "when the spec should fail" do
          attr_reader :builder

          before do
            @spec_options = { :concurrency => 1, :iterations => 2, :iterations_per_second => nil, :mean_iteration_iterval => nil }
          end

          describe "when the iterations_per_second configuration option is set" do
            before do
              spec_options.merge!({ :iterations_per_second => 3 })
              @builder = Spec::Performance::Example::PerformanceExecutionBuilder.new(spec_options)
            end

            it "fails when it does not match on iterations per second" do
              stub(builder)._timed_operation(Spec::Performance::Example::PerformanceExecutionBuilder::EXAMPLE_RUN_TIME_LABEL) { 1.0 }

              lambda do
                builder.performance_proc.call
              end.should raise_error(Spec::Expectations::ExpectationNotMetError)
            end
          end

          describe "when the mean_iteration_interval configuration option is set" do
            before do
              spec_options.merge!({ :iterations => 5, :mean_iteration_interval => 0.100 })
              @builder = Spec::Performance::Example::PerformanceExecutionBuilder.new(spec_options)
            end

            def create_stub_impl
              lambda do |args, block|
                label = Spec::VERSION::MAJOR == 1 && Spec::VERSION::MINOR > 2 ? args.first : args
                return 0.2 if label == Spec::Performance::Example::PerformanceExecutionBuilder::ITERATION_RUN_TIME_LABEL
                block.call
                1.0
              end
            end

            it "fails when the mean_iteration_interval falls below the configured value" do
              stub(builder)._timed_operation(anything, &create_stub_impl)

              lambda do
                builder.performance_proc.call
              end.should raise_error(Spec::Expectations::ExpectationNotMetError)
            end
          end
        end
      end
    end

    describe Spec::Performance::Example::PerformanceExecutionBuilder::PerformanceHelpers do
      attr_reader :helper_instance
      before do
        @helper_instance = Class.new do
          include Spec::Performance::Example::PerformanceExecutionBuilder::PerformanceHelpers
        end.new
      end

      describe ".calculate_average" do
        attr_reader :sample, :expected_average, :current_average
        before do
          @sample = [3, 3, 5, 7]
          @expected_average = (sample.sum + 7) / (sample.size + 1)
          expected_average.should == 5

          @current_average = sample.sum / sample.size
        end

        it "calculates averages correctly" do
          helper_instance.send(:_calculate_average, sample.size, current_average, 7).should == expected_average
        end
      end

      describe ".timed_operation" do
        before do
          called = 0
          stub(Time).now do
            return_value = called > 0 ? 1 : 0
            called += 1
            return_value
          end
        end

        it "returns the elapsed time of execution for a block" do
          elapsed_time = helper_instance.send(:_timed_operation, "foo") {}
          elapsed_time.should be_a(Float)
          elapsed_time.should == 1.0
        end
      end
    end
  end
end
