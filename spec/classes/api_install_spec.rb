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
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^host: "http://0.0.0.0:8080"$})
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
          :tsuru_host          => 'http://tsuru.io:8080',
          :tsuru_use_tls       => 'true',
          :tsuru_tls_cert_file => '/var/lib/tsuru/cert_file.cert',
          :tsuru_tls_key_file  => '/var/lib/tsuru/key_file.key',

          :mongodb_url               => 'localhost:27017',
          :mongodb_database_name     => 'tsuru',
          :mongodb_database_password => 'tsuru',

          :smtp_server   => 'smtp.gmail.com',
          :smtp_user     => 'tsuru',
          :smtp_password => 'tsuru',

          :git_unit_repo  => '/home/application/current',
          :git_api_server => 'localhost:9090',
          :git_rw_host    => 'rwhost.tsuru.io',
          :git_ro_host    => 'rohost.tsuru.io',

          :auth_token_expire_days => '8',
          :auth_hash_cost         => '5',
          :auth_user_registration => true,
          :auth_scheme            => 'oauth',
          :oauth_client_id        => 'oauth_client_id',
          :oauth_client_secret    => 'oauth_client_secret',
          :oauth_scope            => 'tsuru',
          :oauth_auth_url         => 'https://cloud.tsuru.io/authorize',
          :oauth_token_url        => 'https://cloud.tsuru.io/token',
          :oauth_info_url         => 'https://cloud.tsuru.io/info',
          :oauth_collection       => 'oauth_tokens',
          :oauth_callback_port    => '37621',

          :tsuru_queue    => 'redis',
          :redis_host     => 'localhost',
          :redis_port     => 6379,
          :redis_password => 'redis_password',
          :redis_db       => 'tsuru_redis_db',

          :tsuru_admin_team => 'admin',

          :tsuru_apps_per_user => 8,
          :tsuru_units_per_app => 20,

          :hipache_domain       => 'cloud.tsuru.io',
          :hipache_redis_server => 'localhost:6379',

          :tsuru_provisioner                         => 'docker',
          :docker_segregate                          => true,
          :docker_registry                           => 'registry.tsuru.io',
          :docker_router                             => 'hipache',
          :docker_collection                         => 'docker',
          :docker_repository_namespace               => 'tsuru',
          :docker_deploy_cmd                         => '/var/lib/tsuru/deploy',
          :docker_cluster_mongo_url                  => 'localhost:27017',
          :docker_cluster_mongodb_db                 => 'tsuru',
          :docker_run_cmd_bin                        => '/var/lib/tsuru/start',
          :docker_run_cmd_port                       => '8888',
          :docker_ssh_add_key_cmd                    => '/var/lib/tsuru/add-key',
          :docker_public_key                         => '/var/lib/tsuru/.ssh/id_rsa.pub',
          :docker_user                               => 'tsuru',
          :docker_sshd_path                          => 'sudo /usr/sbin/sshd',
          :docker_healing_heal_nodes                 => 'true',
          :docker_healing_active_monitoring_interval => 3,
          :docker_healing_disabled_time              => 40,
          :docker_healing_max_failures               => 10,
          :docker_healing_wait_new_time              => 400,
          :docker_healing_heal_containers_timeout    => 3,
          :docker_healing_events_collection          => 'healing_events',
          :docker_healthcheck_max_time               => 150,

          :iaas_node_protocol       => 'https',
          :iaas_node_port           => '4243',

          :tsuru_debug  => false,
        }
      end

      it 'file /etc/tsuru/tsuru.conf must contain http contiguration' do
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^listen: "0.0.0.0:8080"$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^host: "http://tsuru.io:8080"$})
      end

      it 'file /etc/tsuru/tsuru.conf must contain tls contiguration' do
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^use-tls: true$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  tls-cert-file: /var/lib/tsuru/cert_file.cert$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  tls-key-file: /var/lib/tsuru/key_file.key$})
      end

      it 'file /etc/tsuru/tsuru.conf must contain database contiguration' do
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^database:$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  url: localhost:27017$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  name: tsuru$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  password: tsuru$})
      end

      it 'file /etc/tsuru/tsuru.conf must contain smtp contiguration' do
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^smtp:$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  server: smtp.gmail.com$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  user: tsuru$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  password: tsuru$})
      end

      it 'file /etc/tsuru/tsuru.conf must contain git contiguration' do
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^git:$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  unit-repo: /home/application/current$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  api-server: localhost:9090$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  rw-host: rwhost.tsuru.io$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  ro-host: rohost.tsuru.io$})
      end

      it 'file /etc/tsuru/tsuru.conf must contain auth contiguration' do
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^auth:$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  token-expire-days: 8$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  hash-cost: 5$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  user-registration: true$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  scheme: oauth$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  oauth:$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    client-id: oauth_client_id$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    client-secret: oauth_client_secret$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    scope: tsuru$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    auth-url: https://cloud.tsuru.io/authorize$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    token-url: https://cloud.tsuru.io/token$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    info-url: https://cloud.tsuru.io/info$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    collection: oauth_tokens$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    callback-port: 37621$})
      end

      it 'file /etc/tsuru/tsuru.conf must contain queue contiguration' do
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^queue: redis$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  host: localhost$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  port: 6379$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  password: redis_password})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  db: tsuru_redis_db$})
      end

      it 'file /etc/tsuru/tsuru.conf must contain admin users contiguration' do
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^admin-team: admin$})
      end

      it 'file /etc/tsuru/tsuru.conf must contain quota contiguration' do
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^quota:$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  apps-per-user: 8$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  units-per-app: 20$})
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
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  segregate: true$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  registry: registry.tsuru.io$})
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
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  healing:$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    heal-nodes: true$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    active-monitoring-interval: 3$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    disabled-time: 40$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    max-failures: 10$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    wait-new-time: 400$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    heal-containers-timeout: 3$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    events-collection : healing_events$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    max-time: 150$})
      end

      context 'configuring iaas for cloudstack' do
        before {
          params.merge!(
            :tsuru_iaas_default       => 'cloudstack',
            :cloudstack_apikey        => 'cloudstack_apikey',
            :cloudstack_secretkey     => 'cloudstack_secretkey',
            :cloudstack_api_url       => 'https://cloudstack.tsuru.io',
            :cloudstack_user_data     => '/var/lib/user-data/docker_user_data.sh'
          )
        }
        it 'file /etc/tsuru/tsuru.conf must contain iaas contiguration for cloudstack' do
          should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^iaas:$})
          should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  default: cloudstack$})
          should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  cloudstack:$})
          should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    api-key: "cloudstack_apikey"$})
          should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    secret-key: "cloudstack_secretkey"$})
          should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    url: https://cloudstack.tsuru.io$})
          should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    user-data: /var/lib/user-data/docker_user_data.sh$})
        end
      end

      context 'configuring iaas for ec2' do
        before {
          params.merge!(
            :tsuru_iaas_default       => 'ec2',
            :ec2_key_id               => 'ec2_key_id',
            :ec2_secret_key           => 'ec2_secret_key',
            :ec2_wait_timeout         => 400,
            :ec2_user_data            => '/var/lib/user-data/docker_user_data.sh'
          )
        }
        it 'file /etc/tsuru/tsuru.conf must contain iaas contiguration for ec2' do
          should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^iaas:$})
          should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  default: ec2$})
          should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  ec2:$})
          should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    key-id: "ec2_key_id"$})
          should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    secret-key: "ec2_secret_key"$})
          should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    user-data: /var/lib/user-data/docker_user_data.sh$})
          should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    wait-timeout: 400$})
        end
      end

      context 'setting custom iaas providers' do
        let :match_string do
