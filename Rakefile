require 'rake/clean'
require 'rspec/core/rake_task'

# rake/clean configuration
CLOBBER.include('**/*.gem', 'doc')

# rspec/core/rake_task configuration
RSpec::Core::RakeTask.new(:spec)

task :package do
  system 'gem build superstacker.gemspec'
end

task :docs do
  system 'rdoc'
end
