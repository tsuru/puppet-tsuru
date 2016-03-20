source 'https://rubygems.org'

group :development, :test do
  gem 'puppetlabs_spec_helper', :require => false
  gem 'puppet-lint', :git => 'https://github.com/rodjek/puppet-lint', :ref => 'eec92c19ccfbf558890124d4436bfe7d0e8879e5'
  gem 'rspec-mocks'
  gem 'rspec-puppet'
  gem 'rspec', '~>3.2.0'
  gem 'webmock'
end

if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion, :require => false
else
  gem 'puppet', '3.8.5', :require => false
end

# vim:ft=ruby
