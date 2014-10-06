class router {

  $service_provider = $::operatingsystem ? {
    Ubuntu          => 'upstart',
    (CentOS/RedHat) => 'init',
    default         => fail('OS not supported')
  }

}
