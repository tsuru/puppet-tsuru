#
# == Class: base::ubuntu
#
#  base used by other tsuru classes installed on Ubuntu.
#

class base::ubuntu inherits base {

  class { 'apt':
        always_apt_update => true,
        disable_keys      => true,
        update_timeout    => 600
  }

  apt::key { 'tsuru':
    key         => '383F073D',
    key_content => $base::tsuru_pub_key
  }

  apt::key { 'docker':
    key         => 'A88D21E9',
    key_content => $base::docker_pub_key
  }

  apt::key {'docker_project':
    key         => '2C52609D',
    key_content => $base::docker_project_pub_key
  }

  if ($base::tsuru_source_list) {
    apt::source { 'tsuru':
      location    => $base::tsuru_source_list,
      include_src => false,
      repos       => $base::tsuru_repos,
      release     => $base::tsuru_release,
      require     => Apt::Key['tsuru']
    }
  } else {
    apt::ppa { 'ppa:tsuru/ppa':
      release => $base::tsuru_release,
      require => Apt::Key['tsuru']
    }
  }

  # Tsuru RC
  if ($base::tsuru_rc_source_list or $base::enable_tsuru_rc) {
    if ($base::tsuru_rc_source_list) {
      apt::source { 'tsuru_rc':
        location    => $base::tsuru_rc_source_list,
        include_src => false,
        repos       => $base::tsuru_rc_repos,
        release     => $base::tsuru_rc_release,
        require     => Apt::Key['tsuru']
      }
    } else {
      apt::ppa { 'ppa:tsuru/rc':
        release => $base::tsuru_rc_release,
        require => Apt::Key['tsuru']
      }
    }
  }

  if ($base::docker_source_list) {
    apt::source { 'docker' :
      location    => $base::docker_source_list,
      include_src => false,
      repos       => $base::docker_repos,
      release     => $base::docker_release,
      require     => [Apt::Key['docker'], Apt::Key['docker_project']]
    }
  } else {
    apt::source { 'docker' :
      location    => 'https://apt.dockerproject.org/repo',
      include_src => false,
      repos       => 'main',
      release     => 'ubuntu-trusty',
      require     => [Apt::Key['docker'], Apt::Key['docker_project']]
    }
  }

}
