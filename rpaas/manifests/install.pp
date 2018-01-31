# class rpaas::install
class rpaas::install (

  $nginx_package                     = 'latest',
  $nginx_user                        = 'www-data',
  $nginx_group                       = 'www-data',
  $nginx_worker_processes            = 'auto',
  $nginx_worker_connections          = 1024,
  $nginx_listen                      = 8080,
  $nginx_ssl_listen                  = 8443,
  $nginx_http2                       = false,
  $nginx_admin_listen                = 8089,
  $nginx_admin_ssl_listen            = 8090,
  $nginx_admin_enable_ssl            = false,
  $nginx_key_zone_size               = '10m',
  $nginx_cache_inactive              = '3d',
  $nginx_cache_size                  = '3g',
  $nginx_loader_files                = 50,
  $nginx_location_purge              = true,
  $nginx_allow_admin_list            = ['127.0.0.0/24','127.1.0.0/24'],
  $nginx_custom_error_dir            = undef,
  $nginx_custom_error_codes          = {},
  $nginx_intercept_errors            = false,
  $nginx_local_log                   = true,
  $nginx_syslog_server               = undef,
  $nginx_syslog_tag                  = undef,
  $nginx_dhparams                    = undef,
  $nginx_vts_enabled                 = false,
  $nginx_lua                         = false,
  $nginx_admin_locations             = false,
  $nginx_request_id_enabled          = false,
  $nginx_disable_response_request_id = false,
  $nginx_upstream_keepalive          = 100,
  $consul_template_version           = latest,
  $consul_server                     = undef,
  $consul_syslog_enabled             = true,
  $consul_syslog_facility            = 'LOCAL0',
  $consul_acl_token                  = undef,
  $rpaas_service_name                = undef,
  $rpaas_instance_name               = undef,
  $consul_agent_enable               = false,
  $consul_agent_encrypt              = undef,
  $consul_agent_data_dir             = '/var/lib/consul',
  $consul_agent_version              = latest,
  $consul_agent_datacenter           = 'dc1',
  $consul_agent_client_addr          = '0.0.0.0',
  $consul_agent_bind_addr            = '0.0.0.0',
  $consul_members                    = ['127.0.0.1'],
  $sysctl_somaxconn                  = 2048,
  $sysctl_max_syn_backlog            = 512

) inherits rpaas {

  include base
  include sudo

  if ($nginx_custom_error_codes != {} and !$nginx_custom_error_dir) {
    fail('nginx_custom_error_dir must be set with nginx_custom_error_codes')
  }

  if ($nginx_custom_error_codes and !is_hash($nginx_custom_error_codes)) {
    fail('nginx_custom_error_codes should be in hash format')
  }

  if ($consul_agent_enable) {

    package { 'consul':
      ensure => $consul_agent_version
    }

    file { $consul_agent_data_dir:
      ensure  => directory,
      owner   => 'consul',
      group   => 'consul',
      require => Package['consul']
    }

    service { 'consul':
      ensure  => running,
      enable  => true,
      require => [ Package['consul'], File[$consul_agent_data_dir] ]
    }

    file { '/etc/consul.d/config.json':
      ensure  => file,
      mode    => '0644',
      content => template('rpaas/consul/agent_config.json.erb'),
      require => Package['consul'],
      notify  => Service['consul']
    }

    file { '/etc/consul.d/service.json':
      ensure  => file,
      mode    => '0644',
      content => template('rpaas/consul/nginx_service.json.erb'),
      require => Package['consul'],
      notify  => Service['consul']
    }

    file { '/usr/local/bin/check_ro_fs.sh':
      ensure => file,
      mode   => '0755',
      source => 'puppet:///modules/rpaas/check_ro_fs.sh'
    }

  }

  package { 'consul-template':
    ensure => $consul_template_version,
  }

  file { '/etc/consul-template.d/templates':
    ensure  => directory,
    require => Package['consul-template']
  }

  file { '/etc/consul-template.d/plugins':
    ensure  => directory,
    require => Package['consul-template']
  }

  file { '/etc/consul-template.d/consul.conf':
    ensure  => file,
    content => template('rpaas/consul/consul.conf.erb'),
    require => Package['consul-template']
  }

  file { '/etc/consul-template.d/templates/locations.conf.tpl':
    ensure  => file,
    content => template('rpaas/consul/locations.conf.tpl.erb'),
    require => File['/etc/consul-template.d/templates']
  }

  file { '/etc/consul-template.d/templates/upstreams.conf.tpl':
    ensure  => file,
    content => template('rpaas/consul/upstreams.conf.tpl.erb'),
    require => File['/etc/consul-template.d/templates']
  }

  file { '/etc/consul-template.d/templates/nginx.key.tpl':
    ensure  => file,
    content => template('rpaas/consul/nginx.key.tpl.erb'),
    require => File['/etc/consul-template.d/templates']
  }

  file { '/etc/consul-template.d/templates/nginx.crt.tpl':
    ensure  => file,
    content => template('rpaas/consul/nginx.crt.tpl.erb'),
    require => File['/etc/consul-template.d/templates']
  }

  file { '/etc/consul-template.d/templates/main_ssl.conf.tpl':
    ensure  => file,
    content => template('rpaas/consul/main_ssl.conf.tpl.erb'),
    require => File['/etc/consul-template.d/templates']
  }

  block_file { 'server':
    block_type => 'server'
  }

  block_file { 'http':
    block_type => 'http'
  }

  file { '/etc/consul-template.d/plugins/check_nginx_ssl_data.sh':
    ensure  => file,
    source  => 'puppet:///modules/rpaas/check_nginx_ssl_data.sh',
    require => File['/etc/consul-template.d/plugins']
  }

  file { '/etc/consul-template.d/plugins/check_file.sh':
    ensure  => file,
    source  => 'puppet:///modules/rpaas/check_file.sh',
    require => File['/etc/consul-template.d/plugins']
  }

  file { '/etc/consul-template.d/plugins/check_and_reload_nginx.sh':
    ensure  => file,
    content => template('rpaas/consul/check_and_reload_nginx.sh.erb'),
    require => File['/etc/consul-template.d/plugins'],
    mode    => '0755'
  }

  file { '/etc/nginx/sites-enabled/consul/locations.conf':
    ensure  => file,
    replace => false,
    require => File['/etc/nginx/sites-enabled/consul']
  }

  file { '/etc/nginx/sites-enabled/consul/upstreams.conf':
    ensure  => file,
    replace => false,
    require => File['/etc/nginx/sites-enabled/consul']
  }

  if $nginx_admin_enable_ssl {
    file { '/etc/consul-template.d/templates/nginx_admin.key.tpl':
      ensure  => file,
      content => template('rpaas/consul/nginx_admin.key.tpl.erb'),
      require => File['/etc/consul-template.d/templates']
    }

    file { '/etc/consul-template.d/templates/nginx_admin.crt.tpl':
      ensure  => file,
      content => template('rpaas/consul/nginx_admin.crt.tpl.erb'),
      require => File['/etc/consul-template.d/templates']
    }

    file { '/etc/consul-template.d/templates/admin_ssl.conf.tpl':
      ensure  => file,
      content => template('rpaas/consul/admin_ssl.conf.tpl.erb'),
      require => File['/etc/consul-template.d/templates']
    }

    file { '/etc/nginx/admin_ssl.conf':
      ensure  => file,
      replace => false,
      require => File['/etc/nginx']
    }

    $nginx_admin_ssl_templates = [File['/etc/consul-template.d/templates/nginx_admin.key.tpl'],
                                  File['/etc/consul-template.d/templates/nginx_admin.crt.tpl'],
                                  File['/etc/consul-template.d/templates/admin_ssl.conf.tpl']]
  } else {
    $nginx_admin_ssl_templates = []
  }

  if $nginx_lua {
    $lua_templates = [File['/etc/consul-template.d/templates/lua_server.conf.tpl'],
                      File['/etc/consul-template.d/templates/lua_worker.conf.tpl']]

    lua_file { 'server':
      lua_type => 'server'
    }

    lua_file { 'worker':
      lua_type => 'worker'
    }

    file { '/etc/nginx/sites-enabled/consul/blocks/lua_server.conf':
      ensure  => file,
      replace => false,
      require => File['/etc/nginx/sites-enabled/consul/blocks']
    }

    file { '/etc/nginx/sites-enabled/consul/blocks/lua_worker.conf':
      ensure  => file,
      replace => false,
      require => File['/etc/nginx/sites-enabled/consul/blocks']
    }
  } else {
    $lua_templates = []
  }

  if $nginx_admin_locations {
    file { '/etc/nginx/nginx_admin_locations.conf':
      ensure  => file,
      notify  => Service['nginx'],
      require => File['/etc/nginx']
    }
  }

  $service_consul_template_requirements = concat ([ Package['consul-template'],
                  File['/etc/consul-template.d/consul.conf'],
                  File['/etc/consul-template.d/templates/locations.conf.tpl'],
                  File['/etc/consul-template.d/templates/nginx.key.tpl'],
                  File['/etc/consul-template.d/templates/nginx.crt.tpl'],
                  File['/etc/consul-template.d/templates/main_ssl.conf.tpl'],
                  File['/etc/consul-template.d/templates/block_http.conf.tpl'],
                  File['/etc/consul-template.d/templates/block_server.conf.tpl'],
                  File['/etc/consul-template.d/plugins/check_nginx_ssl_data.sh'],
                  File['/etc/nginx/certs'],
                  File['/etc/consul-template.d/plugins/check_and_reload_nginx.sh']],
                  $lua_templates, $nginx_admin_ssl_templates)

  $service_consul_template_subscribe = concat([ Package['consul-template'],
                  File['/etc/consul-template.d/consul.conf'],
                  File['/etc/consul-template.d/templates/locations.conf.tpl'],
                  File['/etc/consul-template.d/templates/nginx.key.tpl'],
                  File['/etc/consul-template.d/templates/nginx.crt.tpl'],
                  File['/etc/consul-template.d/templates/block_http.conf.tpl'],
                  File['/etc/consul-template.d/templates/block_server.conf.tpl'],
                  File['/etc/consul-template.d/plugins/check_nginx_ssl_data.sh'],
                  File['/etc/nginx/certs'] ] , $lua_templates, $nginx_admin_ssl_templates)

  service { 'consul-template':
    ensure    => running,
    require   => $service_consul_template_requirements,
    subscribe => $service_consul_template_subscribe
  }

  if $nginx_http2 {
    $http2_value = "http2"
  }

  file { '/etc/nginx/main_ssl.conf':
    ensure  => file,
    replace => false,
    require => File['/etc/nginx']
  }

  file { '/etc/nginx/sites-enabled/consul/blocks/http.conf':
    ensure  => file,
    replace => false,
    require => File['/etc/nginx/sites-enabled/consul/blocks']
  }

  file { '/etc/nginx/sites-enabled/consul/blocks/server.conf':
    ensure  => file,
    replace => false,
    require => File['/etc/nginx/sites-enabled/consul/blocks']
  }

  package { 'nginx-extras':
    ensure  => $nginx_package,
    require => [ Exec['apt_update'], File['/etc/nginx/nginx.conf'] ]
  }

  service { 'nginx':
    ensure   => running,
    enable   => true,
    provider => 'upstart',
    restart  => '/usr/sbin/service nginx reload',
    require  => [ Package['nginx-extras'], Service['consul-template']]
  }

  file { $rpaas::nginx_dirs:
    ensure  => directory,
    recurse => true,
    owner   => $nginx_user,
    group   => $nginx_group
  }

  exec { 'session_resumption_random_ticket':
    command  => 'dd if=/dev/random bs=48 count=1 > /etc/nginx/certs/ticket.key',
    onlyif   => '/usr/bin/test ! -f /etc/nginx/certs/ticket.key',
    provider => shell,
    require  => File['/etc/nginx/certs'],
  }

  file { '/etc/nginx/sites-enabled/default':
    ensure  => absent,
    force   => true,
    require => Package['nginx-extras']
  }

  file { '/etc/nginx/nginx.conf':
    content => template('rpaas/nginx.conf.erb'),
    notify  => Service['nginx'],
    require => File['/etc/nginx']
  }

  file { '/etc/sysctl.d/99-nginx_tunnings.conf':
    content => template('rpaas/sysctl_nginx_tunnings.conf.erb'),
    notify  => Exec['invoke-rc.d procps start']
  }
  ->exec { 'invoke-rc.d procps start':
    path        => '/bin:/sbin:/usr/bin:/usr/sbin',
    subscribe   => File['/etc/sysctl.d/99-nginx_tunnings.conf'],
    refreshonly => true
  }
  ->exec { 'restart sysctl when wrong nginx values':
    command => 'invoke-rc.d procps start',
    path    => '/bin:/sbin:/usr/bin:/usr/sbin',
    onlyif  => "sysctl net.core.somaxconn | egrep -v '${sysctl_somaxconn}$' || \
                sysctl net.ipv4.tcp_max_syn_backlog | egrep -v '${sysctl_max_syn_backlog}$'"
  }
}
