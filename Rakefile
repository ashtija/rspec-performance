require "rubygems"
require "rake"
require "rake/gempackagetask"
require "spec/rake/spectask"

task :default => :spec do
end


desc "Runs the rspec-performance ruby specs."
Spec::Rake::SpecTask.new(:spec) do |t|
  spec_options = File.readlines("spec/spec.opts").map {|line| line.chomp }

  t.libs << 'lib'
  t.libs << File.dirname(__FILE__)
  t.spec_opts = spec_options
  t.spec_files = FileList['spec/**/*_spec.rb']
end

spec = Gem::Specification.new do |s|
  require "lib/spec/performance/version"

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