'
iaas:
  custom:
    test_cloudstack_1:
      provider: cloudstack
      url: https://cloudstack.tsuru.io
      api-key: "cloudstack_api_key_1"
      secret-key: "cloudstack_secret_key_1"
      user-data: user_data_1
    test_cloudstack_2:
      provider: cloudstack
      url: https://cloudstack2.tsuru.io
      api-key: "cloudstack_api_key_2"
      secret-key: "cloudstack_secret_key_2"
      user-data: user_data_2
    test_ec2:
      provider: ec2
      key-id: "ec2_key_id_1"
      secret-key: "ec2_secret_key_1"
      user-data: ec2_user_data
      wait-timeout: 2
'
        end
        before {
          params.merge!(
            :custom_iaas => { 'test_cloudstack_1' => { 'provider' => 'cloudstack', 'cloudstack_apikey' => 'cloudstack_api_key_1',
                                                       'cloudstack_secretkey' => 'cloudstack_secret_key_1', 'cloudstack_user_data' => 'user_data_1',
                                                       'cloudstack_api_url' => 'https://cloudstack.tsuru.io'},
                              'test_cloudstack_2' => { 'provider' => 'cloudstack', 'cloudstack_apikey' => 'cloudstack_api_key_2',
                                                      'cloudstack_secretkey' => 'cloudstack_secret_key_2', 'cloudstack_user_data' => 'user_data_2',
                                                      'cloudstack_api_url' => 'https://cloudstack2.tsuru.io'},
                              'test_ec2' => { 'provider' => 'ec2', 'ec2_key_id' => 'ec2_key_id_1', 'ec2_secret_key' => 'ec2_secret_key_1',
                                             'ec2_wait_timeout' => 2, 'ec2_user_data' => 'ec2_user_data'}
                            }
          )
        }
        it 'file /etc/tsuru/tsuru.conf must contain iaas configuration for custom iaas for test_cloudstack_1, test_cloudstack_2 and test_ec2' do
          should contain_file('/etc/tsuru/tsuru.conf').with_content(/.+#{match_string}.+/)
        end
      end

      context 'configuring iaas for ec2 and set default to unknow cloudstack provider' do
        before {
          params.merge!(
            :tsuru_iaas_default       => 'cloudstack',
            :ec2_key_id               => 'ec2_key_id',
            :ec2_secret_key           => 'ec2_secret_key',
            :ec2_wait_timeout         => 400,
            :ec2_user_data            => '/var/lib/user-data/docker_user_data.sh'
          )
        }
        it 'raises puppet error with cloudstack provider not set' do
          should raise_error(Puppet::Error, /\$tsuru_iaas_default set to cloudstack but iaas conf not set/)
        end
      end

      it 'file /etc/tsuru/tsuru.conf must contain debug contiguration' do
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^debug: false$})
      end

      it 'requires class base' do
        should contain_class('base')
      end

      it 'requires class base::ubuntu' do
        should contain_class('base::ubuntu')
      end

      it 'file /etc/default/tsuru-server must contain api configuration' do
        should contain_file('/etc/default/tsuru-server').with_content("TSR_API_ENABLED=yes")
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

    end
  end
end
