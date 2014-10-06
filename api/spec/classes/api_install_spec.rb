require 'spec_helper'

describe 'api::install' do

  context "on a Ubuntu OS" do
    let :facts do
      { :osfamily => 'Debian', :operatingsystem => 'Ubuntu', :lsbdistid => 'Ubuntu', :lsbdistcodename => 'precise', :hostname => 'foo.bar' }
    end

    context "with default parameters" do
      let :params do
        {
          :tsuru_server_version => 'latest',
        }
      end
      it 'file /etc/tsuru/tsuru.conf must contain http contiguration' do
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^listen: "0.0.0.0:8080"$})
      end

      it 'file /etc/tsuru/tsuru.conf must contain database contiguration' do
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^database:$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  url: localhost:27017$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  name: tsuru$})
        should contain_file('/etc/tsuru/tsuru.conf').without_content(%r{^  passord: tsuru$})
      end

      it 'file /etc/tsuru/tsuru.conf must contain git contiguration' do
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^git:$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  unit-repo: /home/application/current$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  api-server: localhost:9090$})
        should contain_file('/etc/tsuru/tsuru.conf').without_content(%r{^  rw-host:})
        should contain_file('/etc/tsuru/tsuru.conf').without_content(%r{^  ro-host:})
      end

      it 'file /etc/tsuru/tsuru.conf must contain auth contiguration' do
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^auth:$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  scheme: native$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  user-registration: true$})
      end

      it 'file /etc/tsuru/tsuru.conf must contain queue contiguration' do
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^queue: redis$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  host: localhost$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  port: 6379$})
        should contain_file('/etc/tsuru/tsuru.conf').without_content(%r{^  password:})
        should contain_file('/etc/tsuru/tsuru.conf').without_content(%r{^  db:$})
      end

      it 'file /etc/tsuru/tsuru.conf must contain Admin users contiguration' do
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^admin-team: admin$})
      end

      it 'file /etc/tsuru/tsuru.conf must contain hipache contiguration' do
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^hipache:$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  domain: cloud.tsuru.io$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  redis-server: localhost:6379$})
      end

      it 'file /etc/tsuru/tsuru.conf must contain docker contiguration' do
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^provisioner: docker$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  memory: 512$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  swap: 1024$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  segregate: false$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  router: hipache$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  collection: docker$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  repository-namespace: tsuru$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  deploy-cmd: /var/lib/tsuru/deploy$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  cluster:$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    mongo-url: localhost:27017$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    mongo-database: tsuru$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  run-cmd:$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    bin: /var/lib/tsuru/start$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    port: 8888$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  ssh:$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    add-key-cmd: /var/lib/tsuru/add-key$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    public-key: /var/lib/tsuru/.ssh/id_rsa.pub$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    user: tsuru$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    sshd-path: sudo /usr/sbin/sshd$})
        should contain_file('/etc/tsuru/tsuru.conf').without_content(%r{^  healing:})
      end

      it 'file /etc/tsuru/tsuru.conf not contain iaas contiguration' do
        should contain_file('/etc/tsuru/tsuru.conf').without_content(%r{^iaas:$})
      end

    end

    context "with all parameters" do
      let :params do
        {
          :tsuru_server_version => 'latest',

          :tsuru_server_listen => '0.0.0.0:8080',
          :tsuru_use_tls => 'true',
          :tsuru_tls_cert_file => '/var/lib/tsuru/cert_file.cert',
          :tsuru_tls_key_file => '/var/lib/tsuru/key_file.key',

          :mongodb_url => 'localhost:27017',
          :mongodb_database_name => 'tsuru',
          :mongodb_database_password => '',

          :smtp_server => '',
          :smtp_user => '',
          :smtp_password => '',

          :git_unit_repo => '/home/application/current',
          :git_api_server => 'localhost:9090',
          :git_rw_host => '',
          :git_ro_host => '',

          :auth_token_expire_days => '',
          :auth_hash_cost => '',
          :auth_user_registration => true,
          :auth_scheme => 'native',
          :oauth_client_id => '',
          :oauth_client_secret => '',
          :oauth_scope => '',
          :oauth_auth_url => '',
          :oauth_token_url => '',
          :oauth_info_url => '',
          :oauth_collection => '',
          :oauth_callback_port => '',

          :tsuru_queue => 'redis',
          :redis_host => 'localhost',
          :redis_port => 6379,
          :redis_password => '',
          :redis_db => '',

          :tsuru_admin_team => 'admin',

          :tsuru_apps_per_user => '',
          :tsuru_units_per_app => '',

          :hipache_domain => 'cloud.tsuru.io',
          :hipache_redis_server => 'localhost:6379',

          :tsuru_provisioner => 'docker',
          :docker_segregate => false,
          :docker_registry_server => '',
          :docker_router => 'hipache',
          :docker_collection => 'docker',
          :docker_repository_namespace => 'tsuru',
          :docker_deploy_cmd => '/var/lib/tsuru/deploy',
          :docker_cluster_mongo_url => 'localhost:27017',
          :docker_cluster_mongodb_db => 'tsuru',
          :docker_run_cmd_bin => '/var/lib/tsuru/start',
          :docker_run_cmd_port => '8888',
          :docker_ssh_add_key_cmd => '/var/lib/tsuru/add-key',
          :docker_public_key => '/var/lib/tsuru/.ssh/id_rsa.pub',
          :docker_user => 'tsuru',
          :docker_sshd_path => 'sudo /usr/sbin/sshd',
          :docker_healing_heal_nodes => '',
          :docker_healing_active_monitoring_interval => '',
          :docker_healing_disabled_time => '',
          :docker_healing_max_failures => '',
          :docker_healing_wait_new_time => '',
          :docker_healing_heal_containers_timeout => '',
          :docker_healing_events_collection => '',
          :docker_healthcheck_max_time => '',

          :tsuru_iaas_default => '',
          :cloudstack_apikey => '',
          :cloudstack_secretkey => '',
          :cloudstack_api_url => '',
          :cloudstack_user_data => '',
          :cloudstack_node_protocol => '',
          :cloudstack_node_port => '',
          :tsuru_debug => false,
        }
      end

      it 'file /etc/tsuru/tsuru.conf must contain http contiguration' do
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^listen: "0.0.0.0:8080"$})
      end

      it 'file /etc/tsuru/tsuru.conf must contain database contiguration' do
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^database:$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  url: localhost:27017$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  name: tsuru$})
        should contain_file('/etc/tsuru/tsuru.conf').without_content(%r{^  passord: tsuru$})
      end

      it 'file /etc/tsuru/tsuru.conf must contain git contiguration' do
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^git:$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  unit-repo: /home/application/current$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  api-server: localhost:9090$})
        should contain_file('/etc/tsuru/tsuru.conf').without_content(%r{^  rw-host:})
        should contain_file('/etc/tsuru/tsuru.conf').without_content(%r{^  ro-host:})
      end

      it 'file /etc/tsuru/tsuru.conf must contain auth contiguration' do
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^auth:$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  scheme: native$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  user-registration: true$})
      end

      it 'file /etc/tsuru/tsuru.conf must contain queue contiguration' do
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^queue: redis$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  host: localhost$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  port: 6379$})
        should contain_file('/etc/tsuru/tsuru.conf').without_content(%r{^  password:})
        should contain_file('/etc/tsuru/tsuru.conf').without_content(%r{^  db:$})
      end

      it 'file /etc/tsuru/tsuru.conf must contain Admin users contiguration' do
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^admin-team: admin$})
      end

      it 'file /etc/tsuru/tsuru.conf must contain hipache contiguration' do
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^hipache:$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  domain: cloud.tsuru.io$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  redis-server: localhost:6379$})
      end

      it 'file /etc/tsuru/tsuru.conf must contain docker contiguration' do
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^provisioner: docker$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  memory: 512$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  swap: 1024$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  segregate: false$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  router: hipache$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  collection: docker$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  repository-namespace: tsuru$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  deploy-cmd: /var/lib/tsuru/deploy$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  cluster:$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    mongo-url: localhost:27017$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    mongo-database: tsuru$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  run-cmd:$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    bin: /var/lib/tsuru/start$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    port: 8888$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  ssh:$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    add-key-cmd: /var/lib/tsuru/add-key$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    public-key: /var/lib/tsuru/.ssh/id_rsa.pub$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    user: tsuru$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    sshd-path: sudo /usr/sbin/sshd$})
        should contain_file('/etc/tsuru/tsuru.conf').without_content(%r{^  healing:})
      end

      it 'file /etc/tsuru/tsuru.conf not contain iaas contiguration' do
        should contain_file('/etc/tsuru/tsuru.conf').without_content(%r{^iaas:$})
      end

      it 'requires class base' do
        should contain_class('base')
      end

      it 'requires class base::ubuntu' do
        should contain_class('base::ubuntu')
      end

      it 'enabling tsuru-server-api service' do
        should contain_service('tsuru-server-api').with({
          :ensure => 'running',
          :enable => 'true'
        })
      end

      it 'package tsuru-server should be installed' do
        should contain_package('tsuru-server').with({
          :ensure => 'latest'
        })
      end

      it 'file /etc/tsuru/tsuru.conf must exists with all parameters' do
        should contain_file('/etc/tsuru/tsuru.conf').with_content(/servers:\n    - http:\/\/foo.localdomain:4243\n    - http:\/\/bar.localdomain:4243/)
      end
    end
  end
end
