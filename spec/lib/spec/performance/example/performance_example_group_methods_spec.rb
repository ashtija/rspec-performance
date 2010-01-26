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
        attr_reader :spec_options
        before do
          @spec_options = { :concurrency => 1, :iterations => 2, :iterations_per_second => 3, :mean_iteration_iterval => nil }
        end

        it "fails when it does not match on iterations per second" do
          # TODO: Use :rr stubbing - BR/HM
          example_group.instance_eval do
            def timed_operation(label, &block)
              1.0
            end
          end
          example_group.timed_operation("FOO") {}.should == 1.0

          example_group.perform("do performance loop", spec_options) {}
          example_group.run(fake_run_options)

          fake_run_options.reporter.example_failures.should_not be_empty
        end
      end


#    it "fails when the mean iteration execution time does not land at or below the configured maximum mean iteration execution time"

    end

    describe ".calculate_average" do
      attr_reader :sample, :expected_average, :current_average
      before do
        @sample = [3, 3, 5, 7]
        @expected_average = (sample.inject(0.0) {|acc, x| acc += x; acc } + 7) / (sample.size + 1)
        expected_average.should == 5

        @current_average = sample.inject(0.0) {|acc, x| acc += x; acc } / sample.size
      end

      it "should calculate average correctly" do
        example_group.calculate_average(sample.size, current_average, 7).should == expected_average
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
        elapsed_time = example_group.timed_operation("foo") {}
        elapsed_time.should be_a(Float)
        elapsed_time.should == 1.0
      end
    end
  end
end