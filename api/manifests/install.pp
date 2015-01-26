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
# [tsuru_host]          defines tsuru hostname
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
# [git_unit_repo]   is the path where tsuru will clone and manage the git repository in all units of an application
# [git_api_server]  is the address of the Gandalf API
# [git_rw_host]     is the host that will be used to build the push URL
# [git_ro_host]     is the host that units will use to clone code from users applications
#
# - Authentication configuration
#
# [auth_token_expire_days] this setting defines the amount of days that the token will be valid
# [auth_hash_cost]         this number indicates how many CPU time you’re willing to give to hashing calculation
# [auth_user_registration] this setting indicates whether user registration is enabled.
# [auth_scheme]            the authentication scheme to be used
# [oauth_client_id]        the client id provided by your OAuth server
# [oauth_client_secret]    the client secret provided by your OAuth server
# [oauth_scope]            the scope for your authentication request
# [oauth_auth_url]         the URL used in the authorization step of the OAuth flow
# [oauth_token_url]        the URL used in the exchange token step of the OAuth flow
# [oauth_info_url]         the URL used to fetch information about the authenticated user
# [oauth_collection]       the database collection used to store valid access tokens
# [oauth_callback_port]    the port used in the callback URL during the authorization step
#
# - Queue configuration
#
# [tsuru_queue]     is the name of the queue implementation that tsuru will use
# [redis_host]      is the host of the Redis server to be used for the working queue
# [redis_port]      is the port of the Redis server to be used for the working queue
# [redis_password]  is the password of the Redis server to be used for the working queue
# [redis_db]        is the database number of the Redis server to be used for the working queue
#
# - Admin users
#
# [tsuru_admin_team]  is the name of the administration team for the current tsuru installation
#
# - Quota management
#
# [tsuru_apps_per_user]  is the default value for apps per-user quota
# [tsuru_units_per_app]  is the default value for units per-app quota
#
# - Router configuration
#
# [hipache_redis_server]  redis server used by Hipache router
# [hipache_domain]        the domain of the server running your hipache server
#
# - Provisioner configuration
#
# [tsuru_provisioner]                          is the string the name of the provisioner that will be used by tsuru
# [docker_collection]                          database collection name used to store containers information
# [docker_repository_namespace]                docker repository namespace to be used for application and platform images
# [docker_router]                              router to be used to distribute requests to units
# [docker_deploy_cmd]                          the command that will be called in your platform when a new deploy happens
# [docker_segregate]                           enable segregate scheduler
# [docker_registry]                            for tsuru to work with multiple docker nodes, you will need a docker-registry
# [docker_cluster_mongo_url]                   connection URL to the mongodb server used to store information about the docker cluster
# [docker_mongo_database]                      database name to be used to store information about the docker cluster
# [docker_run_cmd_bin]                         the command that will be called on the application image to start the application
# [docker_run_cmd_port]                        the tcp port that will be exported by the container to the node network
# [docker_ssh_add_key_cmd]                     the command that will be called with the ssh public key created for the application
# [docker_ssh_user]                            the user used to connect via ssh to running containers
# [docker_healing_heal_nodes]                  boolean value that indicates whether tsuru should try to heal nodes that have failed a specified number of times
# [docker_healing_active_monitoring_interval]  number of seconds between calls to <server>/_ping in each one of the docker nodes
# [docker_healing_disabled_time]               number of seconds tsuru disables a node after a failure
# [docker_healing_max_failures]                number of consecutive failures a node should have before triggering a healing operation
# [docker_healing_wait_new_time]               number of seconds tsuru should wait for the creation of a new node during the healing process
# [docker_healing_heal_containers_timeout]     number of seconds a container should be unresponsive before triggering the recreation of the container
# [docker_healing_events_collection]           collection name in mongodb used to store information about triggered healing events
# [docker_healthcheck_max_time]                maximum time in seconds to wait for deployment time health check to be successful
#
# - IaaS configuration
#
# [tsuru_iaas_default]        define the default IaaS to tsuru use to create/list/delete your nodes (default to ec2)
# [cloudstack_apikey]         api-key to authenticate on IaaS
# [cloudstack_secretkey]      secret-key to authenticate on IaaS
# [cloudstack_api_url]        endpoint API to use the IaaS
# [cloudstack_collection]     collection to handle machine data on database.
# [cloudstack_node_protocol]  protocol to create node URL.
# [cloudstack_node_port]      port to create node URL
# [custom_iaas]               hash params to custom iaas with custom name as key
#
# - Debug configuration
#
# [tsuru_debug]
#
class api::install (

  $tsuru_server_version = 'latest',

  $tsuru_server_listen = '0.0.0.0:8080',
  $tsuru_host = 'http://0.0.0.0:8080',
  $tsuru_use_tls = undef,
  $tsuru_tls_cert_file = undef,
  $tsuru_tls_key_file = undef,

  $mongodb_url = 'localhost:27017',
  $mongodb_database_name = 'tsuru',
  $mongodb_database_password = undef,

  $smtp_server = undef,
  $smtp_user = undef,
  $smtp_password = undef,

  $git_unit_repo = '/home/application/current',
  $git_api_server = 'localhost:9090',
  $git_rw_host = undef,
  $git_ro_host = undef,

  $auth_token_expire_days = undef,
  $auth_hash_cost = undef,
  $auth_user_registration = true,
  $auth_scheme = 'native',
  $oauth_client_id = undef,
  $oauth_client_secret = undef,
  $oauth_scope = undef,
  $oauth_auth_url = undef,
  $oauth_token_url = undef,
  $oauth_info_url = undef,
  $oauth_collection = undef,
  $oauth_callback_port = undef,

  $tsuru_queue = 'redis',
  $redis_host = 'localhost',
  $redis_port = 6379,
  $redis_password = undef,
  $redis_db = undef,

  $tsuru_admin_team = 'admin',

  $tsuru_apps_per_user = undef,
  $tsuru_units_per_app = undef,

  $hipache_domain = 'cloud.tsuru.io',
  $hipache_redis_server = 'localhost:6379',

  $tsuru_provisioner = 'docker',
  $docker_segregate = false,
  $docker_registry = undef,
  $docker_router = 'hipache',
  $docker_collection = 'docker',
  $docker_repository_namespace = 'tsuru',
  $docker_deploy_cmd = '/var/lib/tsuru/deploy',
  $docker_cluster_mongo_url = 'localhost:27017',
  $docker_cluster_mongodb_db = 'tsuru',
  $docker_run_cmd_bin = '/var/lib/tsuru/start',
  $docker_run_cmd_port = '8888',
  $docker_ssh_add_key_cmd = '/var/lib/tsuru/add-key',
  $docker_public_key = '/var/lib/tsuru/.ssh/id_rsa.pub',
  $docker_user = 'tsuru',
  $docker_sshd_path = 'sudo /usr/sbin/sshd',
  $docker_healing_heal_nodes = undef,
  $docker_healing_active_monitoring_interval = undef,
  $docker_healing_disabled_time = undef,
  $docker_healing_max_failures = undef,
  $docker_healing_wait_new_time = undef,
  $docker_healing_heal_containers_timeout = undef,
  $docker_healing_events_collection = undef,
  $docker_healthcheck_max_time = undef,

  $tsuru_iaas_default = undef,
  $ec2_key_id = undef,
  $ec2_secret_key = undef,
  $ec2_user_data = undef,
  $ec2_wait_timeout = 300,
  $cloudstack_apikey = undef,
  $cloudstack_secretkey = undef,
  $cloudstack_api_url = undef,
  $cloudstack_user_data = undef,
  $iaas_node_protocol = undef,
  $iaas_node_port = undef,
  $custom_iaas = {},

  $tsuru_debug = false,

) inherits api {

  require base

  if ( !is_hash($custom_iaas) ){
    error '$custom_iaas must be hash formated iaas with custom name as key'
  }

  if ( !empty($custom_iaas) or $ec2_key_id or $cloudstack_apikey ){
    $iaas_enable = true
  } else {
    $iaas_enable = false
  }

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
