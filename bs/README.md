# Docker Big-Sibling puppet-module

Puppet module for big-sibling installation

# Usage

```puppet
  class { 'bs':
	image => 'tsuru/bs:v1',
	log_backends => 'none',
	metrics_backend => 'logstash',
	metrics_logstash_host => 'localhost',
	metrics_logstash_port => '1984',
  }
```

# Full Parameters list

For details on each of those parameters, check https://github.com/tsuru/bs#environment-variables.

