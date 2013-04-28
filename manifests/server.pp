class openvpn::server (
  $country            = "CH",
  $province           = "VD",
  $city               = "Lausanne",
  $org                = "LedCom",
  $email,
  $cn                 = "LedCom - OpenVPN",
  $cert_name          = "LedCom - OpenVPN",
  $ou                 = "LedCom - Network",
  $pkcs11_module_path = "",
  $pkcs11_pin,
  $server_name,
  $port               = '1194',
  $proto              = 'udp',
  $dev                = 'tun',
  $network,
  $netmask            = '255.255.255.0',
  $verb = '3') {
  package { 'openvpn': ensure => present, }

  class { 'openvpn::server::easyrsa':
    country            => "${country}",
    province           => "${province}",
    city               => "${city}",
    org                => "${org}",
    email              => "${email}",
    cn                 => "${cn}",
    cert_name          => "${cert_name}",
    ou                 => "${ou}",
    pkcs11_module_path => "${pkcs11_module_path}",
    pkcs11_pin         => "${pkcs11_pin}",
    server_name        => "${server_name}",
  }

  file { '/var/log/openvpn/':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    require => [Package['openvpn'], Class['openvpn::server::easyrsa']],
  } -> file { '/etc/openvpn/server.conf':
    ensure  => present,
    content => template('openvpn/server.conf.erb'),
  } -> service { 'openvpn': ensure => running, }

}