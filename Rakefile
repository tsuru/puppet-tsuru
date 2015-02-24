require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'rspec/core/rake_task'

PuppetLint.configuration.send('disable_80chars')
PuppetLint.configuration.send('disable_class_parameter_defaults')
PuppetLint.configuration.ignore_paths = [
  "spec/**/*.pp",
  "vendor/**/*.pp",
  "**/pkg/**/*.pp",
  "**/spec/fixtures/modules/**/**/*.pp"
]

Rake::Task[:spec].enhance [:lint]
