#
# == Class: registry
#
#  Tsuru registry node
#
# === Parameters
#
# [registry_ipbind_port] Registry ip X bind port
# [registry_path] Registry local path
# [registry_version] Registry package version
# [registry_user]
# [registry_group]
# [registry_storage] storages: s3 glance swift glance-swift elliptics gcs local
# [registry_venv_path] virtualenv to docker-registry installation

class registry (
  $registry_ipbind_port                = '0.0.0.0:8080',
  $registry_path                       = '/var/lib/docker-registry',
  $registry_version                    = latest,
  $registry_user                       = 'registry',
  $registry_group                      = 'registry',
  $registry_storage                    = 'local',
  $registry_venv_path                  = '/var/lib/venv',
  $gunicorn_max_requests               = 100,
  $gunicorn_workers                    = 3,
  $loglevel                            = undef,
  $debug                               = undef,
  $standalone                          = undef,
  $index_endpoint                      = undef,
  $storage_redirect                    = undef,
  $disable_token_auth                  = undef,
  $privileged_key                      = undef,
  $search_backend                      = undef,
  $sqlalchemy_index_database           = undef,
  $mirror_source                       = undef,
  $mirror_source_index                 = undef,
  $mirror_tags_cache_ttl               = undef,
  $cache_redis_host                    = undef,
  $cache_redis_port                    = undef,
  $cache_redis_db                      = undef,
  $cache_redis_password                = undef,
  $cache_lru_redis_host                = undef,
  $cache_lru_redis_port                = undef,
  $cache_lru_redis_db                  = undef,
  $cache_lru_redis_password            = undef,
  $smtp_host                           = undef,
  $smtp_port                           = undef,
  $smtp_login                          = undef,
  $smtp_password                       = undef,
  $smtp_secure                         = undef,
  $smtp_from_addr                      = undef,
  $smtp_to_addr                        = undef,
  $bugsnag                             = undef,
  $cors_origins                        = undef,
  $cors_methods                        = undef,
  $cors_headers                        = undef,
  $cors_expose_headers                 = undef,
  $cors_supports_credentials           = undef,
  $cors_max_age                        = undef,
  $cors_send_wildcard                  = undef,
  $cors_always_send                    = undef,
  $cors_automatic_options              = undef,
  $cors_vary_header                    = undef,
  $cors_resources                      = undef,
  $storage_path                        = undef,
  $aws_region                          = undef,
  $aws_bucket                          = undef,
  $aws_bucket                          = undef,
  $storage_path                        = undef,
  $aws_encrypt                         = undef,
  $aws_secure                          = undef,
  $aws_key                             = undef,
  $aws_secret                          = undef,
  $aws_use_sigv4                       = undef,
  $aws_host                            = undef,
  $aws_port                            = undef,
  $aws_calling_format                  = undef,
  $cf_base_url                         = undef,
  $cf_keyid                            = undef,
  $cf_keysecret                        = undef,
  $azure_storage_account_name          = undef,
  $azure_storage_account_key           = undef,
  $azure_storage_contaiNER             = undef,
  $azure_use_https                     = undef,
  $aws_bucket                          = undef,
  $aws_encrypt                         = undef,
  $aws_secure                          = undef,
  $storage_path                        = undef,
  $aws_key                             = undef,
  $aws_secret                          = undef,
  $aws_bucket                          = undef,
  $aws_host                            = undef,
  $aws_port                            = undef,
  $aws_debug                           = undef,
  $aws_calling_format                  = undef,
  $gcs_bucket                          = undef,
  $storage_path                        = undef,
  $gcs_secure                          = undef,
  $gcs_key                             = undef,
  $gcs_secret                          = undef,
  $gcs_oauth2                          = undef,
  $storage_path                        = undef,
  $glance_storage_alternate            = undef,
  $storage_path                        = undef,
  $elliptics_nodes                     = undef,
  $elliptics_wait_timeout              = undef,
  $elliptics_check_timeout             = undef,
  $elliptics_io_thread_num             = undef,
  $elliptics_net_thread_num            = undef,
  $elliptics_nonblocking_io_thread_num = undef,
  $elliptics_groups                    = undef,
  $elliptics_verbosity                 = undef,
  $elliptics_logfile                   = undef,
  $elliptics_addr_family               = undef,
  $storage_path                        = undef,
  $oss_host                            = undef,
  $oss_bucket                          = undef,
  $oss_key                             = undef,
  $oss_secret                          = undef,
  $loglevel                            = undef,
  $debug                               = undef,
  $search_backend                      = undef,
  $storage_path                        = undef,
  $storage_path                        = undef,
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

  python::virtualenv { $registry_venv_path :
    ensure       => present,
    version      => 'system',
    owner        => 'root',
    group        => 'root'
  }

  file { "${registry_path}/config.yml":
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

  if ( $registry_storage == local and mkdir_p($registry_path) ) {
    file { $registry_path:
      ensure  => directory,
      mode    => '0755',
      owner   => $registry_user,
      group   => $registry_group,
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
