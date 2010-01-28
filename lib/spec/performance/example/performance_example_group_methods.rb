require "spec/performance/example/performance_execution_builder"

module Spec
  module Performance
    module Example

      module PerformanceExampleGroupMethods

        def perform(description, options = {}, backtrace = nil, &implementation)
          options = Spec::Performance::Configuration.configured_options.merge(options)

          builder = PerformanceExecutionBuilder.new(options, &implementation)
          example(description, options, backtrace, &builder.performance_proc)
        end
      end

    end
  end
end
