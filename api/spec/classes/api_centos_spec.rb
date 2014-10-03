require 'spec_helper'

describe 'api::install'  do

  let :facts do
    { :osfamily => 'RedHat', :operatingsystem => 'CentOS', :hostname => 'foo.bar' }
  end

  let :params do
    {
      :tsuru_collector_server => 'foo.bar',
      :tsuru_app_domain       => 'app.tsuru.localdomain',
      :tsuru_api_server_url   => 'http://tsuru.localdomain',
      :tsuru_git_url          => 'http://git.tsuru.localdomain',
      :tsuru_git_rw_host      => 'git.tsuru.localdomain',
      :tsuru_git_ro_host      => 'git.tsuru.localdomain',
      :tsuru_redis_server     => 'redis.tsuru.localdomain',
      :tsuru_registry_server  => 'registry.tsuru.localdomain',
      :tsuru_docker_servers_urls   => [ 'foo.localdomain:4243', 'bar.localdomain:4243' ]
    }
  end

  it 'requires class base' do
    should contain_class('base')
  end

  it 'requires class base::centos' do
    should contain_class('base::centos')
  end

  it 'enabling tsuru-server-api service' do
    should contain_service('tsuru-server-api').with({
      :ensure => 'running',
      :enable => 'true',
      :subscribe => [ 'File[/etc/tsuru/tsuru.conf]', 'File[/etc/init.d/tsuru-server]', 'Package[tsuru-server]' ],
    })
  end

   context 'enabling collector server for host foo.bar' do

    it 'enabling beanstalkd service' do
      should contain_service('beanstalkd').with({
        :ensure  => 'running',
        :enable  => 'true'
      })
    end

    it 'package beanstalkd should be installed' do
      should contain_package('beanstalkd').with({
        :ensure => 'latest'
      })
    end

    it 'file /etc/init.d/beanstalkd must exists' do
      should contain_file('/etc/init.d/beanstalkd').with({
        :ensure => 'file'
      })
    end

    it 'service tsuru-server-collector must be enabled' do
      should contain_service('tsuru-server-collector').with ({
        :ensure => 'running',
        :enable  => 'true'
      })
    end

  end

  context 'hostname homer.simpson should not have collector enabled' do

    before do
      facts.merge!( :hostname => 'homer.simpson' )
    end

    it 'service beanstalkd should not defined' do
      should_not contain_service('beanstalkd')
    end

    it 'package beanstalkd should not be installed' do
      should_not contain_package('beanstalkd').with({
        :ensure => 'latest'
      })
    end

  end

  it 'package tsuru-server should be installed' do
    should contain_package('tsuru-server').with({
      :ensure => 'latest'
    })
  end

  it 'file /etc/tsuru/tsuru.conf must exists' do
    should contain_file('/etc/tsuru/tsuru.conf').with_content(/servers:\n    - http:\/\/foo.localdomain:4243\n    - http:\/\/bar.localdomain:4243/)
  end

end