# class rpaas::install
class rpaas::install (

  $nginx_package            = 'latest',
  $nginx_user               = 'www-data',
  $nginx_group              = 'www-data',
  $nginx_worker_processes   = 2,
  $nginx_worker_connections = 1024,
  $nginx_listen             = 8080,
  $nginx_ssl_listen         = 8443,
  $nginx_admin_listen       = 8089,
  $nginx_allow_dav_list     = ['127.0.0.0/24','127.1.0.0/24'],

) inherits rpaas {

  include base
  include sudo

  package { 'nginx-extras':
    ensure => $nginx_package,
  }

  service { 'nginx':
    ensure   => running,
    enable   => true,
    provider => 'upstart',
    require  => Package['nginx-extras'],
  }

  file { $rpaas::dav_dir:
    ensure  => directory,
    recurse => true,
    owner   => $nginx_user,
    group   => $nginx_group,
  }

  exec { 'ssl':
    path    => '/etc/nginx',
    command => $rpaas::ssl_command,
    onlyif  => ["/usr/bin/test ! -f ${rpaas::dav_ssl_key_file}",
                "/usr/bin/test ! -f ${rpaas::dav_ssl_crt_file}"],
    require => File[$rpaas::dav_ssl_dir],
  }

  file { [$rpaas::dav_ssl_key_file, $rpaas::dav_ssl_crt_file]:
    ensure  => file,
    owner   => $nginx_user,
    group   => $nginx_group,
    require => Exec['ssl'],
    notify  => Service['nginx'],
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
    notify  => Service['nginx'],
  }

  sudo::conf { $nginx_user:
    content => "${nginx_user} ALL=(ALL) NOPASSWD: /usr/sbin/service nginx reload",
  }

}