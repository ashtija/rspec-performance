require "spec/performance/example/performance_example_group_methods"

module Spec
  module Performance
    module Example
      class PerformanceExampleGroup < Spec::Example::ExampleGroup
        
        attr_reader :performance_driver
        before(:each) do
          options = Spec::Performance::Configuration.configured_options
          @performance_driver = options[:performance_driver_class].new(options[:performance_driver_base_uri])
        end

        extend PerformanceExampleGroupMethods
      end
    end
  end
end
