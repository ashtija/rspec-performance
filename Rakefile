require "rubygems"
require "rake"
require "rake/gempackagetask"
require "spec/rake/spectask"

load("rspec-performance.gemspec")

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

desc "Publish the gem via gem cutter"
task :publish do
  system "gem build rspec-performance.gemspec"
  system "gem push rspec-performance-#{Spec::Performance::VERSION::STRING}.gem"
end

desc "Runs the integration test server"
task "integration:run" do
  require "spec/helpers/integration_server"
  IntegrationServer.new(8888).run
end

# Gem packaging tasks
