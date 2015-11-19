# class rpaas::install
class rpaas::install (

  $nginx_package            = 'latest',
  $nginx_user               = 'www-data',
  $nginx_group              = 'www-data',
  $nginx_worker_processes   = 'auto',
  $nginx_worker_connections = 1024,
  $nginx_listen             = 8080,
  $nginx_ssl_listen         = 8443,
  $nginx_admin_listen       = 8089,
  $nginx_key_zone_size      = '10m',
  $nginx_cache_inactive     = '3d',
  $nginx_cache_size         = '3g',
  $nginx_location_purge     = true,
  $nginx_allow_admin_list   = ['127.0.0.0/24','127.1.0.0/24'],
  $nginx_custom_error_dir   = undef,
  $nginx_custom_error_codes = {},
  $nginx_intercept_errors   = false,
  $nginx_syslog_server      = undef,
  $nginx_syslog_tag         = undef,
  $nginx_mechanism          = 'dav',
  $consul_template_version  = latest,
  $consul_server            = undef,
  $consul_syslog_enabled    = true,
  $consul_syslog_facility   = 'LOCAL0',
  $consul_acl_token         = undef,
  $rpaas_service_name       = undef,
  $rpaas_instance_name      = undef

) inherits rpaas {

  include base
  include sudo

  if ($nginx_custom_error_codes != {} and !$nginx_custom_error_dir) {
    fail("nginx_custom_error_dir must be set with nginx_custom_error_codes")
  }

  if ($nginx_custom_error_codes and !is_hash($nginx_custom_error_codes)) {
    fail("nginx_custom_error_codes should be in hash format")
  }

  if ($nginx_mechanism == 'consul') {

    package { 'consul-template':
      ensure => $consul_template_version,
    }

    file { '/etc/consul-template.d/templates':
      ensure  => directory,
      require => Package['consul-template']
    }

    file { '/etc/consul-template.d/plugins':
      ensure  => directory,
      require => Package['consul-template']
    }

    file { '/etc/consul-template.d/consul.conf':
      ensure  => file,
      content => template('rpaas/consul/consul.conf.erb'),
      require => Package['consul-template']
    }

    file { '/etc/consul-template.d/templates/locations.conf.tpl':
      ensure  => file,
      content => template('rpaas/consul/locations.conf.tpl.erb'),
      require => File['/etc/consul-template.d/templates']
    }

    file { '/etc/consul-template.d/templates/nginx.key.tpl':
      ensure  => file,
      content => template('rpaas/consul/nginx.key.tpl.erb'),
      require => File['/etc/consul-template.d/templates']
    }

    file { '/etc/consul-template.d/templates/nginx.crt.tpl':
      ensure  => file,
      content => template('rpaas/consul/nginx.crt.tpl.erb'),
      require => File['/etc/consul-template.d/templates']
    }

    file { '/etc/consul-template.d/plugins/check_nginx_ssl_data.sh':
      ensure  => file,
      source  => 'puppet:///modules/rpaas/check_nginx_ssl_data.sh',
      require => File['/etc/consul-template.d/plugins']
    }

    file { '/etc/consul-template.d/plugins/check_and_reload_nginx.sh':
      ensure  => file,
      content => template('rpaas/consul/check_and_reload_nginx.sh.erb'),
      require => File['/etc/consul-template.d/plugins'],
      mode    => 0755
    }

    service { 'consul-template':
      ensure    => running,
      require   => [  Package['consul-template'],
                      File['/etc/consul-template.d/consul.conf'],
                      File['/etc/consul-template.d/templates/locations.conf.tpl'],
                      File['/etc/consul-template.d/templates/nginx.key.tpl'],
                      File['/etc/consul-template.d/templates/nginx.crt.tpl'],
                      File['/etc/consul-template.d/plugins/check_nginx_ssl_data.sh'],
                      File['/etc/nginx/certs'],
                      File['/etc/consul-template.d/plugins/check_and_reload_nginx.sh'] ],
      subscribe => [  Package['consul-template'],
                      File['/etc/consul-template.d/consul.conf'],
                      File['/etc/consul-template.d/templates/locations.conf.tpl'],
                      File['/etc/consul-template.d/templates/nginx.key.tpl'],
                      File['/etc/consul-template.d/templates/nginx.crt.tpl'],
                      File['/etc/consul-template.d/plugins/check_nginx_ssl_data.sh'],
                      File['/etc/nginx/certs'] ]
    }

  }

  package { 'nginx-extras':
    ensure => $nginx_package,
    require => [ Exec['apt_update'], File['/etc/nginx/nginx.conf'], Exec['ssl'] ]
  }

  service { 'nginx':
    ensure   => running,
    enable   => true,
    provider => 'upstart',
    restart  => '/usr/sbin/service nginx reload',
    require  => Package['nginx-extras']
  }

  file { $rpaas::nginx_dirs:
    ensure  => directory,
    recurse => true,
    owner   => $nginx_user,
    group   => $nginx_group
  }


  if ($nginx_mechanism == 'dav') {
    $ssl_key_file   = $rpaas::dav_ssl_key_file
    $ssl_crt_file  = $rpaas::dav_ssl_crt_file
  } else {
    $ssl_key_file   = $rpaas::consul_ssl_key_file
    $ssl_crt_file  = $rpaas::consul_ssl_crt_file
  }
  $ssl_command = "/usr/bin/sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
                 -keyout ${ssl_key_file} \
                 -out ${ssl_crt_file} \
                 -subj \"/C=BR/ST=RJ/L=RJ/O=do not use me/OU=do not use me/CN=rpaas.tsuru\""
  exec { 'ssl':
    path    => '/etc/nginx',
    command => $ssl_command,
    onlyif  => ["/usr/bin/test ! -f ${ssl_key_file}",
                "/usr/bin/test ! -f ${ssl_crt_file}"],
    require => [File['/etc/nginx'], File[$rpaas::dav_ssl_dir], File[$rpaas::consul_ssl_dir]]
  }

  file { [$ssl_key_file, $ssl_crt_file]:
    ensure  => file,
    owner   => $nginx_user,
    group   => $nginx_group,
    require => Exec['ssl'],
  }

  file { '/etc/nginx/sites-enabled/default':
    ensure  => absent,
    force   => true,
    require => Package['nginx-extras']
  }

  file { '/etc/nginx/nginx.conf':
    content => template('rpaas/nginx.conf.erb'),
    notify  => Service['nginx'],
    require => File['/etc/nginx']
  }

  if ($nginx_mechanism == 'dav') {
    sudo::conf { $nginx_user:
      content => "${nginx_user} ALL=(ALL) NOPASSWD: /usr/sbin/service nginx reload"
    }
  }

}
