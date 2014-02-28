if $xdebug_values == undef {
  $xdebug_values = hiera('xdebug', false)
}

if $php_values == undef {
  $php_values = hiera('php', false)
}

$xdebug_webserver_service = 'nginx'

class { 'xdebug':
  service => $xdebug_webserver_service
}

if is_hash($xdebug_values['settings']) and count($xdebug_values['settings']) > 0 {
  each( $xdebug_values['settings'] ) |$key, $value| {
    php::ini { $key:
      entry       => "XDEBUG/${key}",
      value       => $value,
      php_version => $php_values['version'],
      webserver   => $xdebug_webserver_service
    }
  }
}