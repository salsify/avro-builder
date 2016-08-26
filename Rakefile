require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'appraisal/task'

RSpec::Core::RakeTask.new(:default_spec)

Appraisal::Task.new

if !ENV['APPRAISAL_INITIALIZED']
  task default: :appraisal
  task spec: :appraisal
else
  task default: :default_spec
end
