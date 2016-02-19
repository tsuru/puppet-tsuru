# class rpaas
class rpaas {

  $service_provider = $::operatingsystem ? {
    Ubuntu          => 'upstart',
    CentOS          => 'init',
    default         => fail('OS not supported')
  }

  $dav_ssl_dir = '/etc/nginx/sites-enabled/dav/ssl'
  $dav_ssl_key_file = "${dav_ssl_dir}/nginx.key"
  $dav_ssl_crt_file = "${dav_ssl_dir}/nginx.crt"

  $consul_ssl_dir = '/etc/nginx/certs'
  $consul_ssl_key_file = "${consul_ssl_dir}/nginx.key"
  $consul_ssl_crt_file = "${consul_ssl_dir}/nginx.crt"



  $nginx_dirs = [ '/etc/nginx',
                  '/etc/nginx/sites-enabled',
                  '/etc/nginx/sites-enabled/dav',
                  '/etc/nginx/sites-enabled/consul',
                  '/etc/nginx/sites-enabled/consul/blocks',
                  $dav_ssl_dir,
                  $consul_ssl_dir ]


}
