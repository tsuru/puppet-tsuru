#
# == Class: bs
#
#  Big-Sibling
#
# === Parameters
#
# [log_backends] comma separated list of enabled log backends Eg 'tsuru,syslog'
# [metrics_backend]

class bs (
  $version                      = 'latest',
  $log_backends                 = undef,
  $metrics_backend              = undef,
  ){

  $envMap = {
    'LOG_BACKENDS'    => $log_backends,
    'METRICS_BACKEND' => $metrics_backend
  }

  $env = join(prefix(join_keys_to_values(delete_undef_values($envMap), '='), '-e '), ' ')

  exec { 'install bs':
    command => "/usr/bin/docker pull tsuru/bs:${version}",
    path    => '/usr/bin',
    require => Class['docker']
  }

  exec { 'start bs':
    command => "/usr/bin/docker run -d --restart='always' --name='big-sibling' ${env} tsuru/bs:${version}",
    path    =>  '/usr/bin',
    unless  =>  '/usr/bin/docker inspect --format="{{ .State.Running }}" $(docker ps -q)',
    require => Exec['install bs']
  }

}
