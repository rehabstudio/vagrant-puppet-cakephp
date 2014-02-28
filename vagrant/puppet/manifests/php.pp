if $php_values == undef {
  $php_values = hiera('php', false)
}

if $cakephp_values == undef {
  $cakephp_values = hiera('cakephp', false)
}

Class['Php'] -> Class['Php::Devel'] -> Php::Module <| |> -> Php::Pear::Module <| |> -> Php::Pecl::Module <| |>

include nginx::params

$php_webserver_service     = "php5-fpm"
$php_webserver_service_ini = $php_webserver_service
$php_webserver_user        = $nginx::params::nx_daemon_user
$php_webserver_restart     = true
$php_fpm_ini               = '/etc/php5/fpm/php.ini'

class { 'php':
  package             => $php_webserver_service,
  service             => $php_webserver_service,
  service_autorestart => false,
  config_file         => $php_fpm_ini,
}

service { $php_webserver_service:
  ensure     => running,
  enable     => true,
  hasrestart => true,
  hasstatus  => true,
  require    => Package[$php_webserver_service]
}

class { 'php::devel': }

if count($php_values['modules']['php']) > 0 {
  php_mod { $php_values['modules']['php']:; }
}
if count($php_values['modules']['pear']) > 0 {
  php_pear_mod { $php_values['modules']['pear']:; }
}
if count($php_values['modules']['pecl']) > 0 {
  php_pecl_mod { $php_values['modules']['pecl']:; }
}
if count($php_values['ini']) > 0 {
  each( $php_values['ini'] ) |$key, $value| {
    if is_array($value) {
      each( $php_values['ini'][$key] ) |$innerkey, $innervalue| {
        php::ini { "${key}_${innerkey}":
          entry       => "CUSTOM_${innerkey}/${key}",
          value       => $innervalue,
          php_version => $php_values['version'],
          webserver   => $php_webserver_service_ini
        }
      }
    } else {
      php::ini { $key:
        entry       => "CUSTOM/${key}",
        value       => $value,
        php_version => $php_values['version'],
        webserver   => $php_webserver_service_ini
      }
    }
  }

  if $php_values['ini']['session.save_path'] != undef {
    exec {"mkdir -p ${php_values['ini']['session.save_path']}":
      onlyif  => "test ! -d ${php_values['ini']['session.save_path']}",
    }

    file { $php_values['ini']['session.save_path']:
      ensure  => directory,
      group   => 'www-data',
      mode    => 0775,
      require => Exec["mkdir -p ${php_values['ini']['session.save_path']}"]
    }
  }
}

php::ini { $key:
  entry       => 'CUSTOM/date.timezone',
  value       => $php_values['timezone'],
  php_version => $php_values['version'],
  webserver   => $php_webserver_service_ini
}

class { 'composer':
  target_dir      => '/usr/local/bin',
  composer_file   => 'composer',
  download_method => 'curl',
  logoutput       => false,
  tmp_path        => '/tmp',
  php_package     => "php5-cli",
  curl_package    => 'curl',
  suhosin_enabled => false,
}

composer::project { 'app':
  project_name   => $cakephp_values['project_name'],
  target_dir     => $cakephp_values['target_dir'],
  stability      => 'dev',
  dev            => true,
}

define php_mod {
  php::module { $name:
    service_autorestart => $php_webserver_restart,
  }
}
define php_pear_mod {
  php::pear::module { $name:
    use_package         => false,
    service_autorestart => $php_webserver_restart,
  }
}
define php_pecl_mod {
  php::pecl::module { $name:
    use_package         => false,
    service_autorestart => $php_webserver_restart,
  }
}
