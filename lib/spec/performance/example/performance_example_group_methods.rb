require "spec/performance/example/performance_execution_builder"

module Spec
  module Performance
    module Example
      module PerformanceExampleGroupMethods
        def perform(description, options = {}, backtrace = nil, &implementation)
          options = Spec::Performance::Configuration.configured_options.merge(options)
          builder = PerformanceExecutionBuilder.new(options, &implementation)

          implementation_with_performance_loop = builder.performance_proc

          example(description, options, backtrace, &implementation_with_performance_loop)
        end
      end

    end
  end
end
