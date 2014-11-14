require 'spec_helper'

describe 'rpaas::install' do

  fixture_path = File.expand_path(File.join(__FILE__, '..', '../fixtures'))

  context "on a Ubuntu OS" do
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

    it do
      should contain_file('/etc/nginx/nginx.conf').with_content(File.read(File.join(fixture_path,'templates/nginx.conf')))
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