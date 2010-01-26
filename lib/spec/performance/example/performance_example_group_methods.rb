require 'ruby-debug'

module Spec
  module Performance
    module Example
      module PerformanceExampleGroupMethods
        EXAMPLE_RUN_TIME = "Performance Example Run Time"
        ITERATION_RUN_TIME = "Performance Iteration Run Time"

        def perform(description, options = {}, backtrace = nil, &implementation)
          options = Spec::Performance::Configuration.configured_options.merge(options)
          iterations_per_slice = options[:iterations] / options[:concurrency]
          mean_iteration_interval = 0.0

          implementation_with_performance_loop = Proc.new do
            example_run_time = self.class.timed_operation EXAMPLE_RUN_TIME do
              (1..iterations_per_slice).each do |current_iteration|
                iteration_run_time = self.class.timed_operation ITERATION_RUN_TIME do
                  instance_eval(&implementation)
                end

                mean_iteration_interval = self.class.calculate_average(current_iteration - 1, mean_iteration_interval, iteration_run_time)
              end
            end

            if options[:iterations_per_second]
              estimated_iteration_run_time = example_run_time / iterations_per_slice
              acceptable_estimated_iteration_run_time = 1.0 / options[:iterations_per_second]
              estimated_iteration_run_time.should <= acceptable_estimated_iteration_run_time
            end

            if options[:mean_iteration_interval]
              mean_iteration_interval.should <= options[:mean_iteration_interval]
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
