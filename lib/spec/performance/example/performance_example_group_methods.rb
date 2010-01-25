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
      end
    end
  end
end