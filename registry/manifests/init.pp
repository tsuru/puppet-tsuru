#
# == Class: registry
#
#  Tsuru registry node
#
# === Parameters
#
# [lxc_docker_version] LXC docker package version
# [docker_graph_dir] Docker root directory where all files are located
# [docker_bind] Docker bind array options. Eg ['tcp://0.0.0.0:4243', 'unix:///var/run/docker.sock']
# [docker_extra_opts] Extra opts to docker daemon
# [registry_install_command]
# [registry_start_command]
# [proxy_url]
class registry (
  $lxc_docker_version = 'latest',
  $docker_graph_dir = undef,
  $docker_bind = undef,
  $docker_extra_opts = undef,
  $registry_install_command = undef,
  $registry_start_command = undef,
  $proxy_url = undef
  ){

  class { 'docker':
    lxc_docker_version           => $lxc_docker_version,
    docker_graph_dir             => $docker_graph_dir,
    docker_bind                  => $docker_bind,
    docker_extra_opts            => $docker_extra_opts,
    proxy_url                    => $proxy_url,
  }

  exec { 'install registry':
    command => $registry_install_command,
    path    => '/usr/bin',
    require => Class['docker']
  }

  exec { 'start registry':
    command => $registry_start_command,
    path    =>  '/usr/bin',
    unless  =>  '/usr/bin/docker inspect --format="{{ .State.Running }}" $(docker ps -q)',
    require => Exec['install registry']
  }

}
