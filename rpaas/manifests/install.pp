# class rpaas::install
class rpaas::install (

  $nginx_package = '1.4.6-1ubuntu3.1'
  # $nginx_user =
  # $nginx_worker_processes =
  # $nginx_worker_connections =
  # $nginx_listen =

) inherits rpaas {

  include base

  package { 'nginx-extras':
    ensure => $nginx_package,
  }

  service { 'nginx':
    ensure   => running,
    enable   => true,
    provider => 'upstart',
    require  => Package['nginx-extras'],
  }

  file { '/etc/nginx/sites-enabled/dav/ssl':
    ensure  => directory,
    recurse => true,
  }

  exec { 'ssl':
    command => $::rpaas::ssl_command,
    # onlyif  => ''
  }

  file { '/etc/nginx/sites-enabled':
    ensure => directory,
    owner  => 'www-data',
    group  => 'www-data',
  }

  file { '/etc/nginx/sites-enabled/default':
    ensure => absent,
    force  => true,
  }

  file { '/etc/nginx/nginx.conf':
    content => template('rpaas/nginx.conf.erb'),
    # owner   => root,
    # group   => root,
    # mode    => '0600',
    require => Package['nginx-extras'],
  }

}