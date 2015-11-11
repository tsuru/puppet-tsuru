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
      should contain_anchor('apt::ppa::ppa:tsuru/redis-server')
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
      should contain_class('sudo::package')
      should contain_class('sudo::params')
      should contain_class('sudo')
    end

    it do
      should contain_apt__key('docker')
      should contain_apt__key('tsuru')
      should contain_apt__ppa('ppa:tsuru/ppa')
      should contain_apt__ppa('ppa:tsuru/redis-server')
      should contain_apt__source('docker')
      should contain_apt_key('docker')
      should contain_apt_key('tsuru')
      should contain_sudo__conf('www-data')
    end

    it do
      should contain_service('nginx')
    end


    it do
      should contain_package('nginx-extras')
      should contain_package('software-properties-common')
      should contain_package('sudo')
    end

    # test files
    it do
      should contain_file('/etc/apt/apt.conf.d/15update-stamp')
      should contain_file('/etc/apt/sources.list.d/tsuru-ppa-trusty.list')
      should contain_file('/etc/apt/sources.list.d/tsuru-redis-server-trusty.list')
      should contain_file('/etc/nginx/sites-enabled/dav/ssl')
      should contain_file('/etc/nginx/sites-enabled/default')
      should contain_file('/etc/nginx/sites-enabled')
      should contain_file('01proxy')
      should contain_file('99unauth')
      should contain_file('docker.list')
      should contain_file('old-proxy-file')
      should contain_file('preferences.d')
      should contain_file('sources.list.d')
      should contain_file('sources.list')
      should contain_file('/etc/nginx/sites-enabled/dav/ssl/nginx.crt')
      should contain_file('/etc/nginx/sites-enabled/dav/ssl/nginx.key')
      should contain_file('/etc/nginx/sites-enabled/dav')
      should contain_file('/etc/sudoers.d/')
      should contain_file('/etc/sudoers')
      should contain_file('10_www-data')
    end

    context "generating nginx.conf with dav backend" do
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

      server_dav_purge_entry = <<"EOF"
    server {
        listen     8081;
        server_name  _tsuru_nginx_admin;

        location /healthcheck {
            echo "WORKING";
        }

        location ~ ^/purge(/.+) {
            allow           10.0.0.1;
            allow           10.0.2.3;
            deny            all;
            proxy_cache_purge  rpaas $scheme$1$is_args$args;
        }

        location /reload {
            content_by_lua "ngx.print(os.execute('sudo service nginx reload'))";
        }

        location /dav {
            allow           10.0.0.1;
            allow           10.0.2.3;
            deny            all;
            root            /etc/nginx/sites-enabled;
            dav_methods     PUT DELETE;
            create_full_put_path    on;
            dav_access      group:rw all:r;
        }
    }
EOF

      it 'custom user, worker_processes and worker_connections' do
        should contain_file('/etc/nginx/nginx.conf').with_content(/user foobar;\nworker_processes\s+10;\n\nevents \{\n\s+worker_connections\s+10;/)
      end


      it 'dav and purge custom location with ip restriction' do
        should contain_file('/etc/nginx/nginx.conf').with_content(/#{Regexp.escape(server_dav_purge_entry)}/)
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
        should contain_file('/etc/nginx/nginx.conf').with_content(/\s+access_log\ syslog:server=127.0.0.1,facility=local6,tag=rpaas01\ main/)
        should contain_file('/etc/nginx/nginx.conf').with_content(/\s+error_log\ syslog:server=127.0.0.1,facility=local7,tag=rpaas01/)
      end

    end

    it 'check if exec exist' do
      should contain_exec('apt_update')
      should contain_exec('ssl')
      should contain_exec('add-apt-repository-ppa:tsuru/ppa')
      should contain_exec('add-apt-repository-ppa:tsuru/redis-server')
      should contain_exec('sudo-syntax-check for file /etc/sudoers.d/10_www-data')
    end

  end

  context 'using consul backend' do
    let :params do
      {
        :nginx_mechanism      => 'consul',
        :consul_server        => 'foo.bar:8500',
        :consul_acl_token     => '0000-1111',
        :rpaas_service_name   => 'rpaas_fe',
        :rpaas_instance_name  => 'foo_instance'
      }
    end

    it 'generate crt template file for consul' do
      should contain_file('/etc/consul-template.d/templates/nginx.crt.tpl').with_content(<<EOF
{{ key "rpaas_fe/foo_instance/ssl/cert" | plugin "check_nginx_ssl_data.sh" "crt" }}
EOF
    )
    end

    it 'generate key template file for consul' do
      should contain_file('/etc/consul-template.d/templates/nginx.key.tpl').with_content(<<EOF
{{ key "rpaas_fe/foo_instance/ssl/key" | plugin "check_nginx_ssl_data.sh" "key" }}
EOF
    )
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
  end

end
