module Spec
  module Performance
    class Configuration
      attr_reader :options

      def initialize(options)
        @options = options
      end

      def concurrency=(value)
        @options[:concurrency] = value
      end

      def iterations=(value)
        @options[:iterations] = value
      end

      def iterations_per_second=(value)
        @options[:iterations_per_second] = value
      end

      def mean_iteration_iterval=(value)
        @options[:mean_iteration_iterval] = value
      end

      class << self
        def instance
          @@instance ||= new(default_options)
        end

        def configure(&block)
          yield(instance)
        end

        def configured_options
          instance.options
        end

        def default_options
          {
              :concurrency => 1,
              :iterations => 20,
              :iterations_per_second => nil,
              :mean_iteration_iterval => nil
          }
        end
      end
    end
  end
end
