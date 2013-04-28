class openvpn::server::easyrsa ($country, $province, $city, $org, $email, $cn, $cert_name, $ou, $pkcs11_module_path, $pkcs11_pin, $server_name) {
  File {
    owner => 'root',
    group => 'root',
  }

  $easy_rsa_dir = '/etc/openvpn/easy-rsa'

  $easy_rsa_scripts = [
    "${easy_rsa_dir}/build-dh",
    "${easy_rsa_dir}/build-inter",
    "${easy_rsa_dir}/build-key-pass",
    "${easy_rsa_dir}/build-key-pkcs12",
    "${easy_rsa_dir}/build-req",
    "${easy_rsa_dir}/build-req-pass",
    "${easy_rsa_dir}/clean-all",
    "${easy_rsa_dir}/inherit-inter",
    "${easy_rsa_dir}/list-crl",
    "${easy_rsa_dir}/pkitool",
    "${easy_rsa_dir}/revoke-full",
    "${easy_rsa_dir}/sign-req",
    "${easy_rsa_dir}/whichopensslcnf",]

  file { "${easy_rsa_dir}":
    ensure  => directory,
    require => Package['openvpn'],
  } -> exec { 'openvpn-create-easy-rsa':
    command => "cp -R /usr/share/doc/openvpn/examples/easy-rsa/2.0/* ${easy_rsa_dir}",
    path    => '/bin:/usr/bin',
    creates => "${easy_rsa_dir}/pkitool",
  }

  file { $easy_rsa_scripts:
    mode    => '0755',
    require => Exec['openvpn-create-easy-rsa'],
  }

  file { "${easy_rsa_dir}/build-ca":
    content => template('openvpn/build-ca.erb'),
    mode    => '0755',
    require => Exec['openvpn-create-easy-rsa'],
  }

  file { "${easy_rsa_dir}/build-key-server":
    content => template('openvpn/build-key-server.erb'),
    mode    => '0755',
    require => Exec['openvpn-create-easy-rsa'],
  }

  file { "${easy_rsa_dir}/build-key":
    content => template('openvpn/build-key.erb'),
    mode    => '0755',
    require => Exec['openvpn-create-easy-rsa'],
  }

  file { "${easy_rsa_dir}/vars":
    content => template('openvpn/vars.erb'),
    mode    => '0755',
    require => Exec['openvpn-create-easy-rsa'],
  }

  exec { 'openvpn-clean-all':
    command => ". ${easy_rsa_dir}/vars && ${easy_rsa_dir}/clean-all",
    cwd     => "${easy_rsa_dir}",
    path    => '/bin:/usr/bin',
    creates => "${easy_rsa_dir}/keys/index.txt",
    require => [File["${easy_rsa_dir}/clean-all"], File["${easy_rsa_dir}/vars"]],
    notify => [Exec['openvpn-build-ca'],Exec['openvpn-build-key-server']]
  }

  exec { 'openvpn-build-ca':
    command => ". ${easy_rsa_dir}/vars && ${easy_rsa_dir}/build-ca",
    cwd     => "${easy_rsa_dir}",
    path    => '/bin:/usr/bin',
    creates => "${easy_rsa_dir}/keys/ca.crt",
    require => [File["${easy_rsa_dir}/build-ca"], File["${easy_rsa_dir}/vars"], Exec['openvpn-clean-all']],
  }

  exec { 'openvpn-build-key-server':
    command => ". ${easy_rsa_dir}/vars && ${easy_rsa_dir}/build-key-server ${server_name}",
    cwd     => "${easy_rsa_dir}",
    path    => '/bin:/usr/bin',
    creates => "${easy_rsa_dir}/keys/${server_name}.crt",
    require => [File["${easy_rsa_dir}/build-key-server"], File["${easy_rsa_dir}/vars"], Exec['openvpn-build-ca']],
  }

}