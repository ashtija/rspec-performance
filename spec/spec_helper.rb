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

Spec::Runner.configure do |config|
  config.mock_with :rr
end

module Spec::Performance::Runner
  class TestReporter < Spec::Runner::Reporter
    attr_reader :example_failures

    def initialize(options)
      super(options)
      @example_failures = []
    end

    def example_failed(example, error)
      @example_failures << { :example => example, :error => error }
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