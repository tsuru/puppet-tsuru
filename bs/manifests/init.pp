#
# == Class: bs
#
#  Big-Sibling
#
# === Parameters
#
# https://github.com/tsuru/bs#environment-variables

class bs (
  $image                            = 'tsuru/bs:latest',
  $log_backends                     = undef,
  $log_tsuru_buffer_size            = undef,
  $log_tsuru_ping_interval          = undef,
  $log_tsuru_pong_interval          = undef,
  $log_syslog_buffer_size           = undef,
  $log_syslog_forward_addresses     = undef,
  $log_syslog_timezone              = undef,
  $status_interval                  = undef,
  $metrics_backend                  = undef,
  $metrics_interval                 = undef,
  $metrics_logstash_client          = undef,
  $metrics_logstash_port            = undef,
  $metrics_logstash_host            = undef,
  $metrics_logstash_protocol        = undef,
  $container_selection_env          = undef,
  $debug                            = undef,
  $hostcheck_base_container_name    = undef,
  $hostcheck_extra_paths            = undef,
  $tsuru_endpoint                   = undef,
  $tsuru_token                      = undef,
  $docker_endpoint                  = 'unix:///var/run/docker.sock',
  $syslog_listen_address            = undef,
  $host_proc                        = '/prochost',
  ){

  $envMap = {
    'LOG_BACKENDS'                  => $log_backends,
    'LOG_TSURU_BUFFER_SIZE'         => $log_tsuru_buffer_size,
    'LOG_TSURU_PING_INTERVAL'       => $log_tsuru_ping_interval,
    'LOG_TSURU_PONG_INTERVAL'       => $log_tsuru_pong_interval,
    'LOG_SYSLOG_BUFFER_SIZE'        => $log_syslog_buffer_size,
    'LOG_SYSLOG_FORWARD_ADDRESSES'  => $log_syslog_forward_addresses,
    'LOG_SYSLOG_TIMEZONE'           => $log_syslog_timezone,
    'STATUS_INTERVAL'               => $status_interval,
    'METRICS_BACKEND'               => $metrics_backend,
    'METRICS_INTERVAL'              => $metrics_interval,
    'METRICS_LOGSTASH_CLIENT'       => $metrics_logstash_client,
    'METRICS_LOGSTASH_PORT'         => $metrics_logstash_port,
    'METRICS_LOGSTASH_HOST'         => $metrics_logstash_host,
    'METRICS_LOGSTASH_PROTOCOL'     => $metrics_logstash_protocol,
    'CONTAINER_SELECTION_ENV'       => $container_selection_env,
    'BS_DEBUG'                      => $debug,
    'HOSTCHECK_BASE_CONTAINER_NAME' => $hostcheck_base_container_name,
    'HOSTCHECK_EXTRA_PATHS'         => $hostcheck_extra_paths,
    'TSURU_ENDPOINT'                => $tsuru_endpoint,
    'TSURU_TOKEN'                   => $tsuru_token,
    'DOCKER_ENDPOINT'               => $docker_endpoint,
    'SYSLOG_LISTEN_ADDRESS'         => $syslog_listen_address,
    'HOST_PROC'                     => $host_proc,
  }

  $env = join(prefix(join_keys_to_values(delete_undef_values($envMap), '='), '-e '), ' ')

  if $host_proc {
    $proc_volume = "-v /proc:${host_proc}:ro"
  } else {
    $proc_volume = ''
  }

  exec { 'pull image':
    command => "/usr/bin/docker pull ${image}",
    path    => '/usr/bin',
    require => Class['docker']
  }

  if $::bs_is_running {
    exec { 'stop':
        command => '/usr/bin/docker stop big-sibling',
        path    => '/usr/bin',
        require => Exec['pull image'],
        before  => Exec['remove']
      }
  }

  exec { 'remove':
    command => '/usr/bin/docker rm big-sibling',
    path    => '/usr/bin',
    onlyif  => '/usr/bin/docker inspect big-sibling',
    require => Exec['pull image']
  }

  exec { 'run':
    command => "/usr/bin/docker run -d --restart='always' --name='big-sibling' ${proc_volume} ${env} ${image}",
    path    =>  '/usr/bin',
    require => Exec['install']
  }

}
