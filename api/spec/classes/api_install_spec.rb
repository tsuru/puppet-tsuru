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
      it 'file /etc/tsuru/tsuru.conf must contain http configuration' do
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^listen: "0.0.0.0:8080"$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^host: "http://0.0.0.0:8080"$})
      end

      it 'file /etc/tsuru/tsuru.conf must contain database configuration' do
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^database:$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  url: localhost:27017$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  name: tsuru$})
        should contain_file('/etc/tsuru/tsuru.conf').without_content(%r{^  password: tsuru$})
      end

      it 'file /etc/tsuru/tsuru.conf must contain repository configuration' do
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^repo-manager: none$})
        should contain_file('/etc/tsuru/tsuru.conf').without_content(%r{^git:$})
        should contain_file('/etc/tsuru/tsuru.conf').without_content(%r{^  api-server:$})
      end

      it 'file /etc/tsuru/tsuru.conf must contain auth configuration' do
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^auth:$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  scheme: native$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  user-registration: true$})
      end

      it 'file /etc/tsuru/tsuru.conf must contain queue configuration' do
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^pubsub:$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  redis-host: localhost$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  redis-port: 6379$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  pool-max-idle-conn: 20$})
        should contain_file('/etc/tsuru/tsuru.conf').without_content(%r{^  redis-password:})
        should contain_file('/etc/tsuru/tsuru.conf').without_content(%r{^  redis-db:$})
      end

      it 'file /etc/tsuru/tsuru.conf must contain Admin users configuration' do
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^admin-team: admin$})
      end

      it 'file /etc/tsuru/tsuru.conf must contain routers with planb configuration' do
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^routers:$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  my_planb:$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    type: planb$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    domain: cloud.tsuru.io$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    redis-server: localhost:6379$})
      end

      it 'file /etc/tsuru/tsuru.conf must contain docker configuration' do
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^provisioner: docker$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  bs:$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    image: tsuru/bs$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    reporter-interval: 10$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    socket: /var/run/docker.sock$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  segregate: false$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  router: my_planb$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  collection: docker$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  repository-namespace: tsuru$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  deploy-cmd: /var/lib/tsuru/deploy$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  image-history-size: 10$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  cluster:$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    mongo-url: localhost:27017$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    mongo-database: tsuru$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  run-cmd:$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    bin: /var/lib/tsuru/start$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    port: 8888$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  user: tsuru$})
        should contain_file('/etc/tsuru/tsuru.conf').without_content(%r{^  healing:})
      end

      it 'file /etc/tsuru/tsuru.conf not contain iaas configuration' do
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

          :repo_manager   => 'gandalf',
          :git_api_server => 'localhost:9090',

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

          :redis_host     => 'localhost',
          :redis_port     => 6379,
          :redis_password => 'redis_password',
          :redis_db       => 'tsuru_redis_db',

          :tsuru_admin_team => 'admin',

          :tsuru_apps_per_user => 8,
          :tsuru_units_per_app => 20,

          :tsuru_provisioner                         => 'docker',
          :docker_bs_image                           => 'tsuru/custom_bs',
          :docker_bs_reporter_interval               => 20,
          :docker_bs_socket                          => '/tmp/docker.sock',
          :docker_segregate                          => true,
          :docker_registry                           => 'registry.tsuru.io',
          :docker_max_layers                         => 42,
          :docker_port_allocator                     => 'tsuru',
          :docker_router                             => 'my_planb',
          :docker_collection                         => 'docker',
          :docker_repository_namespace               => 'tsuru',
          :docker_deploy_cmd                         => '/var/lib/tsuru/deploy',
          :docker_cluster_mongo_url                  => 'localhost:27017',
          :docker_cluster_mongodb_db                 => 'tsuru',
          :docker_run_cmd_bin                        => '/var/lib/tsuru/start',
          :docker_run_cmd_port                       => '8888',
          :docker_user                               => 'tsuru',
          :docker_healing_heal_nodes                 => 'true',
          :docker_healing_active_monitoring_interval => 3,
          :docker_healing_disabled_time              => 40,
          :docker_healing_max_failures               => 10,
          :docker_healing_wait_new_time              => 400,
          :docker_healing_heal_containers_timeout    => 3,
          :docker_healing_events_collection          => 'healing_events',
          :docker_healthcheck_max_time               => 150,
          :docker_nodecontainer_max_workers          => 5,

          :iaas_node_protocol       => 'https',
          :iaas_node_port           => '4243',

          :tsuru_debug  => false,
        }
      end

      it 'file /etc/tsuru/tsuru.conf must contain http configuration' do
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^listen: "0.0.0.0:8080"$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^host: "http://tsuru.io:8080"$})
      end

      it 'file /etc/tsuru/tsuru.conf must contain tls configuration' do
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^use-tls: true$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  tls-cert-file: /var/lib/tsuru/cert_file.cert$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  tls-key-file: /var/lib/tsuru/key_file.key$})
      end

      it 'file /etc/tsuru/tsuru.conf must contain database configuration' do
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^database:$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  url: localhost:27017$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  name: tsuru$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  password: tsuru$})
      end

      it 'file /etc/tsuru/tsuru.conf must contain smtp configuration' do
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^smtp:$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  server: smtp.gmail.com$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  user: tsuru$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  password: tsuru$})
      end

      it 'file /etc/tsuru/tsuru.conf must contain git configuration' do
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^repo-manager: gandalf$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^git:$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  api-server: localhost:9090$})
      end

      it 'file /etc/tsuru/tsuru.conf must contain auth configuration' do
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^auth:$})
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

      it 'file /etc/tsuru/tsuru.conf must contain queue configuration' do
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^queue:$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  mongo-url: localhost:27017$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  mongo-database: tsuru$})
      end


      it 'file /etc/tsuru/tsuru.conf must contain pubsub configuration' do
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^pubsub:$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  redis-host: localhost$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  redis-port: 6379$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  redis-password: redis_password})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  redis-db: tsuru_redis_db$})
      end

      it 'file /etc/tsuru/tsuru.conf must contain admin users configuration' do
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^admin-team: admin$})
      end

      it 'file /etc/tsuru/tsuru.conf must contain routers with planb configuration' do
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^routers:$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  my_planb:$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    type: planb$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    domain: cloud.tsuru.io$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    redis-server: localhost:6379$})
      end

      it 'file /etc/tsuru/tsuru.conf must contain quota configuration' do
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^quota:$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  apps-per-user: 8$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  units-per-app: 20$})
      end


      it 'file /etc/tsuru/tsuru.conf must contain docker configuration' do
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^provisioner: docker$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  bs:$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    image: tsuru/custom_bs$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    reporter-interval: 20$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    socket: /tmp/docker.sock$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  segregate: true$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  registry: registry.tsuru.io$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  max-layers: 42$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  port-allocator: tsuru$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  router: my_planb$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  collection: docker$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  repository-namespace: tsuru$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  deploy-cmd: /var/lib/tsuru/deploy$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  image-history-size: 10$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  cluster:$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    mongo-url: localhost:27017$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    mongo-database: tsuru$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  run-cmd:$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    bin: /var/lib/tsuru/start$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    port: 8888$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  user: tsuru$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  healing:$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    heal-nodes: true$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    active-monitoring-interval: 3$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    disabled-time: 40$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    max-failures: 10$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    wait-new-time: 400$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    heal-containers-timeout: 3$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    events-collection : healing_events$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    max-time: 150$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  nodecontainer:$})
        should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    max-workers: 5$})
      end

      context 'using sentinel as pubsub' do
        before {
          params.merge!(
            :redis_sentinel_hosts => '10.10.10.10:26379, 10.20.20.20:26379',
            :redis_sentinel_master => 'master_sentinel',
            :redis_password => 'secret'
          )
        }
        let :match_string do
