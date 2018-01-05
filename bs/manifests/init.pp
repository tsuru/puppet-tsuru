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
  $syslog_listen_address            = undef,
  $host_proc                        = '/prochost',
  ){

  $docker_socket = '/var/run/docker.sock'
  $socket_volume = "-v ${docker_socket}:/var/run/docker.sock:rw"

  $env_map = delete_undef_values({
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
    'DOCKER_ENDPOINT'               => "unix://${docker_socket}",
    'SYSLOG_LISTEN_ADDRESS'         => $syslog_listen_address,
    'HOST_PROC'                     => $host_proc,
  })

  $env_st = join(join_keys_to_values($env_map, '='), ' ')
  $env = join(prefix(join_keys_to_values($env_map, '='), '-e '), ' ')

  if $host_proc {
    $proc_volume = "-v /proc:${host_proc}:ro"
  } else {
    $proc_volume = ''
  }

  $image_id = "docker images --no-trunc --format='{{.ID}}' ${image}"

  # returns 0 if bs is running
  $bs_running = 'docker ps -f name=big-sibling --format="{{.Names}}" | grep -c big-sibling'

  # returns 0 if bs is running with diferent envs or image id
  $inspect_bs = 'docker inspect --format="{{range .Config.Env}}{{println .}}{{end}}{{.Image}}" big-sibling'
  $changed = "${inspect_bs} 2> /dev/null | grep -v 'PATH' | xargs | grep -c -v \"${env_st} \$(${image_id})\""

  exec { 'pull bs image':
    command => "docker pull ${image}",
    path    => '/usr/bin',
    require => Class['docker']
  }
  ->exec { 'stop bs container':
    command => 'docker stop big-sibling',
    path    => ['/usr/bin', '/bin'],
    onlyif  => [$changed, $bs_running],
  }
  ->exec { 'remove bs container':
    command => 'docker rm big-sibling',
    path    => ['/usr/bin', '/bin'],
    onlyif  => $inspect_bs,
    unless  => $bs_running,
  }
  ->exec { 'run bs container':
    command => "docker run -d --privileged --net='host' --restart='always' --name='big-sibling' \
${socket_volume} ${proc_volume} ${env} ${image}",
    path    =>  ['/usr/bin', '/bin'],
    unless  => $bs_running,
  }
}
