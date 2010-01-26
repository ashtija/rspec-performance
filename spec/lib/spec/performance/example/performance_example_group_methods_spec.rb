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

      context "execution context" do
        attr_reader :spec_options
        before do
          @spec_options = { :concurrency => 2, :iterations => 10, :iterations_per_second => nil, :mean_iteration_iterval => nil }
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

      context "reporting" do
        describe "when a performance test assertion fails" do
          it "reports the failure" do
            example_group.perform("do something") { 1.should == 0 }
            example_group.run(fake_run_options)

            fake_run_options.reporter.example_successes.should be_empty
            fake_run_options.reporter.example_failures.should_not be_empty
            error = fake_run_options.reporter.example_failures.first[:error]
            error.should be_a(Spec::Expectations::ExpectationNotMetError)
          end
        end

        describe "when a performance test passes" do
          attr_reader :spec_options
          before do
            @spec_options = { :iterations => 1, :concurrency => 1, :mean_iteration_interval => 100000 }
          end

          it "reports the success" do
            example_group.perform("reports the success", spec_options) { 1.should == 1 }
            example_group.run(fake_run_options)
            
            fake_run_options.reporter.example_failures.should be_empty
            example = fake_run_options.reporter.example_successes.first
            example.description.should == "reports the success" 
          end
        end
      end

    end
  end
end

