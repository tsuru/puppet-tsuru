#
# == Class: tsuru::docker
#
#  Tsuru docker node
#
# === Parameters
#
# [tsuru_ssh_agent] Install tsuru-ssh-agent on docker node
# [tsuru_server_version] Package tsuru-server version
# [lxc_docker_version] LXC docker package version
# [tsuru_ssh_agent_private_key] Private key used to access docker containers.
#                               Must be the same on all tsuru docker nodes
# [tsuru_ssh_agent_user] User used to run tsuru-ssh-agent (default to ubuntu)
# [tsuru_ssh_agent_group] Group used to run tsuru-ssh-agent (default to ubuntu)
# [docker_graph_dir] Docker root directory where all files are located
# [docker_exec_driver] Choose between native(default) or lxc
# [docker_bind] Docker bind host:port. Socker default
# [docker_extra_opts] Extra opts to docker daemon


class tsuru::docker (
  $tsuru_ssh_agent              = false,
  $tsuru_server_version         = latest,
  $lxc_docker_version           = latest,
  $tsuru_ssh_agent_private_key  = undef,
  $tsuru_ssh_agent_user         = undef,
  $tsuru_ssh_agent_group        = undef,
  $docker_graph_dir             = '/var/lib/docker',
  $docker_exec_driver           = 'native',
  $docker_bind                  = undef,
  $docker_extra_opts            = ''
) {

  require tsuru::params

  if ($tsuru_ssh_agent) {

    package { 'tsuru-server' :
      ensure => $tsuru_server_version
    }

    file { '/etc/init/tsuru-ssh-agent.conf':
      ensure  => present,
      content => template('tsuru/docker/init-tsuru-ssh-agent.conf.erb'),
      mode    => '0644',
      owner   => root,
      group   => root,
      notify  => Service['tsuru-ssh-agent']
    }

    file { '/etc/default/tsuru-server':
      ensure  => present,
      content => template('tsuru/docker/default-tsuru-server.erb'),
      mode    => '0644',
      owner   => root,
      group   => root,
      notify  => Service['tsuru-ssh-agent']
    }

    service { 'tsuru-ssh-agent':
      ensure     => running,
      enable     => true,
      hasrestart => false,
      hasstatus  => true,
      subscribe  => [ File['/etc/default/tsuru-server'],
                      File['/etc/init/tsuru-ssh-agent.conf'],
                      Package['tsuru-server'] ],
      provider   => 'upstart',
      require    => [ Package['tsuru-server'],
                      File['/etc/default/tsuru-server'] ]
    }

  }

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
    subscribe  => [ File['/etc/init/docker.conf'],
                    File['/etc/default/docker'] ],
    provider   => 'upstart',
    require    => [ Package['lxc-docker'], File['/etc/init/docker.conf'] ]
  }

  file { '/etc/init/docker.conf':
    ensure  => present,
    content => template('tsuru/docker/init-docker.conf.erb'),
    mode    => '0644',
    owner   => root,
    group   => root,
    notify  => Service['docker']
  }

  $docker_bind_opts = $docker_bind ? { undef => '', default => "-H ${docker_bind}" }
  $docker_opts = join([ "-g $docker_graph_dir", "-e ${docker_exec_driver}", $docker_bind_opts, $docker_extra_opts ]," ")
  file { '/etc/default/docker':
    ensure  => present,
    content => template('tsuru/docker/default-docker.erb'),
    mode    => '0644',
    owner   => root,
    group   => root,
    notify  => Service['docker']
  }

  Class['tsuru::params']->Class['tsuru::docker']

}
