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

  $ssl_command = '/usr/bin/sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
                  -keyout $dav_ssl_key_file \
                  -out $dav_ssl_crt_file \
                  -subj "/C=BR/ST=RJ/L=RJ/O=do not use me/OU=do not use me/CN=rpaas.tsuru"'

  $dav_dir = ['/etc/nginx/sites-enabled',
              '/etc/nginx/sites-enabled/dav',
              $dav_ssl_dir]
}
