require 'spec_helper'

describe 'tsuru::params'  do

  let :facts do
    { :osfamily => 'Debian', :operatingsystem => 'Ubuntu', :lsbdistid => 'Ubuntu', :lsbdistcodename => 'precise' }
  end

  it 'contains class apt' do
    should contain_class('apt').with(
      :always_apt_update => true,
      :disable_keys       => true,
      :update_timeout     => 600
    )
  end

  it 'contains define apt::key{tsuru}' do
    should contain_apt__key('tsuru')
  end

  it 'contains define apt::key{docker}' do
    should contain_apt__key('docker')
  end

  context 'with default params' do
    [ 'ppa:tsuru/redis-server', 'ppa:tsuru/ppa' ].each do |tsuru_ppa|
      it { should contain_apt__ppa(tsuru_ppa) }
    end
    it { should contain_apt__source('docker').with(:location => 'https://get.docker.io/ubuntu', :repos => 'main', :release => 'docker') }
  end

  context 'setting custom source list' do

    let :params do { 
      :tsuru_source_list  => 'tsuru_source_list_custom', 
      :redis_source_list  => 'redis_source_list_custom',
      :docker_source_list => 'docker_source_list_custom'
    }
    end

    it { should contain_apt__source('redis').with(:location => 'redis_source_list_custom') }
    it { should contain_apt__source('tsuru').with(:location => 'tsuru_source_list_custom') }
    it { should contain_apt__source('docker').with(:location => 'docker_source_list_custom') }
    context 'using custom release' do

      before do
        params.merge!( :docker_release => 'docker' )
      end

      it { should contain_apt__source('redis').with(:location => 'redis_source_list_custom', :release => 'precise') }
      it { should contain_apt__source('tsuru').with(:location => 'tsuru_source_list_custom', :release => 'precise') }
      it { should contain_apt__source('docker').with(:location => 'docker_source_list_custom', :release => 'docker') }

    end
  end

  context 'fail with wrong OS' do

    before do
      facts.merge!( :operatingsystem => 'RedHat' )
    end

    it 'install packages on RedHat system' do
      expect { should compile }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /OS not supported/)
    end

  end

end
