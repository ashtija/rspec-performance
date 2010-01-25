module Spec
  module Performance
    module Example
      module PerformanceExampleGroupMethods
        def perform(description, options = {}, backtrace = nil, &implementation)
          implementation_with_performance_loop = Proc.new do
            instance_eval(&implementation)
          end
          example(description, options, backtrace, &implementation_with_performance_loop)
        end
        
        def calculate_average(sample_size, current_average, new_value)
          (sample_size * current_average + new_value) / (sample_size + 1)
        end
      end
    end
  end
end