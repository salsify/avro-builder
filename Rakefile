# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'appraisal/task'

RSpec::Core::RakeTask.new(:default_spec)

Appraisal::Task.new

# rubocop:disable Rake/DuplicateTask
# rubocop:disable Rake/Desc
if !ENV['APPRAISAL_INITIALIZED']
  task default: :appraisal
  task spec: :appraisal
else
  task default: :default_spec
end
# rubocop:enable Rake/DuplicateTask
# rubocop:enable Rake/Desc
