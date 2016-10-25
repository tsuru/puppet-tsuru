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
    }
  end

  context "on a Ubuntu OS with default params" do

    it do
      should contain_anchor('apt::ppa::ppa:tsuru/ppa')
      should contain_anchor('apt::source::docker')
      should contain_anchor('apt::update')
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
      should contain_package('software-properties-common')
    end

    # test files
    it do
      should contain_file('/etc/apt/apt.conf.d/15update-stamp')
      should contain_file('/etc/apt/sources.list.d/tsuru-ppa-trusty.list')
      should contain_file('/etc/nginx/sites-enabled/default')
      should contain_file('/etc/nginx/sites-enabled')
      should contain_file('01proxy')
      should contain_file('99unauth')
      should contain_file('docker.list')
      should contain_file('old-proxy-file')
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
          :nginx_syslog_tag => 'rpaas01'
        }
      end

      server_purge_entry = <<"EOF"
    server {
        listen     8081;
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
      should contain_exec('ssl')
      should contain_exec('add-apt-repository-ppa:tsuru/ppa')
    end

  end

  context 'using consul backend' do
    let :params do
      {
        :consul_server        => 'foo.bar:8500',
        :consul_acl_token     => '0000-1111',
        :rpaas_service_name   => 'rpaas_fe',
        :rpaas_instance_name  => 'foo_instance'
      }
    end

    it 'generate crt template file for consul' do
      should contain_file('/etc/consul-template.d/templates/nginx.crt.tpl').with_content(<<EOF
{{ key_or_default "rpaas_fe/foo_instance/ssl/cert" "" | plugin "check_nginx_ssl_data.sh" "crt" }}
EOF
    )
    end

    it 'generate key template file for consul' do
      should contain_file('/etc/consul-template.d/templates/nginx.key.tpl').with_content(<<EOF
{{ key_or_default "rpaas_fe/foo_instance/ssl/key" "" | plugin "check_nginx_ssl_data.sh" "key" }}
EOF
    )
    end

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
    end

    it 'generate initial empty block files' do
      should contain_file('/etc/nginx/sites-enabled/consul/blocks/http.conf')
      should contain_file('/etc/nginx/sites-enabled/consul/blocks/server.conf')
    end

    consul_conf_content = <<EOF
consul = "foo.bar:8500"
token = "0000-1111"
syslog {
    enabled = true
    facility = "LOCAL0"
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
