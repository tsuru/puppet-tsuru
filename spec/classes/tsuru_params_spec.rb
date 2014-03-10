require 'spec_helper'

describe 'tsuru::params' do

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

end

