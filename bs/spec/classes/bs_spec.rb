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
				:command => 'docker pull tsuru/bs:latest'
			})
		end

		it 'starts the latest image' do
			should contain_exec('run').with({
				:command => "docker run -d --restart='always' --name='big-sibling' -v /proc:/prochost:ro -e DOCKER_ENDPOINT=unix:///var/run/docker.sock \
-e HOST_PROC=/prochost tsuru/bs:latest"
			})
		end

	end

	context 'when setting bs image to v1' do
		before { params.merge!( :image => 'tsuru/bs:v1' ) }
		it 'pull v1 image' do
			should contain_exec('pull image').with({
				:command => 'docker pull tsuru/bs:v1'
			})
		end

		it 'starts the v1 image' do
			should contain_exec('run').with({
				:command => "docker run -d --restart='always' --name='big-sibling' -v /proc:/prochost:ro -e DOCKER_ENDPOINT=unix:///var/run/docker.sock \
-e HOST_PROC=/prochost tsuru/bs:v1"
			})
		end
	end

	context 'when setting configurations' do
		before {params.merge!( :log_backends => 'tsuru', :metrics_backend => 'logstash')}
		it 'runs bs with the environment configuration' do
			should contain_exec('run').with({
				:command => "docker run -d --restart='always' --name='big-sibling' \
-v /proc:/prochost:ro -e LOG_BACKENDS=tsuru -e METRICS_BACKEND=logstash -e DOCKER_ENDPOINT=unix:///var/run/docker.sock \
-e HOST_PROC=/prochost tsuru/bs:latest"
			})
		end
	end
end
