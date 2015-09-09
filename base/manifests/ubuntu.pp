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

  apt::key { 'nginx_dev':
    key         => 'C300EE8C',
    key_content => $base::nginx_dev_pub_key
  }

  if ($base::redis_source_list) {
    apt::source { 'redis':
      location      => $base::redis_source_list,
      include_src   => false,
      repos         => 'main',
      release       => $base::redis_release,
      require       => Apt::Key['tsuru']
    }
  } else {
    apt::ppa { 'ppa:tsuru/redis-server':
      release     => $base::redis_release,
      require     => Apt::Key['tsuru']
    }
  }

  if ($base::tsuru_source_list) {
    apt::source { 'tsuru':
      location    => $base::tsuru_source_list,
      include_src => false,
      repos       => 'main',
      release     => $base::tsuru_release,
      require     => Apt::Key['tsuru']
    }
  } else {
    apt::ppa { 'ppa:tsuru/ppa':
      release     => $base::tsuru_release,
      require     => Apt::Key['tsuru']
    }
  }

  # Tsuru RC
  if ($base::tsuru_rc_source_list or $base::enable_tsuru_rc) {
    if ($base::tsuru_rc_source_list) {
      apt::source { 'tsuru_rc':
        location    => $base::tsuru_rc_source_list,
        include_src => false,
        repos       => 'main',
        release     => $base::tsuru_rc_release,
        require     => Apt::Key['tsuru']
      }
    } else {
      apt::ppa { 'ppa:tsuru/rc':
        release     => $base::tsuru_rc_release,
        require     => Apt::Key['tsuru']
      }
    }
  }

  if ($base::docker_source_list) {
    apt::source { 'docker' :
      location    => $base::docker_source_list,
      include_src => false,
      repos       => 'main',
      release     => $base::docker_release,
      require     => [Apt::Key['docker'], Apt::Key['docker_project']]
    }
  } else {
    apt::source { 'docker' :
      location    => 'https://get.docker.io/ubuntu',
      include_src => false,
      repos       => 'main',
      release     => 'docker',
      require     => [Apt::Key['docker'], Apt::Key['docker_project']]
    }
  }

  if ($base::nginx_dev_source_list) {
    apt::source { 'nginx_dev' :
      location    => $base::nginx_dev_source_list,
      include_src => false,
      repos       => 'main',
      release     => $base::nginx_dev_release,
      require     => Apt::Key['nginx_dev']
    }
  } else {
    apt::source { 'nginx_dev' :
      location    => 'http://ppa.launchpad.net/nginx/development/ubuntu/',
      include_src => false,
      repos       => 'main',
      release     => $base::nginx_dev_release,
      require     => Apt::Key['nginx_dev']
    }
  }

}
