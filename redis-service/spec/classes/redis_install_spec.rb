require 'spec_helper'

describe 'redis::init' do

    context 'on a Ubuntu OS' do
        let :facts do
            {
                :osfamily        => 'Debian',
                :operatingsystem => 'Ubuntu',
                :lsbdistid       => 'Ubuntu',
                :lsbdistcodename => 'trusty',
                :hostname        => 'foo.bar',
                :zabbix_enable   => true,
            }
        end

        it do
            should contain_service("redis-server")
        end
    end
end
