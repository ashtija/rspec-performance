require "#{File.dirname(__FILE__)}/lib/spec/performance/version"

spec = Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.summary = "Ruby based make-like utility."
  s.name = "rspec-performance"
  s.version = Spec::Performance::VERSION::STRING
  s.requirements << "rspec-1.2.6"
  s.require_path = "lib"
  s.files = Dir["lib/**/*.rb"] + Dir["spec/**/*.rb"] + ["Rakefile", "README"]
  s.description = "rspec-performance adds a couple of utility methods for unit testing performance"
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end
