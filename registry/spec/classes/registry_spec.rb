require 'spec_helper'

describe 'registry'  do

  before (:each) do
    FileUtils.stubs(:mkdir_p).returns(true)
  end

  let :facts do
    { :osfamily => 'Debian', :operatingsystem => 'Ubuntu', :lsbdistid => 'Ubuntu', :lsbdistcodename => 'precise', :hostname => 'foo.bar' }
  end

  let :params do
    {
      :storage       => 'cloudfronts3'
    }
  end

  it do
    should contain_class('base')
  end

  it do
    should contain_file('/etc/init/docker-registry.conf')
  end

  it do
    should contain_file('/etc/docker-registry/config/config.yml')
  end

end
