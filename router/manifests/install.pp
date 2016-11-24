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
  $router_mode                     = 'planb-docker',
  $router_planb_package_version    = 'latest',
  $docker_version                  = 'latest',
  $docker_graph_dir                = undef,
  $docker_bind                     = undef,
  $docker_extra_opts               = undef,
  $proxy_url                       = undef,
  $planb_pull_command              = '/usr/bin/docker pull tsuru/planb:v1',
  $planb_start_command             = "/usr/bin/docker run -d --restart=always --net=host --name=planb tsuru/planb:v1 \
                                      --listen :80 \
                                      --request-timeout 30 \
                                      --dial-timeout 10 \
                                      --dead-backend-time 30 \
                                      --access-log /var/log/hipache/access_log",

) inherits router {

  require base

  if ($router_mode == 'planb') {

    package { 'planb':
      ensure => $router_planb_package_version,
      notify => Service['planb']
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

  if ($router_mode == 'planb-docker') {

    class { 'docker':
      docker_version     => $docker_version,
      docker_graph_dir   => $docker_graph_dir,
      docker_bind        => $docker_bind,
      docker_extra_opts  => $docker_extra_opts,
      proxy_url          => $proxy_url,
    } ->
    exec { 'pull planb':
      command => $planb_pull_command,
      path    => '/usr/bin',
    } ->
    exec { 'start planb':
      command => $planb_start_command,
      path    => '/usr/bin',
      unless  => '/usr/bin/docker inspect --format="{{ .State.Running }}" planb',
    }

  }


}
