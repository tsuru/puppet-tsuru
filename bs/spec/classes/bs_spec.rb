require 'spec_helper'

describe 'bs'  do

  let :facts do
    { :osfamily => 'Debian', :operatingsystem => 'Ubuntu', :lsbdistid => 'Ubuntu', :lsbdistcodename => 'precise' }
  end

  let :params do
    {}
  end

	it do
	  should contain_class('bs')
	end

	context 'without version' do
		it 'pull latest image' do
			should contain_exec('pull image').with({
				:command => '/usr/bin/docker pull tsuru/bs:latest'
			})
		end

		it 'starts the latest image' do
			should contain_exec('run').with({
				:command => "/usr/bin/docker run -d --restart='always' --name='big-sibling' -v /proc:/prochost:ro -e DOCKER_ENDPOINT=unix:///var/run/docker.sock \
-e HOST_PROC=/prochost tsuru/bs:latest"
			})
		end

	end

	context 'when setting bs image to v1' do
		before { params.merge!( :image => 'tsuru/bs:v1' ) }
		it 'pull v1 image' do
			should contain_exec('pull image').with({
				:command => '/usr/bin/docker pull tsuru/bs:v1'
			})
		end

		it 'starts the v1 image' do
			should contain_exec('run').with({
				:command => "/usr/bin/docker run -d --restart='always' --name='big-sibling' -v /proc:/prochost:ro -e DOCKER_ENDPOINT=unix:///var/run/docker.sock \
-e HOST_PROC=/prochost tsuru/bs:v1"
			})
		end
	end

	context 'when setting configurations' do
		before {params.merge!( :log_backends => 'tsuru', :metrics_backend => 'logstash')}
		it 'runs bs with the environment configuration' do
			should contain_exec('run').with({
				:command => "/usr/bin/docker run -d --restart='always' --name='big-sibling' \
-v /proc:/prochost:ro -e LOG_BACKENDS=tsuru -e METRICS_BACKEND=logstash -e DOCKER_ENDPOINT=unix:///var/run/docker.sock \
-e HOST_PROC=/prochost tsuru/bs:latest"
			})
		end
	end

	context 'when is already running and images are different' do
		before {facts.merge!( :bs_is_running => true, :bs_image => 'tsuru/bs:v0')}
		it 'stops bs' do
			should contain_exec('stop')
		end
	end

	context 'when is not already running' do
		before {facts.merge!( :bs_is_running => false)}
		it 'shouldnt try to stop bs' do
			should_not contain_exec('stop')
		end
	end

	context 'when is already running and images are equal' do
		before {
			facts.merge!( :bs_is_running => true, 
			:bs_envs_hash => { 
				'DOCKER_ENDPOINT' => 'unix:///var/run/docker.sock', 
				'HOST_PROC' => '/prochost'
			},
			:bs_image => "tsuru/bs:v2"
			)
			params.merge!(:image => 'tsuru/bs:v2')
		}

		it 'should not stop the container' do
			should_not contain_exec('stop')
		end
	end

	context 'when is already running and envs are different' do
		before {
			facts.merge!( :bs_is_running => true, 
			:bs_envs_hash => { 
				'DOCKER_ENDPOINT' => 'unix:///var/run/docker.sock', 
				'HOST_PROC' => ''
			},
			:bs_image => "tsuru/bs:v2"
			)
			params.merge!(:image => 'tsuru/bs:v2', :host_proc => '/prochost')
		}
		it 'should not stop the container' do
			should contain_exec('stop')
		end
	end
end
