#
# == Class: api
#
# Installs and configures
#
class api {

  $init_file_name = $::operatingsystem ? {
    Ubuntu  => '/etc/default/tsuru-server',
    CentOS  => '/etc/init.d/tsuru-server',
    default => fail('OS not supported'),
  }

  $service_provider = $::operatingsystem ? {
    Ubuntu  => 'upstart',
    CentOS  => 'init',
    default => fail('OS not supported'),
  }

}
