require 'spec_helper'

describe 'rpaas::install' do

  let :facts do
    {
      :osfamily                  => 'Debian',
      :operatingsystem           => 'Ubuntu',
      :lsbdistid                 => 'Ubuntu',
      :lsbdistcodename           => 'trusty',
      :hostname                  => 'foo.bar',
      :zabbix_enable             => true,
      :vm_id                     => 'd196717b-bcca-4ab1-8ca3-221b2ac4bf8d'
    }
  end

  context "on a Ubuntu OS with default params" do

    it do
      should contain_anchor('apt_key 383F073D present')
      should contain_anchor('apt_key A88D21E9 present')
    end

    it do
      should contain_class('apt::params')
      should contain_class('apt::update')
      should contain_class('apt')
      should contain_class('base::ubuntu')
      should contain_class('base')
      should contain_class('rpaas::install')
      should contain_class('rpaas')
    end

    it do
      should contain_apt__key('docker')
      should contain_apt__key('tsuru')
      should contain_apt__ppa('ppa:tsuru/ppa')
      should contain_apt__source('docker')
      should contain_apt_key('docker')
      should contain_apt_key('tsuru')
    end

    it do
      should contain_service('nginx')
    end


    it do
      should contain_package('nginx-extras')
    end

    # test files
    it do
      should contain_file('/etc/apt/apt.conf.d/15update-stamp')
      should contain_file('/etc/apt/sources.list.d/tsuru-ppa-trusty.list')
      should contain_file('/etc/nginx/sites-enabled/default')
      should contain_file('/etc/nginx/sites-enabled')
      should contain_file('preferences.d')
      should contain_file('sources.list.d')
      should contain_file('sources.list')
    end

    context "generating nginx.conf" do
      let :params do
        {
          :nginx_user => "foobar",
          :nginx_worker_processes => 10,
          :nginx_worker_connections => 10,
          :nginx_admin_listen => 8081,
          :nginx_listen => 8080,
          :nginx_ssl_listen => 8082,
          :nginx_allow_admin_list => ['10.0.0.1', '10.0.2.3'],
          :nginx_custom_error_codes => {'404.html' => ['404', '403'], '500.html' => [ '500', '502', '503', '504' ]},
          :nginx_custom_error_dir => "/mnt/error_pages",
          :nginx_intercept_errors => true,
          :nginx_syslog_server => '127.0.0.1',
          :nginx_syslog_tag => 'rpaas01',
          :nginx_dhparams => '/etc/nginx/dh_params.pem',
        }
      end

      server_purge_entry = <<"EOF"
    server {
        listen 8081;

        server_name  _tsuru_nginx_admin;

        location /healthcheck {
            echo "WORKING";
        }

        location ~ ^/purge/(.+) {
            allow           10.0.0.1;
            allow           10.0.2.3;
            deny            all;
            proxy_cache_purge  rpaas $1$is_args$args;
        }
    }
EOF
      custom_worker_process = <<"EOF"
