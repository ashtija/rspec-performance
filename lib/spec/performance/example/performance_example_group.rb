require "spec/performance/example/performance_example_group_methods"

module Spec
  module Performance
    module Example
      class PerformanceExampleGroup < Spec::Example::ExampleGroup
        extend PerformanceExampleGroupMethods
      end
    end
  end
end