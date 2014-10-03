#
# == Class: api::install
#
# Installs and configures tsuru api
#
# === Parameters
#
# [tsuru_server_version] package tsuru-server to be installed.
#
# === tsuru configuration parameters
#
# See more information in the config docs http://docs.tsuru.io/en/latest/reference/config.html
#
# - HTTP Server
#
# [tsuru_server_listen] defines in which address tsuru webserver will listen
# [tsuru_use_tls]       indicates whether tsuru should use TLS or not
# [tsuru_tls_cert_file] is the path to the X.509 certificate file configured to serve the domain
# [tsuru_tls_key_file]  is the path to private key file configured to serve the domain
#
# - Database access
#
# [mongodb_url]           is the database connection string
# [mongodb_database_name] is the name of the database that tsuru uses
#
# - Email configuration
#
# [smtp_server]   is the SMTP server to connect to
# [smtp_user]     is the user to authenticate with the SMTP sever
# [smtp_password] is the password for authentication within the SMTP server
#
# - Git configuration
#
# [git_unit_repo] is the path where tsuru will clone and manage the git repository in all units of an application
# [git_api_server] is the address of the Gandalf API
# [git_rw_host] is the host that will be used to build the push URL
# [git_ro_host] is the host that units will use to clone code from users applications

# auth_token_expire_days = 7
# auth_hash_cost = 10
# auth_user_registration = true
# auth_scheme = 'native'
# oauth_client_id
# oauth_client_secret
# oauth_scope
# oauth_auth_url
# oauth_token_url
# oauth_info_url
# oauth_collection
# oauth_callback_port

# redis_host = '127.0.0.1'
# redis_port = 6379
# redis_pool_max_idle_conn = 1

# tsuru_admin_team
# tsuru_apps_per_user = 4
# tsuru_units_per_app = 40
# tsuru_server_domain

# tsuru_provisioner = 'docker'
# docker_memory = 512
# docker_swap = 1024
# docker_segregate = true
# docker_registry_server
# docker_mongodb_collection = 'docker'
# docker_repository_namespace = 'tsuru'
# docker_router = 'hipache'
# docker_deploy_cmd = '/var/lib/tsuru/deploy'
# docker_cluster_storage = 'mongo'
# docker_cluster_mongodb_db = 'tsuru_cluster'
# docker_run_cmd_bin = '/var/lib/tsuru/start'
# docker_run_cmd_port = '8888'
# docker_ssh_add_key_cmd = '/var/lib/tsuru/add-key'
# docker_public_key = '/var/lib/tsuru/.ssh/id_rsa.pub'
# docker_user = 'tsuru'
# docker_sshd_path 'sudo /usr/sbin/sshd'

# tsuru_iaas_default
# cloudstack_apikey
# cloudstack_secretkey
# cloudstack_api_url
# cloudstack_user_data
# cloudstack_node_protocol
# cloudstack_node_port
# tsuru_debug = false



class api::install (

  $tsuru_server_version = latest,

  $tsuru_server_listen = '0.0.0.0:8080',
  $tsuru_use_tls,
  $tsuru_tls_cert_file,
  $tsuru_tls_key_file,

  $mongodb_url = '127.0.0.1:27071',
  $mongodb_database_name = 'tsuru',
  $smtp_server,
  $smtp_user,
  $smtp_password,

  $git_unit_repo = '/home/application/current',
  $git_url,
  $git_rw_host,
  $git_ro_host,

  $auth_token_expire_days = 7,
  $auth_hash_cost = 10,
  $auth_user_registration = true,
  $auth_scheme = 'native',
  $oauth_client_id,
  $oauth_client_secret,
  $oauth_scope,
  $oauth_auth_url,
  $oauth_token_url,
  $oauth_info_url,
  $oauth_collection,
  $oauth_callback_port,

  $redis_host = '127.0.0.1',
  $redis_port = 6379,
  $redis_pool_max_idle_conn = 1,

  $tsuru_admin_team,
  $tsuru_apps_per_user = 4,
  $tsuru_units_per_app = 40,
  $tsuru_server_domain,

  $tsuru_provisioner = 'docker',
  $docker_memory = 512,
  $docker_swap = 1024,
  $docker_segregate = true,
  $docker_registry_server,
  $docker_mongodb_collection = 'docker',
  $docker_repository_namespace = 'tsuru',
  $docker_router = 'hipache',
  $docker_deploy_cmd = '/var/lib/tsuru/deploy',
  $docker_cluster_storage = 'mongo',
  $docker_cluster_mongodb_db = 'tsuru_cluster',
  $docker_run_cmd_bin = '/var/lib/tsuru/start',
  $docker_run_cmd_port = '8888',
  $docker_ssh_add_key_cmd = '/var/lib/tsuru/add-key',
  $docker_public_key = '/var/lib/tsuru/.ssh/id_rsa.pub',
  $docker_user = 'tsuru',
  $docker_sshd_path 'sudo /usr/sbin/sshd',

  $tsuru_iaas_default,
  $cloudstack_apikey,
  $cloudstack_secretkey,
  $cloudstack_api_url,
  $cloudstack_user_data,
  $cloudstack_node_protocol,
  $cloudstack_node_port,
  $tsuru_debug = false,

){

  require api
  require base

  package { 'tsuru-server' :
    ensure => $tsuru_server_version
  }

  file { '/etc/tsuru/tsuru.conf' :
    content => template('api/tsuru.conf.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['tsuru-server']
  }

  file { $api::init_file_name:
    content => template('api/tsuru-server.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['tsuru-server']
  }

  # Services
  service { 'tsuru-server-api' :
    ensure     => running,
    enable     => true,
    provider   => $api::service_provider,
    subscribe  => [ File['/etc/tsuru/tsuru.conf'], File[$api::init_file_name], Package['tsuru-server'] ],
    require    => Package['tsuru-server']
  }

}
