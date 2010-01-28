begin
  require "spec"
rescue LoadError
  require "rubygems" unless ENV["NO_RUBYGEMS"]
  gem "rspec"
  require "spec"
end

$:.unshift(File.dirname(__FILE__) + "/../lib")
dir = File.dirname(__FILE__)

require "rspec-performance"
require "#{dir}/helpers/integration_server"

IntegrationServer.port = 8888

Spec::Runner.configure do |config|
  config.mock_with :rr
end

module Spec::Performance::Runner
  class TestReporter < Spec::Runner::Reporter
    attr_reader :example_failures, :example_successes  

    def initialize(options)
      super(options)
      reset
    end

    def example_failed(example, error)
      @example_failures << { :example => example, :error => error }
    end

    def example_passed(example)
      @example_successes << example
    end

    def reset
      @example_failures = []
      @example_successes = []
    end
  end
end

def with_sandboxed_options
  attr_reader :options

  before(:each) do
    @original_rspec_options = ::Spec::Runner.options
    ::Spec::Runner.use(@options = ::Spec::Runner::Options.new(StringIO.new, StringIO.new))
  end

  after(:each) do
    ::Spec::Runner.use(@original_rspec_options)
  end

  yield
end

class Array
  def sum(&block)
    inject(0.0) do |acc, x|
      acc += block_given? ? yield(x) : x
      acc
    end
  end
end

