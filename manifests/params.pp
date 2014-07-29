#
# == Class: tsuru::params
#
#  Params used by other tsuru classes
#
# === Parameters
#
# [redis_source_list] Optional source list used instead tsuru PPA
# [redis_release]     Optional release name to used instead lsb dist code
# [tsuru_source_list] Optional source list used instead tsuru PPA
# [tsuru_release]     Optional release name to used instead lsb dist code
# [docker_source_list] Optional source list used instead tsuru PPA
# [docker_release]     Optional release name to used instead lsb dist code
#

class tsuru::params (
  $redis_source_list    = false,
  $redis_release        = $::lsbdistcodename,
  $tsuru_source_list    = false,
  $tsuru_release        = $::lsbdistcodename,
  $docker_source_list   = false,
  $docker_release       = $::lsbdistcodename
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

$docker_pub_key = '
-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v1.4.11 (GNU/Linux)

mQENBFIOqEUBCADsvqwefcPPQArws9jHF1PaqhXxkaXzeE5uHHtefdoRxQdjoGok
HFmHWtCd9zR7hDpHE7Q4dwJtSFWZAM3zaUtlvRAgvMmfLm08NW9QQn0CP5khjjF1
cgckhjmzQAzpEHO5jiSwl0ZU8ouJrLDgmbhT6knB1XW5/VmeECqKRyhlEK0zRz1a
XV+4EVDySlORmFyqlmdIUmiU1/6pKEXyRBBVCHNsbnpZOOzgNhfMz8VE8Hxq7Oh8
1qFaFXjNGCrNZ6xr/DI+iXlsZ8urlZjke5llm4874N8VPUeFQ/szmsbSqmCnbd15
LLtrpvpSMeyRG+LoTYvyTG9QtAuewL9EKJPfABEBAAG0OURvY2tlciBSZWxlYXNl
IFRvb2wgKHJlbGVhc2Vkb2NrZXIpIDxkb2NrZXJAZG90Y2xvdWQuY29tPokBOAQT
AQIAIgUCUg6oRQIbLwYLCQgHAwIGFQgCCQoLBBYCAwECHgECF4AACgkQ2Fdqi6iN
IenM+QgAnOiozhHDAYGO92SmZjib6PK/1djbrDRMreCT8bnzVpriTOlEtARDXsmX
njKSFa+HTxHi/aTNo29TmtHDfUupcfmaI2mXbZt1ixXLuwcMv9sJXKoeWwKZnN3i
9vAM9/yAJz3aq+sTXeG2dDrhZr34B3nPhecNkKQ4v6pnQy43Mr59Fvv5CzKFa9oZ
IoZf+Ul0F90HSw5WJ1NsDdHGrAaHLZfzqAVrqHzazw7ghe94k460T8ZAaovCaTQV
HzTcMfJdPz/uTim6J0OergT9njhtdg2ugUj7cPFUTpsxQ1i2S8qDEQPL7kabAZZo
Pim0BXdjsHVftivqZqfWeVFKMorchQ==
=fRgo
-----END PGP PUBLIC KEY BLOCK-----
'

  case $::operatingsystem {

    /Ubuntu/ : {

      class { 'apt':
        always_apt_update => true,
        disable_keys      => true,
        update_timeout    => 600
      }

      apt::key { 'tsuru':
        key         => '383F073D',
        key_content => $tsuru_pub_key
      }

      apt::key { 'docker':
        key         => 'A88D21E9',
        key_content => $docker_pub_key
      }

      if ($redis_source_list) {
        apt::source { 'redis':
          location      => $redis_source_list,
          include_src   => false,
          repos         => 'main',
          release       => $redis_release,
          require       => Apt::Key['tsuru']
        }
      } else {
        apt::ppa { 'ppa:tsuru/redis-server':
          release     => $redis_release,
          require     => Apt::Key['tsuru']
        }
      }

      if ($tsuru_source_list) {
        apt::source { 'tsuru':
          location    => $tsuru_source_list,
          include_src => false,
          repos       => 'main',
          release     => $tsuru_release,
          require     => Apt::Key['tsuru']
        }
      } else {
        apt::ppa { 'ppa:tsuru/ppa':
          release     => $tsuru_release,
          require     => Apt::Key['tsuru']
        }
      }

      if ($docker_source_list) {
        apt::source { 'docker' :
          location    => $docker_source_list,
          include_src => false,
          repos       => 'main',
          release     => $docker_release,
          require     => Apt::Key['docker']
        }
      } else {
        apt::source { 'docker' :
          location    => 'https://get.docker.io/ubuntu',
          include_src => false,
          repos       => 'main',
          release     => 'docker',
          require     => Apt::Key['docker']
        }
      }


    }

    default : { fail('OS not supported') }
  }

}
