class tsuru::docker (
  $tsuru_ssh_agent              = false,
  $tsuru_server_version         = latest,
  $lxc_docker_version           = latest,
  $tsuru_ssh_agent_private_key  = undef
) {

  include tsuru::params

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
      subscribe  => [ File['/etc/default/tsuru-server'], File['/etc/init/tsuru-ssh-agent.conf'], Package['tsuru-server'] ],
      provider   => 'upstart',
      require    => [ Package['tsuru-server'], File['/etc/default/tsuru-server'] ]
    }

  }

  file { '/etc/profile.d/docker.sh' :
    content => inline_template("alias docker='docker -H=localhost'"),
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
    subscribe  => File['/etc/init/docker.conf'],
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

  Class['tsuru::params']->Class['tsuru::docker']

}
