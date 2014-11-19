#
# == Class: base
#
#  base used by other tsuru classes
#
# === Parameters
#
# [redis_source_list] Optional source list used instead tsuru PPA
# [redis_release]     Optional release name to used instead lsb dist code
# [tsuru_source_list] Optional source list used instead tsuru PPA
# [tsuru_release]     Optional release name to used instead lsb dist code
# [docker_source_list] Optional source list used instead tsuru PPA
# [docker_release]     Optional release name to used instead lsb dist code
# [nginx_source_list] Optional source list used instead tsuru PPA
# [nginx_release]     Optional release name to used instead lsb dist code
#

class base (
  $redis_source_list     = false,
  $redis_release         = $::lsbdistcodename,
  $tsuru_source_list     = false,
  $tsuru_release         = $::lsbdistcodename,
  $docker_source_list    = false,
  $docker_release        = $::lsbdistcodename,
  $nginx_dev_source_list = false,
  $nginx_dev_release     = $::lsbdistcodename,
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

$nginx_dev_pub_key = '
-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: SKS 1.1.4
Comment: Hostname: keyserver.ubuntu.com

mI0ETEc2OgEEALxNbtwubq7RMxez4yamifApqlEFYqcA+vvdOF0IJWK1h/+NcAdYdmZ+g+j4
q5n93qaCvI21jT6ldLvHUq2X1N506GIV21/Rhryc3WWA3F+cXwQ14uvu2IkQibJ57+9JGgMp
OglufOKltj7P/YdsXffBTUBDuhFYf7UaYm1Qzk1VABEBAAG0EExhdW5jaHBhZCBTdGFibGWI
tgQTAQIAIAUCTEc2OgIbAwYLCQgHAwIEFQIIAwQWAgMBAh4BAheAAAoJEACm8KPDAO6MudcD
/i2RPS//GmQ7/dLu+S27awxdiNqjL9mIBKjfrwp+Y3wg2315pUWa3y3s7NT+f5Vws5AWGZ46
uopHTg4MLZaXUxoja8lJgoKv6YpU6ptz1QPl/ISq3DozvelOcKPeKsvcz2L0ayZCK9LhkT2k
MmVzRQO3v15bdG2eiamGicO0w/ouiQIcBBABAgAGBQJNMFdUAAoJELlvIwCtEcvu8M4P/1zw
izfSeIa3t0wU0zZzr3BpLnhWrWBghPZS/Wem3biVMs6N22W8xXNiAGHWqTssWggd0O8/NXMK
UCfc8KMAPVFNBo6TM247eFc0FA2CMUFh4AGh2YvwoNQxJinugiWUALrFm9xGXKASvhvbSJCU
8SAtQFKGxjQbe6e5/exkj/YUpxfisyOYffsL9PSif4V8fjb4IQtTXAW/i+zDQq1ow5jsw6z7
si1i2ADWpsjjd85uhSzioz2lI6j5DUvPo6jGtY4hHw1FPp7omWILo6K8yuoMOryFIz3zayk2
WC1iV/I6LWE/1+Wg0ShLH22aPfHm8QseJZRUiBjpYUuaCasMlXdXWCzLHTTYGEB8xpFTJF+W
I98aywMRHW2OLFrn/3DH/mGeE2wIg3tnGgy1tugF397/MErLMbRSn2XE28CxBqsCy5T6TqA8
4d8UBN4I3ihLrM/6iQ0BKrtw7CLUX0aefcgIJDtWkajhTcqRZ3kbdbuBscYo+0CzCPOW2gdL
qSq4+WhyBgCSEn70aVB6+kDKW/uREmqGhZtS1HU109fJo503LWaVzA9zfHEwVEybtpsO45Ib
w/ZzJrgzit1cbS2cTfjpNKfpkeUaDE0y82HhIrCaonK0t9gfpnEwRqsxaupCP9j8p5oeVGwL
gKHRYeFhIBwHIPKb+LSIoUdK8zGno+1u
=4E5d
-----END PGP PUBLIC KEY BLOCK-----
'

  case $::operatingsystem {
    Ubuntu : { include base::ubuntu }
    CentOS : { include base::centos }
    default : { fail('OS not supported') }
  }

}
