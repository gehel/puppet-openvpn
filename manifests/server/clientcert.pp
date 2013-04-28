define openvpn::server::clientcert {

  exec { 'openvpn-client-cert':
    command => ". ${openvpn::server::easyrsa::easy_rsa_dir}/vars && ${openvpn::server::easyrsa::easy_rsa_dir}/build-key ${name}",
    cwd     => "${openvpn::server::easyrsa::easy_rsa_dir}",
    path    => '/bin:/usr/bin',
    creates => "${openvpn::server::easyrsa::easy_rsa_dir}/keys/${name}.crt",
    require => [File["${openvpn::server::easyrsa::easy_rsa_dir}/build-key"], File["${openvpn::server::easyrsa::easy_rsa_dir}/vars"]],
  }

}