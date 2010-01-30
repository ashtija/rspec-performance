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

# Gem packaging tasks
load("rspec-performance.gemspec")
