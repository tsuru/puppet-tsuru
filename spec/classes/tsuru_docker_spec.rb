require 'spec_helper'

describe 'tsuru::docker'  do

  let :facts do
    { :osfamily => 'Debian', :operatingsystem => 'Ubuntu', :lsbdistid => 'Ubuntu', :lsbdistcodename => 'precise' }
  end

  let (:params) { { :tsuru_ssh_agent => false } }

  it 'requires class params' do
    should contain_class('tsuru::params')
  end

  context 'enable tsuru_ssh_agent' do

    let (:params) { { :tsuru_ssh_agent => true } }

    it 'install tsuru-server package latest version' do
      should contain_package('tsuru-server').with({
        :ensure  => 'latest'
      })
    end

    it 'creates /etc/init/tsuru-ssh-agent.conf with service enable' do
      should contain_file('/etc/init/tsuru-ssh-agent.conf').with_content(/exec \/usr\/bin\/tsr docker-ssh-agent/)
      should contain_file('/etc/init/tsuru-ssh-agent.conf').with( {
        'ensure' => 'present',
        'owner'  => 'root',
        'group'  => 'root',
        'mode'   => '0644'
      })
    end

    it 'creates /etc/default/tsuru-server with default ssh key' do
      should contain_file('/etc/default/tsuru-server').with_content(/\/var\/lib\/tsuru\/.ssh\/id_rsa/)
    end

    context 'using custom tsuru_ssh_agent_private_key to /var/lib/super_secure_id_rsa' do

      before do
        params.merge!(:tsuru_ssh_agent_private_key => '/var/lib/super_secure_id_rsa')
      end

      it 'creates /etc/default/tsuru-server with TSR_SSH_AGENT_PRIVATE_KEY=/var/lib/super_secure_id_rsa' do
        should contain_file('/etc/default/tsuru-server').with_content(/TSR_SSH_AGENT_PRIVATE_KEY=\/var\/lib\/super_secure_id_rsa/)
      end

    end

    it 'service tsuru-ssh-agent should be created and running' do
      should contain_service('tsuru-ssh-agent').with({
        'ensure'     => 'running',
        'enable'     => 'true',
        'hasrestart' => 'false',
        'hasstatus'  => 'true',
        'provider'   => 'upstart', 
      })
    end

  end

  it 'creates /etc/profile.d/docker.sh with alias to docker' do
    should contain_file('/etc/profile.d/docker.sh').with_content(/alias docker='docker -H=localhost'/)
  end

  it 'creates docker service, ensure running and notifies Package[lxc-docker], File[/etc/init/docker.conf] ' do
    should contain_service('docker').with_ensure('running')
    should contain_service('docker').that_subscribes_to('File[/etc/init/docker.conf]')
    should contain_service('docker').that_subscribes_to('Package[lxc-docker]')
  end 

  it 'install lxc-docker package that notifies service docker' do
    should contain_package('lxc-docker').that_notifies('Service[docker]')
  end

  it 'creates service docker file /etc/init/docker.conf' do
    should contain_file('/etc/init/docker.conf').with_content(/\/usr\/bin\/docker -r -d  -H 0.0.0.0:4243/)
  end

  it 'tsuru::params should be called before tsuru::docker' do
    should contain_class('tsuru::params').that_comes_before('Class[tsuru::docker]')
  end

end
