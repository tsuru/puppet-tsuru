source 'https://rubygems.org'

group :development, :test do
  gem 'puppetlabs_spec_helper', '~>2.5.1'
  gem 'puppet-lint'
  gem 'rspec-mocks'
  gem 'rspec-puppet'
  gem 'rspec'
  gem 'webmock'
end

if puppetversion = ENV['PUPPET_GEM_VERSION']
  gem 'puppet', puppetversion, :require => false
else
  gem 'puppet', '6.13.0', :require => false
end

# vim:ft=ruby
