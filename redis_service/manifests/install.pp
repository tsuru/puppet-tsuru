class redis_service::install (
    $filer_docker,
    $docker_version = 'latest'
) inherits redis_service {

  include base

  file { '/etc/profile.d/docker.sh' :
    content => $docker_alias,
    mode    => '0755'
  }

  file { '/etc/init/sentinel.conf':
    ensure  => file,
    source  => 'puppet:///redis_service/files/sentinel.conf',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  package { 'lxc-docker' :
    ensure  => $docker_version,
    notify  => Service['docker']
  }

  package { 'redis-server':
    ensure  => latest,
    notify  => Service['sentinel'],
    require => File['/etc/init/sentinel.conf']
  }

  service { 'docker':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    subscribe  => [File['/etc/init/docker.conf'], File['/etc/default/docker']],
    provider   => 'upstart',
    require    => [ Package['lxc-docker'], File['/etc/init/docker.conf'], File['/etc/default/docker'] ]
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

  file { '/etc/init/docker.conf':
    ensure  => present,
    content => template('docker/init-docker.conf.erb'),
    mode    => '0644',
    owner   => root,
    group   => root,
    notify  => Service['docker']
  }

  file {'/etc/default/docker':
    ensure  => file,
    source  => 'puppet:///redis_service/files/docker',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    notify  => Service['docker']
  }
}
