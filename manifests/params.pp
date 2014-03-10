# class tsuru::params
class tsuru::params (
  $redis_source_list  = false,
  $tsuru_source_list  = false,
  $docker_source_list = false,
  $lvm2_source_list   = false
) {

  $tsuru_pub_key = '
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
'

  class { 'apt':
    always_apt_update => true,
    disable_keys      => true,
    update_timeout    => 600
  }

  apt::key { 'tsuru':
      key         => '383F073D',
      key_content => $tsuru_pub_key
  }

  if ($redis_source_list) {
    apt::source { 'redis':
      location    => $redis_source_list,
      include_src => false,
      repos       => 'main',
      require     => Apt::Key['tsuru']
    }
  } else {
    apt::ppa { 'ppa:tsuru/redis-server':
      require     => Apt::Key['tsuru']
    }
  }

  if ($tsuru_source_list) {
    apt::source { 'tsuru':
      location    => $tsuru_source_list,
      include_src => false,
      repos       => 'main',
      require     => Apt::Key['tsuru']
    }
  } else {
    apt::ppa { 'ppa:tsuru/ppa':
      require     => Apt::Key['tsuru']
    }
  }

  if ($docker_source_list) {
    apt::source { 'docker' :
      location    => $docker_source_list,
      include_src => false,
      repos       => 'main',
      require     => Apt::Key['tsuru']
    }
  } else {
    apt::ppa { 'ppa:tsuru/docker':
      require     => Apt::Key['tsuru']
    }
  }

  if ($lvm2_source_list) {
    apt::source { 'lvm2' :
      location    => $lvm2_source_list,
      include_src => false,
      repos       => 'main',
      require     => Apt::Key['tsuru']
    }
  } else {
    apt::ppa { 'ppa:tsuru/lvm2':
      require     => Apt::Key['tsuru']
    }
  }

}
