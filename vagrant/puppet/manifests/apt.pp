if $server_values == undef {
  $server_values = hiera('server', false)
}

# Adding extra PPA's for more up to date software.
class { 'apt': }

Class['::apt::update'] -> Package <|
    title != 'python-software-properties'
and title != 'software-properties-common'
|>

ensure_packages( ['augeas-tools'] )

# Adding latest PHP packages
apt::key { '4F4EA0AAE5267A6C':
  key_server => 'hkp://keyserver.ubuntu.com:80'
}
apt::key { '4CBEDD5A':
  key_server => 'hkp://keyserver.ubuntu.com:80'
}

apt::ppa { 'ppa:pdoes/ppa': require => Apt::Key['4CBEDD5A'] }
apt::ppa { 'ppa:ondrej/php5': require => Apt::Key['4F4EA0AAE5267A6C'] }

if !empty($server_values['packages']) {
  ensure_packages( $server_values['packages'] )
}