module Spec
  module Performance
    class Configuration
      attr_accessor :max_request_median, :iterations, :concurrency, :min_requests_per_second

      DEFAULT_MAX_REQUEST_MEDIAN      = 1000
      DEFAULT_ITERATIONS              = 20
      DEFAULT_CONCURRENCY             = 1
      DEFAULT_MIN_REQUESTS_PER_SECOND = 40

      def initialize
        @max_request_median      = DEFAULT_MAX_REQUEST_MEDIAN
        @iterations              = DEFAULT_ITERATIONS
        @concurrency             = DEFAULT_CONCURRENCY
        @min_requests_per_second = DEFAULT_MIN_REQUESTS_PER_SECOND
      end

      def to_hash
        instance_variables.inject({}) do |acc, variable|
          acc[variable[1..-1].to_sym] = instance_variable_get(variable)
          acc
        end
      end

      class << self
        def instance
          @@instance ||= new
        end

        def configure(&block)
          block.call(instance)
        end
      end
    end
  end
end
