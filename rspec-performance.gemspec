require "rubygems"
require "rake"
require "rake/gempackagetask"

require "#{File.dirname(__FILE__)}/lib/spec/performance/version"

spec = Gem::Specification.new do |s|
  s.author = "Bob Remeika"
  s.email = "bob@grockit.com"
  s.homepage = "http://grockit.com"
  s.rubyforge_project = "rspec-performance"

  s.platform = Gem::Platform::RUBY

  s.summary = "Ruby based make-like utility."
  s.name = "rspec-performance"
  s.version = Spec::Performance::VERSION::STRING
  s.requirements << "rspec-1.2.6"
  s.require_path = "lib"
  s.files = Dir["lib/**/*.rb"] + Dir["spec/**/*.rb"] + ["Rakefile", "README"]
  s.description = "rspec-performance adds a couple of utility methods for unit testing performance"
end
spec.add_dependency('mechanize', '>= 1.0.0')

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end
