require 'spec_helper'

describe 'base'  do

  let :facts do
    { :osfamily => 'Debian', :operatingsystem => 'Ubuntu', :lsbdistid => 'Ubuntu', :lsbdistcodename => 'precise' }
  end

  it 'contains class apt' do
    should contain_class('apt').with(
      :update => { 'frequency' => 'always', 'timeout' => 600 }
    )
  end

  it 'contains define apt::key{unauth}' do
    should contain_apt__conf('unauth')
  end

  it 'contains define apt::key{tsuru}' do
    should contain_apt__key('tsuru')
  end

  it 'contains define apt::key{docker}' do
    should contain_apt__key('docker')
  end

  context 'with default base' do
    it { should contain_apt__ppa('ppa:tsuru/ppa') }
    it { should contain_apt__source('docker').with(:location => 'https://apt.dockerproject.org/repo', :repos => 'main', :release => 'ubuntu-trusty') }
  end

  context 'setting custom source list' do

    let :params do {
      :tsuru_source_list  => 'tsuru_source_list_custom',
      :docker_source_list => 'docker_source_list_custom'
    }
    end

    it { should contain_apt__source('tsuru').with(:location => 'tsuru_source_list_custom') }
    it { should contain_apt__source('docker').with(:location => 'docker_source_list_custom') }
    context 'using custom release' do

      before do
        params.merge!( :docker_release => 'docker' )
      end

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

  context 'setting no repository' do
    let :params do {
      :no_repos => true
    }
    end

    it 'should no add extra repository for docker or tsuru' do
      should_not contain_apt__ppa('ppa:tsuru/ppa')
      should_not contain_apt__source('docker').with(:location => 'https://apt.dockerproject.org/repo', :repos => 'main', :release => 'ubuntu-trusty')
    end
  end

end