'
pubsub:
  redis-sentinel-addrs: 10.10.10.10:26379, 10.20.20.20:26379
  redis-sentinel-master: master_sentinel
  redis-password: secret
  redis-port: 6379
  pool-max-idle-conn: 20
  redis-db: tsuru_redis_db'
        end

        it 'file /etc/tsuru/tsuru.conf must contain sentinel config for pubsub' do
          should contain_file('/etc/tsuru/tsuru.conf').with_content(/.+#{match_string}/m)
        end
      end

      context 'setting unknown auth type' do
        before {
          params.merge!(
            :auth_scheme => 'whatever'
          )
        }

        it 'rises unknown auth type' do
          should raise_error(Puppet::Error, /Auth scheme unknown. Valid types are: native or oauth/)
        end
      end

      context 'setting routers hipache, planb, galeb, vulcand and api' do
        before {
            params.merge!(
              :routers => { 'bar_galeb' => {'router_type' => 'galeb', 'galeb_api_url' => 'galeb2.endpoint.com', 'galeb_username' => 'bilbo', 'galeb_password' => 'secret2',
                                            'galeb_domain' => 'cloud3.test.com', 'galeb_environment' => 'prod', 'galeb_project' => 'Y',
                                            'galeb_balance_policy' => 'ip-hash', 'galeb_rule_type' => '2', 'galeb_debug' => 'true', 'galeb_use_token' => true },
                            'foo_galeb' => {'router_type' => 'galeb', 'galeb_api_url' => 'galeb1.endpoint.com', 'galeb_username' => 'foobar', 'galeb_password' => 'secret',
                                            'galeb_domain' => 'cloud2.test.com', 'galeb_environment' => 'dev', 'galeb_project' => 'X',
                                            'galeb_balance_policy' => 'round-robin', 'galeb_rule_type' => '1'},
                            'foo_hipache' => {'router_type' => 'hipache', 'hipache_domain' => 'cloud.test.com', 'hipache_redis_server' => '10.10.10.10:6379' },
                            'foo_hipache_sentinel' => {'router_type' => 'hipache', 'hipache_domain' => 'cloud5.test.com', 'hipache_redis_sentinel_addrs' => '10.10.10.10:26379, 10.20.30.40:26379',
                                                       'hipache_redis_sentinel_master' => 'master_sentinel', 'hipache_redis_password' => 'secret'},
                            'foo_vulcand' => {'router_type' => 'vulcand', 'vulcand_api_url' => 'http://localhost:8009', 'vulcand_domain' => 'cloud4.test.com'},
                            'foo_planb' => {'router_type' => 'planb', 'planb_domain' => 'cloud.test.com', 'planb_redis_server' => '10.10.10.10:6379' },
                            'foo_api' => {'router_type' => 'api', 'api_url' => 'http://localhost:8090', 'api_debug' => true, 'api_headers' => ['KEY1: VAL1', 'KEY2: VAL2']},
                          }
            )
        }

        let :match_string do
'
routers:
  bar_galeb:
    type: galeb
    api-url: galeb2.endpoint.com
    username: bilbo
    password: secret2
    domain: cloud3.test.com
    environment: prod
    project: Y
    balance-policy: ip-hash
    rule-type: 2
    debug: true
    use-token: true
  foo_api:
    type: api
    api-url: http://localhost:8090
    headers:
      - KEY1: VAL1
      - KEY2: VAL2
    debug: true
  foo_galeb:
    type: galeb
    api-url: galeb1.endpoint.com
    username: foobar
    password: secret
    domain: cloud2.test.com
    environment: dev
    project: X
    balance-policy: round-robin
    rule-type: 1
    debug: false
    use-token: false
  foo_hipache:
    type: hipache
    domain: cloud.test.com
    redis-server: 10.10.10.10:6379
  foo_hipache_sentinel:
    type: hipache
    domain: cloud5.test.com
    redis-sentinel-addrs: 10.10.10.10:26379, 10.20.30.40:26379
    redis-sentinel-master: master_sentinel
    redis-password: secret
  foo_planb:
    type: planb
    domain: cloud.test.com
    redis-server: 10.10.10.10:6379
  foo_vulcand:
    type: vulcand
    api-url: http://localhost:8009
    domain: cloud4.test.com
'
        end

        it 'file /etc/tsuru/tsuru.conf must contain routers foo_hipache, foo_galeb, foo_planb and bar_galeb' do
          should contain_file('/etc/tsuru/tsuru.conf').with_content(/.+#{match_string}$/)
        end
      end

      context 'setting unknown router type' do
        before {
          params.merge!(
            :routers => {'test' => { 'router_type' => 'whatever', 'option1' => 'A', 'option2' => 'B' }}
          )
        }

        it 'rises unknown router type' do
          should raise_error(Puppet::Error, /Router type unknown. Valid types are: hipache, planb, vulcand or galeb/)
        end
      end


      context 'configuring iaas for cloudstack' do
        before {
          params.merge!(
            :tsuru_iaas_default       => 'cloudstack',
            :cloudstack_apikey        => 'cloudstack_apikey',
            :cloudstack_secretkey     => 'cloudstack_secretkey',
            :cloudstack_api_url       => 'https://cloudstack.tsuru.io',
            :cloudstack_user_data     => '/var/lib/user-data/docker_user_data.sh',
            :cloudstack_wait_timeout  => '600'
          )
        }
        it 'file /etc/tsuru/tsuru.conf must contain iaas configuration for cloudstack' do
          should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^iaas:$})
          should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  default: cloudstack$})
          should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  cloudstack:$})
          should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    api-key: cloudstack_apikey$})
          should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    secret-key: cloudstack_secretkey$})
          should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    url: https://cloudstack.tsuru.io$})
          should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    user-data: /var/lib/user-data/docker_user_data.sh$})
          should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    wait-timeout: 600$})
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
        it 'file /etc/tsuru/tsuru.conf must contain iaas configuration for ec2' do
          should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^iaas:$})
          should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  default: ec2$})
          should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  ec2:$})
          should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    key-id: ec2_key_id$})
          should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    secret-key: ec2_secret_key$})
          should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    user-data: /var/lib/user-data/docker_user_data.sh$})
          should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    wait-timeout: 400$})
        end
      end

      context 'setting custom iaas providers' do
        let :match_string do
