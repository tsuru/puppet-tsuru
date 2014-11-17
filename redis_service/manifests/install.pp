class redis_service::install (
    $lxc_docker_version = 'latest'
) inherits redis_service {

  include base

  class {'docker':
    lxc_docker_version => $lxc_docker_version,
    docker_bind_opts   => '-H tcp://0.0.0.0:4243 -H unix:///var/run/docker.sock',
  }

  file { '/etc/init/sentinel.conf':
    ensure  => file,
    source  => 'puppet:///modules/redis_service/sentinel.conf',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  package { 'redis-server':
    ensure  => latest,
    notify  => Service['sentinel'],
    require => File['/etc/init/sentinel.conf']
  }

  service { 'sentinel':
    ensure      => running,
    enable      => true,
    hasrestart  => true,
    subscribe   => File['/etc/init/sentinel.conf'],
    provider    => 'upstart',
    require     => [ Package['redis-server'], File['/etc/init/sentinel.conf'] ]
  }

  service { 'redis-server':
    ensure  => stopped,
    require => Package['redis-server']
  }
}
