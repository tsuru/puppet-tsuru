# Docker Big-Sibling puppet-module

Puppet module for big-sibling installation

# Usage

```puppet
  class { 'bs':
    log_backends      => 'tsuru,syslog',
    metric_backends   => 'logstash',
  }
```

# Full Parameters list

