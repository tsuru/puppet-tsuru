# class tsuru::api
class tsuru::api (
  $tsuru_server_version = latest,
  $tsuru_collector_server = undef,
  $tsuru_app_domain,
  $tsuru_server_bind = '0.0.0.0:80',
  $tsuru_api_server_url,
  $tsuru_mongodb_url = '127.0.0.1:27071',
  $tsuru_mongodb_database = 'tsuru',
  $tsuru_git_url,
  $tsuru_git_rw_host,
  $tsuru_git_ro_host,
  $tsuru_redis_master,
  $tsuru_registry_server,
  $tsuru_segregate = false,
  $tsuru_docker_servers_urls,
  $tsuru_docker_redis_prefix = 'docker-cluster',
  $tsuru_docker_container_port = 8888,
  $tsuru_docker_container_public_key = '/var/lib/tsuru/.ssh/id_rsa.pub',
  $tsuru_queue_server = '127.0.0.1:11300',
  $tsuru_quota_apps_per_user = 4,
  $tsuru_quota_units_per_app = 40,
  $tsuru_smtp_server = localhost,
  $tsuru_smtp_from = 'tsuru@localdomain'
){

  require tsuru::params

  if ( $tsuru_collector_server == $::hostname) {
    $tsuru_server_collector_ensure = 'running'
    $beanstalkd_package_ensure = 'latest'
    $beanstalkd_file_ensure = 'file'

    service { 'beanstalkd' :
      ensure    => running,
      enable    => true,
      subscribe => File['/etc/default/beanstalkd'],
      require   => Package['beanstalkd']
    }

  } else {
    $tsuru_server_collector_ensure = 'stopped'
    $beanstalkd_package_ensure = purged
    $beanstalkd_file_ensure = 'absent'
  }

  package { 'tsuru-server' :
    ensure => $tsuru_server_version
  }

  package { 'beanstalkd' :
    ensure => $beanstalkd_package_ensure
  }

  file { '/etc/tsuru/tsuru.conf' :
    content => template('tsuru/api/tsuru.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['tsuru-server']
  }

  file { '/etc/default/tsuru-server' :
    content => template('tsuru/api/tsuru-server.default.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['tsuru-server']
  }

  file { '/etc/default/beanstalkd' :
    ensure  => $beanstalkd_file_ensure,
    source  => 'puppet:///modules/tsuru/api/beanstalkd.default',
    owner   => 'root',
    group   => 'root',
    mode    => '0644'
  }

  # Services
  service { 'tsuru-server-api':
    ensure     => running,
    enable     => true,
    provider   => 'upstart',
    subscribe  => [ File['/etc/tsuru/tsuru.conf'], File['/etc/default/tsuru-server'], Package['tsuru-server'] ],
    require    => Package['tsuru-server']
  }


  service { 'tsuru-server-collector' :
    ensure    => $tsuru_server_collector_ensure,
    enable    => true,
    provider  => 'upstart',
    subscribe  => [ File['/etc/tsuru/tsuru.conf'], File['/etc/default/tsuru-server'], Package['tsuru-server'] ],
    require   => Package['tsuru-server']
  }

}
