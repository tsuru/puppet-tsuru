class redis_service::install (
    $filer_docker,
    $lxc_docker_version = 'latest'
) inherits redis_service {

  include base

  file { '/etc/profile.d/docker.sh' :
    content => $docker_alias,
    mode    => '0755'
  }

  file { '/etc/init/sentinel.conf':
    ensure  => file,
    source  => 'puppet:///modules/redis_service/sentinel.conf',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  if ( $lxc_docker_version == 'latest' ) {
    $lxc_package_name = 'lxc-docker'
    package { 'lxc-docker' :
      ensure  => latest,
      notify  => Service['docker']
    }
  } else {
    $lxc_package_name = "lxc-docker-${lxc_docker_version}"
    package { "lxc-docker-${lxc_docker_version}":
      ensure => installed,
      notify => Service['docker']
    }
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
    require    => [ Package[$lxc_package_name], File['/etc/init/docker.conf'], File['/etc/default/docker'] ]
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
    content => template('redis_service/init-docker.conf.erb'),
    mode    => '0644',
    owner   => root,
    group   => root,
    notify  => Service['docker']
  }

  file {'/etc/default/docker':
    ensure  => file,
    source  => 'puppet:///modules/redis_service/docker',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    notify  => Service['docker']
  }
}
