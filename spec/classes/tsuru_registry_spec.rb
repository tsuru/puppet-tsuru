require 'spec_helper'

describe 'tsuru::registry'  do

  before (:each) do
    FileUtils.stubs(:mkdir_p).returns(true)
  end

  let :facts do
    { :osfamily => 'Debian', :operatingsystem => 'Ubuntu', :lsbdistid => 'Ubuntu', :lsbdistcodename => 'precise', :hostname => 'foo.bar' }
  end

  let :params do
    {
      :registry_ipbind_port   => '0.0.0.0:9000',
      :registry_path          => '/foo/bar',
      :registry_version       => '0.1.0',
      :registry_user          => 'foo',
      :registry_group         => 'bar'
    }
  end

  it 'requires class params' do
    should contain_class('tsuru::params')
  end

  it 'creates file /etc/init/docker-registry.conf' do
    should contain_file('/etc/init/docker-registry.conf').with_content(/setuid foo\nsetgid bar\n\nrespawn\nexec.+-l 0.0.0.0:9000 -d \/foo\/bar/)
  end

  it 'creates /foo/bar registry_path dir' do
    should contain_file('/foo/bar').with({:ensure => 'directory', :notify => 'Service[docker-registry]'})
  end

  it 'run service docker-registry and subscribe /etc/init/docker-registry.conf file' do
    should contain_service('docker-registry').with({:ensure => 'running', :subscribe => 'File[/etc/init/docker-registry.conf]'})
  end

end
