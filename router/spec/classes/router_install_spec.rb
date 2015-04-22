require 'spec_helper'

describe 'router::install' do

  context "on a Ubuntu OS" do
    let :facts do
      {
        :osfamily        => 'Debian',
        :operatingsystem => 'Ubuntu',
        :lsbdistid       => 'Ubuntu',
        :lsbdistcodename => 'precise',
        :hostname        => 'foo.bar'
      }
    end

    context "with default parameters" do

      it 'install required classes' do
        should contain_class('base')
        should contain_class('router')
        should contain_class('router::install')
        should contain_class('base::ubuntu')
      end

      it 'required by apt' do

        should contain_class('apt')
        should contain_class('apt::params')
        should contain_class('apt::update')

        should contain_exec('apt_update')
        should contain_exec('add-apt-repository-ppa:tsuru/redis-server')
        should contain_exec('add-apt-repository-ppa:tsuru/ppa')

        should contain_file('docker.list')
        should contain_file('sources.list')
        should contain_file('sources.list.d')
        should contain_file('preferences.d')
        should contain_file('99unauth')
        should contain_file('01proxy')
        should contain_file('old-proxy-file')
        should contain_file('/etc/apt/apt.conf.d/15update-stamp')
        should contain_file('/etc/apt/sources.list.d/tsuru-redis-server-precise.list')
        should contain_file('/etc/apt/sources.list.d/tsuru-ppa-precise.list')

        should contain_anchor('apt::update')
        should contain_anchor('apt::source::docker')
        should contain_anchor('apt::ppa::ppa:tsuru/redis-server')
        should contain_anchor('apt::ppa::ppa:tsuru/ppa')
        should contain_anchor('apt_key 383F073D present')
        should contain_anchor('apt_key A88D21E9 present')

        should contain_apt__ppa('ppa:tsuru/redis-server')
        should contain_apt__ppa('ppa:tsuru/ppa')

        should contain_apt__source('docker')

        should contain_apt_key('tsuru')
        should contain_apt_key('docker')

        should contain_apt__key('tsuru')
        should contain_apt__key('docker')

      end

      it 'required by hipache' do
        should contain_package('node-hipache')
        should contain_service('hipache')
        should contain_file('/etc/hipache.conf')
      end

      it 'required by hchecker' do
        should contain_package('hipache-hchecker')
        should contain_service('hipache-hchecker')
        should contain_file('/etc/default/hipache-hchecker')
      end

    end

    context "with all parameters" do
      let :params do
        {
          # :tsuru_server_version => 'latest',
        }
      end

      it  do
        #
      end

      it 'requires class base' do
        should contain_class('base')
      end

    end
  end
end
