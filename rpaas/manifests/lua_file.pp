define rpaas::lua_file ($lua_type){
  file { "/etc/consul-template.d/templates/lua_${lua_type}.conf.tpl":
    ensure  => file,
    content => template('rpaas/consul/lua.conf.tpl.erb'),
    require => File['/etc/consul-template.d/templates']
  }
}