'
iaas:
  default: ec2
  custom:
    test_cloudstack_1:
      provider: cloudstack
      url: https://cloudstack.tsuru.io
      api-key: "cloudstack_api_key_1"
      secret-key: "cloudstack_secret_key_1"
      user-data: user_data_1
      wait-timeout: 300
    test_cloudstack_2:
      provider: cloudstack
      url: https://cloudstack2.tsuru.io
      api-key: "cloudstack_api_key_2"
      secret-key: "cloudstack_secret_key_2"
      user-data: user_data_2
      wait-timeout: 300
    test_docker_machine:
      provider: dockermachine
      user-data: user_data_3
      debug: false
      driver:
        name: cloudstack
        user-data-file-param: cloudstack-userdata-file
        options:
          cloudstack-api-key: cloudstack_api_key_3
          cloudstack-secret-key: cloudstack_secret_key_3
          cloudstack-api-url: https://cloudstack3.tsuru.io
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
                                             'ec2_wait_timeout' => 2, 'ec2_user_data' => 'ec2_user_data'},
                              'test_docker_machine' => { 'provider' => 'dockermachine', 'dockermachine_user_data' => 'user_data_3',
                                                         'dockermachine_driver' => 'cloudstack', 'dockermachine_user_data_param' => 'cloudstack-userdata-file',
                                                         'driver' => { 'cloudstack_api_key' => 'cloudstack_api_key_3', 'cloudstack_secret_key' => 'cloudstack_secret_key_3',
                                                                       'cloudstack_api_url' => 'https://cloudstack3.tsuru.io'}}

                            }
          )
        }
        it 'file /etc/tsuru/tsuru.conf must contain iaas configuration for custom iaas for test_cloudstack_1, test_cloudstack_2, test_ec2 and test_docker_machine' do
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

      context 'using security-opts' do
        before {
          params.merge!(
            :docker_security_opts   => ['apparmor:foo', 'apparmor:bar']
          )
        }

        it 'writes apparmor:foo and bar to conf' do
          should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  security-opts:$})
          should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    - apparmor:foo$})
          should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    - apparmor:bar$})
        end
      end

      context 'only one security-opt set' do
        before {
          params.merge!(
            :docker_security_opts   => ['apparmor:foo']
          )
        }

        it 'writes apparmor:foo to conf' do
          should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^  security-opts:$})
          should contain_file('/etc/tsuru/tsuru.conf').with_content(%r{^    - apparmor:foo$})
        end
      end

      context 'security-opts not set' do
        it 'will not write security-opts' do
          should contain_file('/etc/tsuru/tsuru.conf').without_content(%r{^  security-opts:$})
        end
      end

      context 'auto-scale' do

        context 'using default options' do
          let :auto_scale_default_options do
