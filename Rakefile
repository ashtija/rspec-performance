require "rubygems"
require "rake"
require "spec/rake/spectask"

task :default => :spec do
end

desc "Runs the rspec-performance ruby specs."
Spec::Rake::SpecTask.new(:runspec) do |t|
  t.libs << 'lib'
  t.libs << File.dirname(__FILE__)
  t.spec_files = []
  t.spec_files += FileList['spec/**/*_spec.rb']
end