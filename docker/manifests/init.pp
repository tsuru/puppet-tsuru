#
# == Class: docker
#
#  Tsuru docker node
#
# === Parameters
#
# [tsuru_server_version] Package tsuru-server version
# [lxc_docker_version] LXC docker package version
# [docker_graph_dir] Docker root directory where all files are located
# [docker_exec_driver] Choose between native(default) or lxc
# [docker_bind] Docker bind host:port. Socker default
# [docker_extra_opts] Extra opts to docker daemon
# [log_to_syslog] Log output and stderr also to syslog


class docker (
  $tsuru_server_version         = latest,
  $lxc_docker_version           = latest,
  $docker_graph_dir             = '/var/lib/docker',
  $docker_exec_driver           = 'native',
  $docker_bind                  = undef,
  $docker_extra_opts            = '',
  $log_to_syslog                = true
) {

  require base

  file { '/etc/profile.d/docker.sh' :
    content => inline_template('alias docker="docker -H=tcp://localhost:4243"'),
    mode    => '0755'
  }

  package { 'lxc-docker' :
    ensure  => $lxc_docker_version,
    notify  => Service['docker']
  }

  service { 'docker':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    subscribe  => File['/etc/default/docker'],
    provider   => 'upstart',
    require    => [ Package['lxc-docker'], File['/etc/init/docker.conf'] ]
  }

  file { '/etc/init/docker.conf':
    ensure  => present,
    content => template('docker/init-docker.conf.erb'),
    mode    => '0644',
    owner   => root,
    group   => root,
  }

  $docker_bind_opts = $docker_bind ? { undef => '', default => "-H ${docker_bind}" }
  $docker_opts = join([ "-g $docker_graph_dir", "-e ${docker_exec_driver}", $docker_bind_opts, $docker_extra_opts ]," ")

  file { '/etc/default/docker':
    ensure  => present,
    content => template('docker/default-docker.erb'),
    mode    => '0644',
    owner   => root,
    group   => root,
    notify  => Service['docker']
  }

  Class['base']->Class['docker']

}
