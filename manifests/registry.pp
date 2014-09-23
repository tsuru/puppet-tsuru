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
# [registry_user]
# [registry_group]
# [registry_storage] storages: s3 glance swift glance-swift elliptics gcs local
# [registry_venv_path] virtualenv to docker-registry installation

class tsuru::registry (
  $registry_ipbind_port  = '0.0.0.0:8080',
  $registry_path         = '/var/lib/docker-registry',
  $registry_version      = latest,
  $registry_user         = 'registry',
  $registry_group        = 'registry',
  $registry_storage      = 'local',
  $registry_venv_path    = '/var/lib/venv'
) {

  require tsuru::params

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
    content => template('tsuru/registry/config.yml.erb'),
    mode    => '0644',
    owner   => 'root',
    group   => 'root'
  }

  #DOCKER_REGISTRY_CONFIG=config_sample.yml /var/lib/virtualenv/bin/gunicorn -k
  #gevent --max-requests 100 --graceful-timeout 3600 -t 3600 -b localhost:5000
  #-w 8 docker_registry.wsgi:application

  file { '/etc/init/docker-registry.conf':
    ensure  => present,
    content => template('tsuru/registry/docker-registry.conf.erb'),
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
