#
# == Class: registry
#
#  Tsuru registry node
#
# === Parameters
#
# [ipbind_port] Registry ip X bind port
# [path] Registry local path
# [version] Registry package version
# [user] Registre user name
# [group] Registre group name
# [storage] storages: s3 glance swift glance-swift elliptics gcs local
# [venv_path] virtualenv to docker-registry installation

class registry (
  $ipbind_port                         = '0.0.0.0:8080',
  $version                             = latest,
  $user                                = 'registry',
  $group                               = 'registry',
  $storage                             = 'local',
  $venv_path                           = '/var/lib/venv',
  $gunicorn_max_requests               = 100,
  $gunicorn_workers                    = 3,
  $storage                             = 'local',
  $loglevel                            = 'info',
  $debug                               = 'false',
  $standalone                          = 'true',
  $index_endpoint                      = 'https://index.docker.io',
  $storage_redirect                    = undef,
  $disable_token_auth                  = undef,
  $privileged_key                      = undef,
  $search_backend                      = undef,
  $sqlalchemy_index_database           = 'sqlite:////tmp/docker-registry.db',
  $mirror_source                       = undef,
  $mirror_source_index                 = undef,
  $mirror_tags_cache_ttl               = '172800',
  $cache_redis_host                    = undef,
  $cache_redis_port                    = undef,
  $cache_redis_db                      = '0',
  $cache_redis_password                = undef,
  $cache_lru_redis_host                = undef,
  $cache_lru_redis_port                = undef,
  $cache_lru_redis_db                  = '0',
  $cache_lru_redis_password            = undef,
  $smtp_host                           = undef,
  $smtp_port                           = 25,
  $smtp_login                          = undef,
  $smtp_password                       = undef,
  $smtp_secure                         = 'false',
  $smtp_from_addr                      = 'docker-registry@localdomain.local',
  $smtp_to_addr                        = 'noise+dockerregistry@localdomain.local',
  $bugsnag                             = undef,
  $cors_origins                        = undef,
  $cors_methods                        = undef,
  $cors_headers                        = '[Content-Type]',
  $cors_expose_headers                 = undef,
  $cors_supports_credentials           = undef,
  $cors_max_age                        = undef,
  $cors_send_wildcard                  = undef,
  $cors_always_send                    = undef,
  $cors_automatic_options              = undef,
  $cors_vary_header                    = undef,
  $cors_resources                      = undef,
  $local_storage_path                  = '/tmp/registry',
  $aws_region                          = undef,
  $aws_bucket                          = undef,
  $aws_storage_path                    = '/registry',
  $aws_encrypt                         = true,
  $aws_secure                          = true,
  $aws_key                             = undef,
  $aws_secret                          = undef,
  $aws_use_sigv4                       = undef,
  $aws_host                            = undef,
  $aws_port                            = undef,
  $aws_debug                           = 0,
  $aws_calling_format                  = undef,
  $cf_base_url                         = undef,
  $cf_keyid                            = undef,
  $cf_keysecret                        = undef,
  $azure_storage_account_name          = undef,
  $azure_storage_account_key           = undef,
  $azure_storage_container             = 'registry',
  $azure_use_https                     = true,
  $gcs_bucket                          = undef,
  $gcs_storage_path                    = '/registry',
  $gcs_secure                          = true,
  $gcs_key                             = undef,
  $gcs_secret                          = undef,
  $gcs_oauth2                          = false,
  $os_storage_path                     = undef,
  $os_auth_url                         = undef,
  $os_container                        = undef,
  $os_container                        = undef,
  $os_password                         = undef,
  $os_tenant_name                      = undef,
  $os_region_name                      = undef,
  $glance_storage_alternate            = file,
  $glance_storage_path                 = '/tmp/registry',
  $elliptics_nodes                     = undef,
  $elliptics_wait_timeout              = 60,
  $elliptics_check_timeout             = 60,
  $elliptics_io_thread_num             = 2,
  $elliptics_net_thread_num            = 2,
  $elliptics_nonblocking_io_thread_num = 2,
  $elliptics_groups                    = undef,
  $elliptics_verbosity                 = 4,
  $elliptics_logfile                   = '/dev/stderr',
  $elliptics_addr_family               = 2,
  $oss_storage_path                    = '/registry/',
  $oss_host                            = undef,
  $oss_bucket                          = undef,
  $oss_key                             = undef,
  $oss_secret                          = undef,
  $dev_loglevel                        = 'debug',
  $dev_debug                           = true,
  $dev_search_backend                  = 'sqlalchemy',
  $test_storage_path                   = './tmp/test',
  $prod_storage_path                   = '/prod',
) {

  require base

  $packages = [ 'liblzma-dev', 'libyaml-dev' ]
  package { $packages:
    ensure => installed
  }

  class { 'python':
    version    => 'system',
    dev        => true,
    virtualenv => true,
  }

  python::virtualenv { $venv_path :
    ensure       => present,
    version      => 'system',
    owner        => 'root',
    group        => 'root'
  }

  file { "${path}/config.yml":
    ensure  => present,
    content => template('registry/config.yml.erb'),
    mode    => '0644',
    owner   => 'root',
    group   => 'root'
  }

  file { '/etc/init/docker-registry.conf':
    ensure  => present,
    content => template('registry/docker-registry.conf.erb'),
    mode    => '0644',
    owner   => root,
    group   => root,
    notify  => Service['docker-registry'],
  }

  if ( $storage == local and mkdir_p($path) ) {
    file { $path:
      ensure  => directory,
      mode    => '0755',
      owner   => $user,
      group   => $group,
      notify  => Service['docker-registry']
    }
  }

  service { 'docker-registry':
    ensure     => running,
    enable     => true,
    provider   => 'upstart',
    subscribe  => File['/etc/init/docker-registry.conf'],
    require    => [ File['/etc/init/docker-registry.conf'],
                    Python::Gunicorn['docker-registry'] ]
  }

}
