#
# == Class: router
#
#  Tsuru router node
#
# === Parameters
#
# TODO

class router::install (

  $router_port                     = 80,
  $router_bind                     = '0.0.0.0',
  $router_hipache_workers          = 5,
  $router_hipache_max_sockets      = 100,
  $router_dead_backend_ttl         = 30,
  $router_tcp_timeout              = 30,
  $router_planb_connect_timeout    = 10,
  $router_hipache_http_keep_alive  = true,
  $router_access_log               = '/var/log/hipache/access_log',
  $router_access_log_mode          = 'file',
  $router_redis_host               = '127.0.0.1',
  $router_redis_port               = 6379,
  $router_redis_master_host        = '127.0.0.1',
  $router_redis_master_port        = 6379,
  $router_service_planb_enable     = true,
  $router_service_planb_ensure     = 'running',
  $router_service_hipache_enable   = true,
  $router_service_hipache_ensure   = 'running',
  $router_service_hchecker_enable  = true,
  $router_service_hchecker_ensure  = 'running',
  $router_mode                     = 'hipache',
  $router_planb_package_version    = 'latest',
  $router_hipache_package_version  = 'latest',
  $router_hchecker_package_version = 'latest',
  $hchecker_enabled                = true,
  $hckecher_uri                    = '/',
  $hchecker_redis_server           = 'localhost:6379',
  $hchecker_redis_key_suffix       = 'localhost',
  $hchecker_http_method            = 'head',
  $hchecker_io_timeout             = 3,
  $hchecker_check_interval         = 3,
  $hchecker_connect_timeout        = 3,
  $hchecker_redis_idle_timeout     = 120,
  $hchecker_redis_max_idle         = 3,

) inherits router {

  require base

  if ($router_mode == 'hipache') {

    package { 'planb':
      ensure => purged
    }

    service { 'planb':
      ensure => stopped,
    }

    package { 'node-hipache' :
      ensure  => $router_hipache_package_version,
      notify  => Service['hipache']
    }

    service { 'hipache':
      ensure     => $router_service_hipache_ensure,
      enable     => $router_service_hipache_enable,
      hasrestart => true,
      hasstatus  => true,
      provider   => $router::service_provider,
      require    => [ Package['node-hipache'], File['/etc/hipache.conf'] ]
    }

    file { '/etc/hipache.conf':
      content => template('router/hipache.conf.erb'),
      owner   => root,
      group   => root,
      mode    => '0600',
      require => Package['node-hipache'],
      notify  => Service['hipache']
    }

  }

  if ($router_mode == 'planb') {

    package { 'planb':
      ensure => $router_planb_package_version,
      notify => Service['planb']
    }

    package { 'node-hipache' :
      ensure  => purged
    }

    service { 'hipache':
      ensure => stopped
    }

    file { '/etc/default/planb':
      ensure  => file,
      content => template('router/planb_conf.erb'),
      notify  => Service['planb'],
      require => Package['planb']
    }

    service { 'planb':
      ensure     => $router_service_planb_ensure,
      enable     => $router_service_planb_enable,
      hasrestart => true,
      hasstatus  => true,
      provider   => $router::service_provider,
      require    => [ Package['planb'], File['/etc/default/planb'] ]
    }

  }

  if ($router_service_hchecker_enable) {

    package { 'hipache-hchecker' :
      ensure  => $router_hchecker_package_version,
      notify  => Service['hipache-hchecker']
    }

    service { 'hipache-hchecker':
      ensure     => $router_service_hchecker_ensure,
      enable     => $router_service_hchecker_enable,
      hasrestart => true,
      hasstatus  => true,
      provider   => $router::service_provider,
      require    => [ Package['hipache-hchecker'],
                      File['/etc/default/hipache-hchecker'] ]
    }

    file { '/etc/default/hipache-hchecker':
      content => template('router/hipache-hchecker.conf.erb'),
      owner   => root,
      group   => root,
      mode    => '0600',
      require => Package['hipache-hchecker'],
      notify  => Service['hipache-hchecker']
    }
  }



}
