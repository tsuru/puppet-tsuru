require 'spec_helper'

describe 'rpaas::install' do

  context "on a Ubuntu OS with default params" do
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

    context "generating nginx.conf with" do
      let :params do
        {
          :nginx_user => "foobar",
          :nginx_worker_processes => 10,
          :nginx_worker_connections => 10,
          :nginx_admin_listen => 8081,
          :nginx_listen => 8080,
          :nginx_ssl_listen => 8082,
          :nginx_allow_dav_list => ['10.0.0.1', '10.0.2.3'],
          :nginx_custom_error_codes => {'404.html' => ['404', '403'], '500.html' => [ '500', '502', '503', '504' ]},
          :nginx_custom_error_dir => "/mnt/error_pages",
          :nginx_intercept_errors => true
        }
      end

      it 'custom user, worker_processes and worker_connections' do
        should contain_file('/etc/nginx/nginx.conf').with_content(/user foobar;\nworker_processes\s+10;\n\nevents \{\n\s+worker_connections\s+10;/)
      end

      it 'dav allow ip list' do
        should contain_file('/etc/nginx/nginx.conf').with_content(/\s+allow\s+10.0.0.1;\n\s+allow\s+10.0.2.3;/)
      end

      it 'custom error pages for 40X and 50X errors with proxy_intercept errors' do
        should contain_file('/etc/nginx/nginx.conf').with_content(/error_page 404 403 \/_nginx_errordocument\/404.html;/m)
        should contain_file('/etc/nginx/nginx.conf').with_content(/error_page 500 502 503 504 \/_nginx_errordocument\/500.html;/m)
        should contain_file('/etc/nginx/nginx.conf').with_content(/proxy_intercept_errors on;/)
      end

      it 'custom error location' do
        should contain_file('/etc/nginx/nginx.conf').with_content(/\s+location\ ~\ \^\/_nginx_errordocument\/\(.\+\) \{\n\s+internal;\n\s+alias \/mnt\/error_pages\/\$1;\n\s+\}/)
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
end
