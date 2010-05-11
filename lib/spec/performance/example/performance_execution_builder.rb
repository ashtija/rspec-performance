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

            example_run_time, maximum_iteration_time = _run_performance_loop(iterations_per_slice, &implementation)
            _assert_iterations_per_second(example_run_time, iterations_per_slice, options[:iterations_per_second]) if options[:iterations_per_second]
            _assert_maximum_iteration_time(maximum_iteration_time, options[:maximum_iteration_time]) if options[:maximum_iteration_time]
          end
        end

        module PerformanceHelpers
          private

          def _run_performance_loop(iterations_per_slice, &implementation)
            maximum_iteration_time = 0.0
            example_run_time = _timed_operation EXAMPLE_RUN_TIME_LABEL do
              (1..iterations_per_slice).each do |current_iteration|
                # TODO: there is almost certainly a better way to get a new performance driver at each iteration...
                @performance_driver = options[:performance_driver_class].new(options[:performance_driver_base_uri])
                iteration_run_time = _timed_operation ITERATION_RUN_TIME_LABEL do
                  instance_eval(&implementation)
                end
                maximum_iteration_time = _calculate_average(current_iteration - 1, maximum_iteration_time, iteration_run_time)
              end
            end

            [example_run_time, maximum_iteration_time]
          end

          def _assert_iterations_per_second(example_run_time, iterations_per_slice, acceptable_iterations_per_second)
            estimated_iteration_run_time = example_run_time / iterations_per_slice
            acceptable_estimated_iteration_run_time = 1.0 / acceptable_iterations_per_second
            estimated_iteration_run_time.should <= acceptable_estimated_iteration_run_time
          end

          def _assert_maximum_iteration_time(maximum_iteration_time, acceptable_maximum_iteration_time)
            maximum_iteration_time.should <= acceptable_maximum_iteration_time
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
