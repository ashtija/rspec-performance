require "#{File.dirname(__FILE__)}/../../../../spec_helper"

describe Spec::Performance::Example::PerformanceExampleGroupMethods do
  with_sandboxed_options do
    attr_reader :example_group, :fake_run_options
    before do
      @example_group = Class.new(Spec::Performance::Example::PerformanceExampleGroup)
      @fake_run_options = ::Spec::Runner::Options.new(StringIO.new, StringIO.new)
      Spec::Performance::Runner::TestReporter.new(fake_run_options)
    end

    describe ".perform" do
      context "configuration options" do
        attr_reader :configured_options
        before do
          @configured_options = Spec::Performance::Configuration.configured_options
        end

        it "uses the global configuration options" do
          mock(example_group).example(anything, configured_options, anything)
          example_group.perform("do something") {}
        end

        describe "when options are passed on a per test level" do
          attr_reader :spec_options, :expected_options
          before do
            @spec_options = { :concurrency => 100, :iterations => 200 }
            @expected_options = configured_options.merge(spec_options)
          end

          it "overrides the global configuration options" do
            mock(example_group).example(anything, expected_options, anything)
            example_group.perform("do something", spec_options) {}
          end
        end
      end

      context "behavior" do
        attr_reader :spec_options
        before do
          @spec_options = { :concurrency => 2, :iterations => 10, :iterations_per_second => nil, :mean_iteration_iterval => nil }
        end

        it "runs the performance loop runs N times where N is equal to iterations divided by concurrency" do
          expected_call_count = spec_options[:iterations] / spec_options[:concurrency]

          call_count = 0
          example_group.perform "do performance loop", spec_options do
            call_count += 1
          end
          example_group.run(fake_run_options)
          call_count.should == expected_call_count
        end

        it "executes the performance loop in the same context as the other examples" do
          example_group.before do
            @scope = self
            @foo = "bar"
          end

          executed = false
          example_group.perform "do performance loop", spec_options.merge(:iterations => 1, :concurrency => 1) do
            (@scope == self).should be_true
            @foo.should == "bar"
            executed = true
          end

          example_group.run(fake_run_options)

          @scope.should be_nil
          @foo.should_not == "bar"
          executed.should be_true
        end
      end

      context "pass or fail reporting" do
        describe "when the spec should fail" do
          attr_reader :spec_options
          before do
            @spec_options = { :concurrency => 1, :iterations => 2, :iterations_per_second => nil, :mean_iteration_iterval => nil }
          end

          # TODO: Use :rr stubbing - BR/HM
#          def stub_timed_operation_1(example_group)
#            class Spec::Performance::Example::PerformanceExecutionBuilder
#              def _timed_operation(label, &block)
#                1.0
#              end
#            end
#          end

          def stub_timed_operation_2(example_group)
            example_group.class_eval do
              def _timed_operation(label, &block)
                yield
                label == Spec::Performance::Example::PerformanceExampleGroupMethods::ITERATION_RUN_TIME_LABEL ? 0.2 : 1.0
              end
            end
          end

          describe "when the iterations_per_second configuration option is set" do
            before do
              spec_options.merge!({ :iterations_per_second => 3 })
            end

            it "fails when it does not match on iterations per second" do
#              stub_timed_operation_1(example_group)
              stub.instance_of(Spec::Performance::Example::PerformanceExecutionBuilder)._timed_operation { puts "called it"; 1.0 }

              example_group.perform("do performance loop", spec_options) {}
              example_group.run(fake_run_options)

              fake_run_options.reporter.example_failures.should_not be_empty
              error = fake_run_options.reporter.example_failures.first[:error]
              error.should be_a(Spec::Expectations::ExpectationNotMetError)
            end
          end

          describe "when the mean_iteration_interval configuration option is set" do
            before do
              spec_options.merge!({ :iterations => 5, :mean_iteration_interval => 0.100 })
            end

            it "fails when the mean_iteration_interval falls below the configured value" do
              stub_timed_operation_2(example_group)

              example_group.perform("do performance loop", spec_options) {}
              example_group.run(fake_run_options)

              fake_run_options.reporter.example_failures.should_not be_empty
              error = fake_run_options.reporter.example_failures.first[:error]
              error.should be_a(Spec::Expectations::ExpectationNotMetError)
            end
          end
        end
      end
    end

    describe ".calculate_average" do
      attr_reader :sample, :expected_average, :current_average
      before do
        @sample = [3, 3, 5, 7]
        @expected_average = (sample.inject(0.0) {|acc, x| acc += x; acc } + 7) / (sample.size + 1)
        expected_average.should == 5

        @current_average = sample.inject(0.0) {|acc, x| acc += x; acc } / sample.size
      end

      it "calculates averages correctly" do
        example = example_group.new(fake_run_options)
        example.send(:_calculate_average, sample.size, current_average, 7).should == expected_average
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
        example = example_group.new(fake_run_options)
        elapsed_time = example.send(:_timed_operation, "foo") {}
        elapsed_time.should be_a(Float)
        elapsed_time.should == 1.0
      end
    end
  end
end

