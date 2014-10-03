require 'spec_helper'

describe 'base'  do

  let :facts do
    { :osfamily => 'RedHat', :operatingsystem => 'CentOS', :hostname => 'foo.bar' }
  end

  it 'requires class base' do
    should contain_class('base')
  end

  it 'requires class base::centos' do
    should contain_class('base::centos')
  end

end