user foobar;
worker_processes  10;
include /etc/nginx/modules-enabled/*.conf;

events {
    worker_connections  10;
}
EOF

      it 'custom user, worker_processes and worker_connections' do
        should contain_file('/etc/nginx/nginx.conf').with_content(/#{Regexp.escape(custom_worker_process)}/m)
      end


      it 'purge custom location with ip restriction' do
        should contain_file('/etc/nginx/nginx.conf').with_content(/#{Regexp.escape(server_purge_entry)}/)
      end

      it 'custom error pages for 40X and 50X errors with proxy_intercept errors' do
        should contain_file('/etc/nginx/nginx.conf').with_content(/error_page 404 403 \/_nginx_errordocument\/404.html;/m)
        should contain_file('/etc/nginx/nginx.conf').with_content(/error_page 500 502 503 504 \/_nginx_errordocument\/500.html;/m)
        should contain_file('/etc/nginx/nginx.conf').with_content(/proxy_intercept_errors on;/)
      end

      it 'custom error location' do
        should contain_file('/etc/nginx/nginx.conf').with_content(/\s+location\ ~\ \^\/_nginx_errordocument\/\(.\+\) \{\n\s+internal;\n\s+alias \/mnt\/error_pages\/\$1;\n\s+\}/)
      end

      it 'custom syslog server' do
        should contain_file('/etc/nginx/nginx.conf').with_content(/\s+access_log\ syslog:server=127.0.0.1,facility=local6,tag=rpaas01\ main;/)
        should contain_file('/etc/nginx/nginx.conf').with_content(/\s+error_log\ syslog:server=127.0.0.1,facility=local6,tag=rpaas01;/)
      end

    end

    it 'check if exec exist' do
      should contain_exec('apt_update')
      should contain_exec('add-apt-repository-ppa:tsuru/ppa')
    end

  end

  context 'enabling nginx admin ssl' do
    let :params do
      {
        :nginx_admin_enable_ssl => true
      }
    end

    nginx_admin_ssl_enabled = <<"EOF"
    server {
        listen 8089;
        include /etc/nginx/admin_ssl.conf;

        server_name  _tsuru_nginx_admin;

        location /healthcheck {
            echo "WORKING";
        }
EOF

    it 'nginx admin server should bind to the ssl port' do
      should contain_file('/etc/nginx/nginx.conf').with_content(/#{Regexp.escape(nginx_admin_ssl_enabled)}/)
    end
  end


  context 'enabling nginx custom locations based on consul' do
    let :params do
      {
        :nginx_admin_locations => true
      }
    end

    nginx_custom_locations = <<"EOF"
    server {
        listen 8089;

        server_name  _tsuru_nginx_admin;

        location /healthcheck {
            echo "WORKING";
        }

        location ~ ^/purge/(.+) {
            allow           127.0.0.0/24;
            allow           127.1.0.0/24;
            deny            all;
            proxy_cache_purge  rpaas $1$is_args$args;
        }
        include nginx_admin_locations.conf;
    }
EOF

    it 'nginx admin server should include a custom locations file' do
      should contain_file('/etc/nginx/nginx.conf').with_content(/#{Regexp.escape(nginx_custom_locations)}/)
    end

    it 'nginx admin server should have a custom admin location file to not throw an error' do
      should contain_file('/etc/nginx/nginx_admin_locations.conf')
    end
  end


  context 'enabling vts' do
    let :params do
      {
        :nginx_vts_enabled => true
      }
    end
    server_vts_enabled = <<"EOF"
    vhost_traffic_status_zone;
    server {
        listen 8089;

        server_name  _tsuru_nginx_admin;

        location /healthcheck {
            echo "WORKING";
        }

        location ~ ^/purge/(.+) {
            allow           127.0.0.0/24;
            allow           127.1.0.0/24;
            deny            all;
            proxy_cache_purge  rpaas $1$is_args$args;
        }

        location /vts_status {
          vhost_traffic_status_display;
          vhost_traffic_status_display_format json;
        }
    }
EOF

    it 'add custom location to admin block and enable it at http block' do
      should contain_file('/etc/nginx/nginx.conf').with_content(/#{Regexp.escape(server_vts_enabled)}/)
    end

  end

  context 'enabling request_id' do
    let :params do
      {
        :nginx_request_id_enabled => true,
        :nginx_local_log          => false,
        :nginx_syslog_server      => 'localhost'
      }
    end
    server_request_id_enabled = <<"EOF"
    uuid4 $request_id_uuid;
    map $http_x_request_id $request_id_final {
      default $request_id_uuid;
      "~." $http_x_request_id;
    }

    map $http_x_real_ip $real_ip_final {
        default $remote_addr;
        "~." $http_x_real_ip;
    }

    map $http_x_forwarded_proto $forwarded_proto_final {
      default $scheme;
      "~." $http_x_forwarded_proto;
    }

    map $http_x_forwarded_host $forwarded_host_final {
      default $host;
      "~." $http_x_forwarded_host;
    }


    log_format main
      '${remote_addr}\\t${host}\\t${request_method}\\t${request_uri}\\t${server_protocol}\\t'
      '${http_referer}\\t${http_x_mobile_group}\\t'
      'Local:\\t${status}\\t*${connection}\\t${body_bytes_sent}\\t${request_time}\\t'
      'Proxy:\\t${upstream_addr}\\t${upstream_status}\\t${upstream_cache_status}\\t'
      '${upstream_response_length}\\t${upstream_response_time}\\t${request_uri}\\t'
      'Agent:\\t${http_user_agent}\\t$request_id_final\\t'
      'Fwd:\\t${http_x_forwarded_for}';

    access_log syslog:server=localhost,facility=local6,tag=rpaas main;
    error_log syslog:server=localhost,facility=local6,tag=rpaas;
EOF

    server_request_id_headers = <<"EOF"
        more_set_input_headers "X-Request-ID: $request_id_final";
        more_set_headers "X-Request-ID: $request_id_final";
EOF
    it 'add request_id headers' do
      should contain_file('/etc/nginx/nginx.conf').with_content(/#{Regexp.escape(server_request_id_headers)}/)
    end
    it 'add uuid4 module, generate request_id headers' do
      should contain_file('/etc/nginx/nginx.conf').with_content(/#{Regexp.escape(server_request_id_enabled)}/)
    end
  end

  context 'using consul backend' do
    let :params do
      {
        :consul_server          => 'foo.bar:8500',
        :consul_acl_token       => '0000-1111',
        :rpaas_service_name     => 'rpaas_fe',
        :rpaas_instance_name    => 'foo_instance',
        :nginx_admin_enable_ssl => true,
        :nginx_lua              => true
      }
    end

    it 'generate crt template file for consul' do
      should contain_file('/etc/consul-template.d/templates/nginx.crt.tpl').with_content(<<EOF
{{ key_or_default "rpaas_fe/foo_instance/ssl/cert" "" | plugin "check_nginx_ssl_data.sh" "main" "crt" }}
EOF
    )
    end

    it 'generate key template file for consul' do
      should contain_file('/etc/consul-template.d/templates/nginx.key.tpl').with_content(<<EOF
{{ key_or_default "rpaas_fe/foo_instance/ssl/key" "" | plugin "check_nginx_ssl_data.sh" "main" "key" }}
EOF
    )
    end

    it 'generate admin key template file for consul' do
      should contain_file('/etc/consul-template.d/templates/nginx_admin.key.tpl').with_content(<<EOF
{{ key_or_default "rpaas_fe/foo_instance/ssl/d196717b-bcca-4ab1-8ca3-221b2ac4bf8d/key" "" | plugin "check_nginx_ssl_data.sh" "admin" "key" }}
EOF
    )
    end

    it 'generate admin crt template file for consul' do
      should contain_file('/etc/consul-template.d/templates/nginx_admin.crt.tpl').with_content(<<EOF
{{ key_or_default "rpaas_fe/foo_instance/ssl/d196717b-bcca-4ab1-8ca3-221b2ac4bf8d/cert" "" | plugin "check_nginx_ssl_data.sh" "admin" "crt" }}
EOF
    )
    end

    lua_worker_content = <<EOF
init_worker_by_lua_block {
ngx_rpaas_service  = "rpaas_fe"
ngx_rpaas_instance = "foo_instance"
ngx_consul_token   = "0000-1111"
{{ with $locations := ls "rpaas_fe/foo_instance/lua_module/worker" }}
  {{ range $locations }}
    {{if .Value | regexMatch "(?ms)-- Begin custom RpaaS .+ lua module --.+-- End custom RpaaS .+ lua module --" }}
{{ .Value }}
    {{ end }}
  {{ end }}
{{ end }}
}
EOF

    lua_server_content = <<EOF
init_by_lua_block {
ngx_rpaas_service  = "rpaas_fe"
ngx_rpaas_instance = "foo_instance"
ngx_consul_token   = "0000-1111"
{{ with $locations := ls "rpaas_fe/foo_instance/lua_module/server" }}
  {{ range $locations }}
    {{if .Value | regexMatch "(?ms)-- Begin custom RpaaS .+ lua module --.+-- End custom RpaaS .+ lua module --" }}
{{ .Value }}
    {{ end }}
  {{ end }}
{{ end }}
}
EOF

    it 'generate block templates file for consul' do
      should contain_file('/etc/consul-template.d/templates/block_http.conf.tpl').with_content(<<EOF
{{ with $custom_block := key_or_default "rpaas_fe/foo_instance/blocks/http/ROOT" "" }}
  {{ if $custom_block | regexMatch "(?ms)## Begin custom RpaaS http block ##.+## End custom RpaaS http block ##"  }}
{{ $custom_block }}
  {{ else }}
{{ plugin "check_file.sh" "/etc/nginx/sites-enabled/consul/blocks/http.conf" }}
  {{ end }}
{{ else }}
{{ plugin "check_file.sh" "/etc/nginx/sites-enabled/consul/blocks/http.conf" }}
{{ end }}
EOF
      )

      should contain_file('/etc/consul-template.d/templates/block_server.conf.tpl').with_content(<<EOF
{{ with $custom_block := key_or_default "rpaas_fe/foo_instance/blocks/server/ROOT" "" }}
  {{ if $custom_block | regexMatch "(?ms)## Begin custom RpaaS server block ##.+## End custom RpaaS server block ##"  }}
{{ $custom_block }}
  {{ else }}
{{ plugin "check_file.sh" "/etc/nginx/sites-enabled/consul/blocks/server.conf" }}
  {{ end }}
{{ else }}
{{ plugin "check_file.sh" "/etc/nginx/sites-enabled/consul/blocks/server.conf" }}
{{ end }}
EOF
      )

    should contain_file('/etc/consul-template.d/templates/lua_server.conf.tpl').with_content(lua_server_content)
    should contain_file('/etc/consul-template.d/templates/lua_worker.conf.tpl').with_content(lua_worker_content)
  end

    it 'generate initial empty block files' do
      should contain_file('/etc/nginx/sites-enabled/consul/blocks/http.conf')
      should contain_file('/etc/nginx/sites-enabled/consul/blocks/server.conf')
    end

    it 'generate initial empty block files for lua' do
      should contain_file('/etc/nginx/sites-enabled/consul/blocks/lua_server.conf')
      should contain_file('/etc/nginx/sites-enabled/consul/blocks/lua_worker.conf')
    end

    consul_conf_content = <<EOF
consul = "foo.bar:8500"
token = "0000-1111"
syslog {
    enabled = true
    facility = "LOCAL0"
}

template {
    source = "/etc/consul-template.d/templates/locations.conf.tpl"
    destination = "/etc/nginx/sites-enabled/consul/locations.conf"
    command = "/etc/consul-template.d/plugins/check_and_reload_nginx.sh"
    perms = 0644
}

template {
    source = "/etc/consul-template.d/templates/upstreams.conf.tpl"
    destination = "/etc/nginx/sites-enabled/consul/upstreams.conf"
    command = "/etc/consul-template.d/plugins/check_and_reload_nginx.sh"
    perms = 0644
}

template {
    source = "/etc/consul-template.d/templates/nginx.key.tpl"
    destination = "/etc/nginx/certs/nginx_main.key"
    command = "/etc/consul-template.d/plugins/check_and_reload_nginx.sh"
    perms = 0644
}

template {
    source = "/etc/consul-template.d/templates/nginx.crt.tpl"
    destination = "/etc/nginx/certs/nginx_main.crt"
    command = "/etc/consul-template.d/plugins/check_and_reload_nginx.sh"
    perms = 0644
}

template {
    source = "/etc/consul-template.d/templates/main_ssl.conf.tpl"
    destination = "/etc/nginx/main_ssl.conf"
    command = "/etc/consul-template.d/plugins/check_and_reload_nginx.sh"
    perms = 0644
}

template {
    source = "/etc/consul-template.d/templates/block_http.conf.tpl"
    destination = "/etc/nginx/sites-enabled/consul/blocks/http.conf"
    command = "/etc/consul-template.d/plugins/check_and_reload_nginx.sh"
    perms = 0644
}

template {
    source = "/etc/consul-template.d/templates/block_server.conf.tpl"
    destination = "/etc/nginx/sites-enabled/consul/blocks/server.conf"
    command = "/etc/consul-template.d/plugins/check_and_reload_nginx.sh"
    perms = 0644
}

template {
    source = "/etc/consul-template.d/templates/lua_server.conf.tpl"
    destination = "/etc/nginx/sites-enabled/consul/blocks/lua_server.conf"
    command = "/etc/consul-template.d/plugins/check_and_reload_nginx.sh"
    perms = 0644
}

template {
    source = "/etc/consul-template.d/templates/lua_worker.conf.tpl"
    destination = "/etc/nginx/sites-enabled/consul/blocks/lua_worker.conf"
    command = "/etc/consul-template.d/plugins/check_and_reload_nginx.sh"
    perms = 0644
}


template {
    source = "/etc/consul-template.d/templates/nginx_admin.key.tpl"
    destination = "/etc/nginx/certs/nginx_admin.key"
    command = "/etc/consul-template.d/plugins/check_and_reload_nginx.sh"
    perms = 0644
}

template {
    source = "/etc/consul-template.d/templates/nginx_admin.crt.tpl"
    destination = "/etc/nginx/certs/nginx_admin.crt"
    command = "/etc/consul-template.d/plugins/check_and_reload_nginx.sh"
    perms = 0644
}

template {
    source = "/etc/consul-template.d/templates/admin_ssl.conf.tpl"
    destination = "/etc/nginx/admin_ssl.conf"
    command = "/etc/consul-template.d/plugins/check_and_reload_nginx.sh"
    perms = 0644
}
EOF
    it 'creates /etc/consul-template.d/consul.conf' do
      should contain_file('/etc/consul-template.d/consul.conf').with_content(/#{consul_conf_content}/m)
    end

check_and_reload_nginx_content = <<EOF
nginx_error=$(nginx -t 2>&1 | grep emerg)
consul_nginx_url='http://foo.bar:8500/v1/kv/rpaas_fe/foo_instance/status/foo.bar?token=0000-1111'
EOF

    it 'creates /etc/consul-template.d/plugins/check_and_reload_nginx.sh' do
      should contain_file('/etc/consul-template.d/plugins/check_and_reload_nginx.sh').with_content(/#{Regexp.escape(check_and_reload_nginx_content)}/)
    end

  end

end
