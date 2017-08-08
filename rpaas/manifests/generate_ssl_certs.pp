# rpaas::generate_ssl_certs
define rpaas::generate_ssl_certs ($key,$crt) {
  $ssl_command = "/usr/bin/sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
                 -keyout ${key} \
                 -out ${crt} \
                 -subj \"/C=BR/ST=RJ/L=RJ/O=do not use me/OU=do not use me/CN=rpaas.tsuru\""

  exec { "ssl_${title}":
    path    => '/etc/nginx',
    command => $ssl_command,
    onlyif  => ["/usr/bin/test ! -f ${key}",
                "/usr/bin/test ! -f ${crt}"],
    require => [File['/etc/nginx'], File[$rpaas::consul_ssl_dir]]
  }

  file { [$key, $crt]:
    ensure  => file,
    owner   => $rpaas::install::nginx_user,
    group   => $rpaas::install::nginx_group,
    require => Exec["ssl_${title}"],
  }
}
