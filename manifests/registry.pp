#
# == Class: tsuru::registry
#
#  Tsuru registry node
#
# === Parameters
#
# [registry_ipbind_port] Registry ip X bind port
# [registry_path] Registry local path
# [registry_version] Registry package version

class tsuru::registry (
  $registry_ipbind_port  = '0.0.0.0:8080',
  $registry_path         = '/var/lib/docker-registry',
  $registry_version      = latest,
  $registry_user         = 'registry',
  $registry_group        = 'registry'
) {

  require tsuru::params

  package { 'docker-registry' :
    ensure =>  $registry_version
  }

  file { '/etc/init/docker-registry.conf':
    ensure  => present,
    content => template('tsuru/registry/docker-registry.conf.erb'),
    mode    => '0644',
    owner   => root,
    group   => root,
    notify  => Service['docker-registry'],
  }

  file { '/var/run/registry':
    ensure  => directory,
    recurse => true,
    mode    => '0755',
    owner   => $registry_user,
    group   => $registry_group,
    notify  => Service['docker-registry'],
  }

  if ( mkdir_p($registry_path) ) {
    file { $registry_path:
      ensure  => directory,
      mode    => '0755',
      owner   => $registry_user,
      group   => $registry_group,
      notify  => Service['docker-registry']
    }
  }

  service { 'docker-registry':
    ensure     => running,
    enable     => true,
    provider   => 'upstart',
    subscribe  => File['/etc/init/docker-registry.conf'],
    require    => File['/etc/init/docker-registry.conf']
  }

}
