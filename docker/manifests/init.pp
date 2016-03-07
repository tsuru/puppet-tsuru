#
# == Class: docker
#
#  Tsuru docker node
#
# === Parameters
#
# [lxc_docker_version] LXC docker package version
# [docker_graph_dir] Docker root directory where all files are located
# [docker_bind] Docker bind array options. Eg ['tcp://0.0.0.0:4243', 'unix:///var/run/docker.sock']
# [docker_extra_opts] Extra opts to docker daemon
# [log_to_syslog] Log output and stderr also to syslog


class docker (
  $lxc_docker_version           = latest,
  $docker_graph_dir             = '/var/lib/docker',
  $docker_bind                  = [],
  $docker_extra_opts            = '',
  $log_to_syslog                = true,
  $proxy_url                    = undef
) {

  if (!is_array($docker_bind)) {
    fail('\$docker_bind must be an array')
  }

  package { 'docker-engine':
    ensure  => $lxc_docker_version,
    require => [ File['/etc/default/docker'], File['/etc/init/docker.conf'] ]
  }

  $docker_bind_join = join($docker_bind, ' -H ')

  if ($docker_bind_join) {
    $docker_bind_opts = "-H ${docker_bind_join}"
  } else {
    $docker_bind_opts = ''
  }

  $docker_opts = join(["-g ${docker_graph_dir}", $docker_bind_opts, $docker_extra_opts ],' ')

  file { '/etc/default/docker':
    ensure  => present,
    content => template('docker/default-docker.erb'),
    mode    => '0644',
    owner   => root,
    group   => root
  }

  file { '/etc/init/docker.conf':
    ensure  => present,
    content => template('docker/init-docker.conf.erb'),
    mode    => '0644',
    owner   => root,
    group   => root,
  }

}
