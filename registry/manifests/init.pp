#
# == Class: registry
#
#  Tsuru registry node
#
# === Parameters
#
# [registry_ipbind_port] Registry ip X bind port
# [registry_path] Registry local path
# [registry_version] Registry package version
# [registry_user]
# [registry_group]
# [registry_storage] storages: s3 glance swift glance-swift elliptics gcs local
# [registry_venv_path] virtualenv to docker-registry installation

class registry (
  $registry_ipbind_port  = '0.0.0.0:8080',
  $registry_path         = '/var/lib/docker-registry',
  $registry_version      = latest,
  $registry_user         = 'registry',
  $registry_group        = 'registry',
  $registry_storage      = 'local',
  $registry_venv_path    = '/var/lib/venv',
  $gunicorn_max_requests = 100,
  $gunicorn_workers      = 3
) {

  require base

  $packages = [ 'liblzma-dev', 'libyaml-dev' ]
  package { $packages:
    ensure => installed
  }

  class { 'python':
    version    => 'system',
    dev        => true,
    virtualenv => true,
  }

  python::virtualenv { $registry_venv_path :
    ensure       => present,
    version      => 'system',
    owner        => 'root',
    group        => 'root'
  }

  file { "${registry_path}/config.yml":
    ensure  => present,
    content => template('registry/config.yml.erb'),
    mode    => '0644',
    owner   => 'root',
    group   => 'root'
  }

  file { '/etc/init/docker-registry.conf':
    ensure  => present,
    content => template('registry/docker-registry.conf.erb'),
    mode    => '0644',
    owner   => root,
    group   => root,
    notify  => Service['docker-registry'],
  }

  if ( $registry_storage == local and mkdir_p($registry_path) ) {
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
    require    => [ File['/etc/init/docker-registry.conf'],
                    Python::Gunicorn['docker-registry'] ]
  }

}
