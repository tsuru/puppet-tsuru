#
# == Class: docker
#
#  Tsuru docker node
#
# === Parameters
#
# [docker_version] LXC docker package version
# [docker_graph_dir] Docker root directory where all files are located
# [docker_bind] Docker bind array options. Eg ['tcp://0.0.0.0:4243', 'unix:///var/run/docker.sock']
# [docker_extra_opts] Extra opts to docker daemon
# [log_to_syslog] Log output and stderr also to syslog


class docker (
  $docker_version               = latest,
  $docker_graph_dir             = '/var/lib/docker',
  $docker_bind                  = [],
  $docker_extra_opts            = '',
  $log_to_syslog                = true,
  $proxy_url                    = undef
) {

  if (!is_array($docker_bind)) {
    fail('\$docker_bind must be an array')
  }

  if (versioncmp($docker_version, '1.9.1') <= 0 and $docker_version != latest) {
    fail('\$docker_version must be greater than 1.9.1')
  }

  if (versioncmp($docker_version, '5:18.09.2') >=0 or versioncmp($docker_version, '17.03.2') >=0 or $docker_version == latest) {
    $docker_package = 'docker-ce'
  } else {
    $docker_package = 'docker-engine'
  }

  package { $docker_package:
    ensure  => $docker_version,
    require => File['/etc/default/docker']
  }

  $docker_bind_join = join($docker_bind, ' -H ')

  if ($docker_bind_join) {
    $docker_bind_opts = "-H ${docker_bind_join}"
  } else {
    $docker_bind_opts = ''
  }

  $docker_opts = join(["-g ${docker_graph_dir}", $docker_bind_opts, $docker_extra_opts ],' ')

  service { 'docker':
    ensure  => running,
    enable  => true,
    require => Package[$docker_package]
  }

  file { '/etc/default/docker':
    ensure  => present,
    content => template('docker/default-docker.erb'),
    mode    => '0644',
    owner   => root,
    group   => root,
  }

}
