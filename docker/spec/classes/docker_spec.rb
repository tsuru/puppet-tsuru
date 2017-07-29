require 'spec_helper'

describe 'docker'  do

  let :facts do
    { :osfamily => 'Debian', :operatingsystem => 'Ubuntu', :lsbdistid => 'Ubuntu', :lsbdistcodename => 'precise' }
  end

  let :params do
    { :docker_version => 'latest' }
  end

  context 'when setting docker version to 1.8.1' do
    before { params.merge!( :docker_version => '1.8.1' ) }
    it 'raises puppet error when version is lower or equal than 1.9.1' do
      should raise_error(Puppet::Error, /\$docker_version must be greater than 1.9.1/)
    end
  end

  context 'when setting docker version to 1.10.2' do
    before { params.merge!( :docker_version => '1.10.2' ) }
    it 'install docker-engine package with version 1.10.2' do
      should contain_package('docker-engine').with({
        :ensure  => '1.10.2',
        :require => "File[/etc/default/docker]"
      })
    end
  end

  context 'when setting docker version to 17.03.2' do
    before { params.merge!( :docker_version => '17.03.2' ) }
    it 'install docker-ce package with version 17.03.2' do
      should contain_package('docker-ce').with({
        :ensure  => '17.03.2',
        :require => "File[/etc/default/docker]"
      })
    end
  end

  context 'when setting docker version to latest' do
    it 'install docker-engine package with latest version' do
      should contain_package('docker-ce').with({
        :require => "File[/etc/default/docker]"
      })
    end
  end

  context 'setting all docker options' do
    let (:params) { { :docker_graph_dir => '/foo/bar',
                      :docker_bind => ['tcp:///0.0.0.0:4243', 'unix:///var/run/docker.sock'],
                      :docker_extra_opts => '--extra-opts foo=bar' } }
    it 'creates docker default file /etc/default/docker' do
      should contain_file('/etc/default/docker').with_content(/^DOCKER_OPTS="-g \/foo\/bar -H tcp:\/\/\/0.0.0.0:4243 -H unix:\/\/\/var\/run\/docker.sock --extra-opts foo=bar"/m)
    end
  end

  context 'default docker options' do
    it 'creates docker default file /etc/default/docker' do
      should contain_file('/etc/default/docker').with_content(/^DOCKER_OPTS="-g \/var\/lib\/docker  "/m)
    end
  end

  context 'invalid docker_bind' do
    let (:params) { { :docker_bind => "tcp:///0.0.0.0:4243" } }
    it 'raises puppet error when not array' do
      should raise_error(Puppet::Error, /\$docker_bind must be an array/)
    end
  end

end
