require 'spec_helper'

describe 'tsuru::params'  do

  let :facts do
    { :osfamily => 'Debian', :operatingsystem => 'Ubuntu', :lsbdistid => 'Ubuntu', :lsbdistcodename => 'precise' }
  end

  let (:tsuru_pub_key) {'
-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: SKS 1.1.4
Comment: Hostname: keyserver.ubuntu.com

mI0EUktBQAEEAJwPWcFy1B20SgKkF3QVvMoSJld+3bhrS6AT0fbYwv4RgpwekQGrnO5z4Otg
APTwe64jJPyCRneO0IC8Y5U2ILZNl50oFVrE3eMjdRp7Gy+9t1Kpq1fLlH/bER/YVkzmaomI
xA8ZWOWOXWrdf4IwGYtzmrBarAryHliSjXwXej+nABEBAAG0F0xhdW5jaHBhZCBQUEEgZm9y
IHRzdXJ1iLgEEwECACIFAlJLQUACGwMGCwkIBwMCBhUIAgkKCwQWAgMBAh4BAheAAAoJEDsB
U9A4Pwc9wpMD/RKIYfFBX3m7rsu0CELJwthyIaynjjMdl9AlVwc97Df2N2hVWR1hzTBFT43q
Qt//piVffD29fWIMG5ZuCFWMUPKOeljRLoX71kHVlgHBmJDSsE8ygYV1Y1RvGu/BBuNvn/ha
kDrSLb2SyfEoJ0psRDssSDHjOaIDEDpaACkSd+hm
=37Zt
-----END PGP PUBLIC KEY BLOCK-----
'}


  it 'contains class apt' do
    should contain_class('apt').with(
      :always_apt_update => true,
      :disable_keys       => true,
      :update_timeout     => 600
    )
  end

  it 'contains define apt::key{tsuru}' do
    should contain_apt__key('tsuru').with(
      :key  => '383F073D',
      :key_content => tsuru_pub_key
    )
  end

  context 'with default params' do
    [ 'ppa:tsuru/redis-server', 'ppa:tsuru/ppa', 'ppa:tsuru/docker', 'ppa:tsuru/lvm2'].each do |tsuru_ppa|
      it { should contain_apt__ppa(tsuru_ppa) }
    end
  end

  context 'setting custom source list' do

    let :params do { 
      :tsuru_source_list  => 'tsuru_source_list_custom', 
      :lvm2_source_list   => 'lvm2_source_list_custom',
      :redis_source_list  => 'redis_source_list_custom',
      :docker_source_list => 'docker_source_list_custom'
    }
    end

    it { should contain_apt__source('redis').with(:location => 'redis_source_list_custom') }
    it { should contain_apt__source('tsuru').with(:location => 'tsuru_source_list_custom') }
    it { should contain_apt__source('lvm2').with(:location => 'lvm2_source_list_custom') }
    it { should contain_apt__source('docker').with(:location => 'docker_source_list_custom') }

  end

  context 'fail with wrong OS' do

    before do
      facts.merge!( :operatingsystem => 'RedHat' )
    end

    it 'install packages on RedHat system' do
      expect { should compile }.to raise_error(Puppet::Error, /OS not supported/)
    end

  end

end