'
  auto-scale:
    enabled: false
'
          end
          before {
            params.merge!( :docker_use_auto_scale => true)
          }

          it 'set auto-scale with disabled status' do
            should contain_file('/etc/tsuru/tsuru.conf').with_content(/.+#{auto_scale_default_options}.+/)
          end

        end

        context 'enable memory based' do

          before {
            params.merge!( :docker_scheduler_total_memory_metadata => 'memory',
                           :docker_scheduler_max_used_memory => 0.8
                         )
          }
          let :docker_scheduler_file do
'
  scheduler:
    total-memory-metadata: memory
    max-used-memory: 0.8
'
          end

          it { should contain_file('/etc/tsuru/tsuru.conf').with_content(/.+#{docker_scheduler_file}.+/) }

        end

        context 'set max-used-memory to -0.1' do

          before {
            params.merge!( :docker_scheduler_total_memory_metadata => 'memory',
                           :docker_scheduler_max_used_memory => -0.1  )
          }

          it 'raises puppet error with invalid max-used-memory' do
            should raise_error(Puppet::Error, /\$docker_scheduler_max_used_memory must be a value greater than 0/)
          end

        end

        context 'event trottling' do
          
          context 'using enabled options' do
            let :event_trottling_enabled_options do
'
event:
  throttling:
  - target-type: node
    kind-name: healer
    limit: 3
    window: 300
    all-targets: true
    wait-finish: true'
            end
            before {
              params.merge!( :event_throttling_enable => true,
                             :event_throttling_target_type => 'node',
                             :event_throttling_kind_name => 'healer',
                             :event_throttling_limit => 3,
                             :event_throttling_window => 300,
                             :event_throttling_all_targets => true,
                             :event_throttling_wait_finish => true)
            }
            it 'set event throttling with enable status' do
              should contain_file('/etc/tsuru/tsuru.conf').with_content(/.+#{event_trottling_enabled_options}.+/)
            end
          end
        end

      end

      it 'file /etc/tsuru/tsuru.conf must contain debug configuration' do
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
