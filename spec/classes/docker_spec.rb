require 'spec_helper'

describe 'docker'  do

  let :facts do
    { :osfamily => 'Debian', :operatingsystem => 'Ubuntu', :lsbdistid => 'Ubuntu', :lsbdistcodename => 'precise' }
  end

  it 'requires class base' do
    should contain_class('base')
  end

  it 'creates /etc/profile.d/docker.sh with alias to docker' do
    should contain_file('/etc/profile.d/docker.sh').with_content(/alias docker="docker -H=tcp:\/\/localhost:4243"/)
  end

  it 'creates docker service, ensure running and notifies Package[lxc-docker], File[/etc/init/docker.conf] ' do
    should contain_service('docker').with_ensure('running')
    should contain_service('docker').that_subscribes_to('File[/etc/default/docker]')
    should contain_service('docker').that_subscribes_to('Package[lxc-docker]')
  end 

  it 'install lxc-docker package that notifies service docker' do
    should contain_package('lxc-docker').that_notifies('Service[docker]')
  end

  it 'creates service docker file /etc/init/docker.conf' do
    should contain_file('/etc/init/docker.conf')
  end

  context 'setting all docker options' do
    let (:params) { { :docker_graph_dir => '/foo/bar', :docker_bind => '0.0.0.0:4243', :docker_exec_driver => 'lxc', :docker_extra_opts => '--extra-opts foo=bar' } }
    it 'creates docker default file /etc/default/docker' do
      should contain_file('/etc/default/docker').with_content(/^DOCKER_OPTS="-g \/foo\/bar -e lxc -H 0.0.0.0:4243 --extra-opts foo=bar"/m)
    end
  end

  context 'default docker options' do
    it 'creates docker default file /etc/default/docker' do
      should contain_file('/etc/default/docker').with_content(/^DOCKER_OPTS="-g \/var\/lib\/docker -e native  "/m)
    end
  end

  it 'base should be called before docker' do
    should contain_class('base').that_comes_before('Class[docker]')
  end

end
