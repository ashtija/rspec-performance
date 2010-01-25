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