# class rpaas
class rpaas {

  $service_provider = $::operatingsystem ? {
    Ubuntu          => 'upstart',
    CentOS          => 'init',
    default         => fail('OS not supported')
  }

  $ssl_command = 'sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
                  -keyout /etc/nginx/sites-enabled/dav/ssl/nginx.key \
                  -out /etc/nginx/sites-enabled/dav/ssl/nginx.crt \
                  -subj "/C=BR/ST=RJ/L=RJ/O=do not use me/OU=do not use me/CN=rpaas.tsuru"'

}
