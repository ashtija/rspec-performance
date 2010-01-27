module Spec
  module Performance
    module Example

      class PerformanceExecutionBuilder
        attr_reader :options

        EXAMPLE_RUN_TIME_LABEL = "Performance Example Run Time"
        ITERATION_RUN_TIME_LABEL = "Performance Iteration Run Time"

        def initialize(options, &implementation)
          @options = options
          @impl = implementation
        end

        def performance_proc
          iterations_per_slice = options[:iterations] / options[:concurrency]

          # NOTE: Block execution only works if this is a local variable.
          implementation = @impl

          Proc.new do
            extend(PerformanceHelpers)

            example_run_time, mean_iteration_interval = _run_performance_loop(iterations_per_slice, &implementation)
            _assert_iterations_per_second(example_run_time, iterations_per_slice, options[:iterations_per_second]) if options[:iterations_per_second]
            _assert_mean_iteration_interval(mean_iteration_interval, options[:mean_iteration_interval]) if options[:mean_iteration_interval]
          end
        end

        module PerformanceHelpers
          private

          def _run_performance_loop(iterations_per_slice, &implementation)
            mean_iteration_interval = 0.0
            example_run_time = _timed_operation EXAMPLE_RUN_TIME_LABEL do
              (1..iterations_per_slice).each do |current_iteration|
                iteration_run_time = _timed_operation ITERATION_RUN_TIME_LABEL do
                  instance_eval(&implementation)
                end
                mean_iteration_interval = _calculate_average(current_iteration - 1, mean_iteration_interval, iteration_run_time)
              end
            end
            [example_run_time, mean_iteration_interval]
          end

          def _assert_iterations_per_second(example_run_time, iterations_per_slice, acceptable_iterations_per_second)
            estimated_iteration_run_time = example_run_time / iterations_per_slice
            acceptable_estimated_iteration_run_time = 1.0 / acceptable_iterations_per_second
            estimated_iteration_run_time.should <= acceptable_estimated_iteration_run_time
          end

          def _assert_mean_iteration_interval(mean_iteration_interval, acceptable_mean_iteration_interval)
            mean_iteration_interval.should <= acceptable_mean_iteration_interval
          end

          def _calculate_average(sample_size, current_average, new_value)
            (sample_size * current_average + new_value) / (sample_size + 1)
          end

          def _timed_operation(label, &block)
            tic = Time.now.to_f
            yield
            Time.now.to_f - tic
          end
        end
      end

    end
  end
end
