require 'spec_helper'

describe 'docker'  do

  let :facts do
    { :osfamily => 'Debian', :operatingsystem => 'Ubuntu', :lsbdistid => 'Ubuntu', :lsbdistcodename => 'precise' }
  end

  let :params do 
    { :lxc_docker_version => 'latest' }
  end

  it 'install lxc-docker package that notifies service docker' do
    should contain_package('lxc-docker').with({
      :require => ["File[/etc/default/docker]", "File[/etc/init/docker.conf]"]
    })
  end

  context 'when seting docker version to 1.2.0' do

    before { params.merge!( :lxc_docker_version => '1.2.0' ) }

    it 'install lxc-docker-1.2.0 package that notifies service docker' do
      should contain_package('lxc-docker-1.2.0').with({
        :require => ["File[/etc/default/docker]", "File[/etc/init/docker.conf]"]
      })
    end

  end

  it 'creates service docker file /etc/init/docker.conf' do
    should contain_file('/etc/init/docker.conf')
  end

  context 'setting all docker options' do
    let (:params) { { :docker_graph_dir => '/foo/bar',
                      :docker_bind => ['tcp:///0.0.0.0:4243', 'unix:///var/run/docker.sock'],
                      :docker_exec_driver => 'lxc',
                      :docker_extra_opts => '--extra-opts foo=bar' } }
    it 'creates docker default file /etc/default/docker' do
      should contain_file('/etc/default/docker').with_content(/^DOCKER_OPTS="-g \/foo\/bar -e lxc -H tcp:\/\/\/0.0.0.0:4243 -H unix:\/\/\/var\/run\/docker.sock --extra-opts foo=bar"/m)
    end
  end

  context 'default docker options' do
    it 'creates docker default file /etc/default/docker' do
      should contain_file('/etc/default/docker').with_content(/^DOCKER_OPTS="-g \/var\/lib\/docker -e native  "/m)
    end
  end

  context 'invalid docker_bind' do
    let (:params) { { :docker_bind => "tcp:///0.0.0.0:4243" } }
    it 'raises puppet error when not array' do
      should raise_error(Puppet::Error, /\$docker_bind must be an array/)
    end
  end

end
