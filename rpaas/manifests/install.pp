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
  $nginx_custom_error_dir   = undef,
  $nginx_custom_error_codes = {},
  $nginx_intercept_errors   = false

) inherits rpaas {

  include base
  include sudo

  if ($nginx_custom_error_codes != {} and !$nginx_custom_error_dir) {
    fail("nginx_custom_error_dir must be set with nginx_custom_error_codes")
  }

  if ($nginx_custom_error_codes and !is_hash($nginx_custom_error_codes)) {
    fail("nginx_custom_error_codes should be in hash format")
  }

  package { 'nginx-extras':
    ensure => $nginx_package,
    require => [ Exec['apt_update'], File['/etc/nginx/nginx.conf'] ]
  }

  service { 'nginx':
    ensure   => running,
    enable   => true,
    restart  => '/etc/init.d/nginx reload',
    require  => Package['nginx-extras'],
  }

  file { $rpaas::dav_dir:
    ensure  => directory,
    recurse => true,
    owner   => $nginx_user,
    group   => $nginx_group,
    require => File['/etc/nginx'],
  }

  exec { 'ssl':
    path    => '/etc/nginx',
    command => $rpaas::ssl_command,
    onlyif  => ["/usr/bin/test ! -f ${rpaas::dav_ssl_key_file}",
                "/usr/bin/test ! -f ${rpaas::dav_ssl_crt_file}"],
    require => [File['/etc/nginx'], File[$rpaas::dav_ssl_dir]],
  }

  file { [$rpaas::dav_ssl_key_file, $rpaas::dav_ssl_crt_file]:
    ensure  => file,
    owner   => $nginx_user,
    group   => $nginx_group,
    require => Exec['ssl'],
  }

  file { '/etc/nginx/sites-enabled/default':
    ensure => absent,
    force  => true,
    require => Package['nginx-extras'],
  }

  file { '/etc/nginx':
    ensure => directory
  }

  file { '/etc/nginx/nginx.conf':
    content => template('rpaas/nginx.conf.erb'),
    notify  => Service['nginx'],
    require => File['/etc/nginx']
  }

  sudo::conf { $nginx_user:
    content => "${nginx_user} ALL=(ALL) NOPASSWD: /usr/sbin/service nginx reload",
  }

}
