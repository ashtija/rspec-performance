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

      def maximum_iteration_time=(value)
        @options[:maximum_iteration_time] = value
      end

      def performance_driver_class=(value)
        @options[:performance_driver_class] = value
      end

      def performance_driver_base_uri=(value)
        @options[:performance_driver_base_uri] = value
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
              :maximum_iteration_time => nil,
              :performance_driver_class => Spec::Client::HttpClient,
              :performance_driver_base_uri => "http://localhost/"
          }
        end
      end
    end
  end
end
