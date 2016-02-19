define rpaas::block_file ($block_type){
  file { "/etc/consul-template.d/templates/block_${block_type}.conf.tpl":
    ensure  => file,
    content => template('rpaas/consul/block.conf.tpl.erb'),
    require => File['/etc/consul-template.d/templates']
  }
}
