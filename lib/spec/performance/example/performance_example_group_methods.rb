require 'ruby-debug'

module Spec
  module Performance
    module Example
      module PerformanceExampleGroupMethods
        PERFORMANCE_EXAMPLE_LABEL = "Performance Example"

        def perform(description, options = {}, backtrace = nil, &implementation)
          options = Spec::Performance::Configuration.configured_options.merge(options)
          iterations_per_slice = options[:iterations] / options[:concurrency]

          implementation_with_performance_loop = Proc.new do
            example_run_time = self.class.timed_operation(PERFORMANCE_EXAMPLE_LABEL) do
              (1..iterations_per_slice).each do |current_iteration|
                instance_eval(&implementation)
              end
            end

            if options[:iterations_per_second]
              estimated_iteration_run_time = example_run_time / iterations_per_slice
              acceptable_estimated_iteration_run_time = 1.0 / options[:iterations_per_second]
              estimated_iteration_run_time.should <= acceptable_estimated_iteration_run_time
            end
          end
          example(description, options, backtrace, &implementation_with_performance_loop)
        end

        def calculate_average(sample_size, current_average, new_value)
          (sample_size * current_average + new_value) / (sample_size + 1)
        end

        def timed_operation(label, &block)
          tic = Time.now.to_f
          yield
          Time.now.to_f - tic
        end
      end
    end
  end
end
