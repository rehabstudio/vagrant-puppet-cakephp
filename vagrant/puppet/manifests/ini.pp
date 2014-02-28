define php::ini (
  $php_version,
  $webserver,
  $ini_filename = 'zzzz_custom.ini',
  $entry,
  $value  = '',
  $ensure = present
  ) {

  $real_webserver = $webserver ? {
    'apache'   => 'apache2',
    'httpd'    => 'apache2',
    'apache2'  => 'apache2',
    'nginx'    => 'fpm',
    'php5-fpm' => 'fpm',
    'php-fpm'  => 'fpm',
    'fpm'      => 'fpm',
    'cgi'      => 'cgi',
    'fcgi'     => 'cgi',
    'fcgid'    => 'cgi',
    undef      => undef,
  }

  case $php_version {
    '5.3', '53': {
      case $::osfamily {
        'debian': {
          $target_dir  = '/etc/php5/conf.d'
          $target_file = "${target_dir}/${ini_filename}"

          if ! defined(File[$target_file]) {
            file { $target_file:
              replace => no,
              ensure  => present,
              require => Package['php']
            }
          }
        }
        'redhat': {
          $target_dir  = '/etc/php.d'
          $target_file = "${target_dir}/${ini_filename}"

          if ! defined(File[$target_file]) {
            file { $target_file:
              replace => no,
              ensure  => present,
              require => Package['php']
            }
          }
        }
        default: { fail('This OS has not yet been defined for PHP 5.3!') }
      }
    }
    '5.4', '54': {
      case $::osfamily {
        'debian': {
          $target_dir  = '/etc/php5/mods-available'
          $target_file = "${target_dir}/${ini_filename}"

          if ! defined(File[$target_file]) {
            file { $target_file:
              replace => no,
              ensure  => present,
              require => Package['php']
            }
          }

          $symlink = "/etc/php5/conf.d/${ini_filename}"

          if ! defined(File[$symlink]) {
            file { $symlink:
              ensure  => link,
              target  => $target_file,
              require => File[$target_file],
            }
          }
        }
        'redhat': {
          $target_dir  = '/etc/php.d'
          $target_file = "${target_dir}/${ini_filename}"

          if ! defined(File[$target_file]) {
            file { $target_file:
              replace => no,
              ensure  => present,
              require => Package['php']
            }
          }
        }
        default: { fail('This OS has not yet been defined for PHP 5.4!') }
      }
    }
    '5.5', '55': {
      case $::osfamily {
        'debian': {
          $target_dir  = '/etc/php5/mods-available'
          $target_file = "${target_dir}/${ini_filename}"

          $webserver_ini_location = $real_webserver ? {
              'apache2' => '/etc/php5/apache2/conf.d',
              'cgi'     => '/etc/php5/cgi/conf.d',
              'fpm'     => '/etc/php5/fpm/conf.d',
              undef     => undef,
          }
          $cli_ini_location = '/etc/php5/cli/conf.d'

          if ! defined(File[$target_file]) {
            file { $target_file:
              replace => no,
              ensure  => present,
              require => Package['php']
            }
          }

          if $webserver_ini_location != undef and ! defined(File["${webserver_ini_location}/${ini_filename}"]) {
            file { "${webserver_ini_location}/${ini_filename}":
              ensure  => link,
              target  => $target_file,
              require => File[$target_file],
            }
          }

          if ! defined(File["${cli_ini_location}/${ini_filename}"]) {
            file { "${cli_ini_location}/${ini_filename}":
              ensure  => link,
              target  => $target_file,
              require => File[$target_file],
            }
          }
        }
        'redhat': {
          $target_dir  = '/etc/php.d'
          $target_file = "${target_dir}/${ini_filename}"

          if ! defined(File[$target_file]) {
            file { $target_file:
              replace => no,
              ensure  => present,
              require => Package['php']
            }
          }
        }
        default: { fail('This OS has not yet been defined for PHP 5.5!') }
      }
    }
    default: { fail('Unrecognized PHP version') }
  }

  if $real_webserver != undef {
    if $real_webserver == 'cgi' {
      $webserver_service = 'apache2'
    } else {
      $webserver_service = $webserver
    }

    $notify_service = Service[$webserver_service]
  } else {
    $notify_service = []
  }

  php::augeas{ "${entry}-${value}" :
    target  => $target_file,
    entry   => $entry,
    value   => $value,
    ensure  => $ensure,
    require => File[$target_file],
    notify  => $notify_service,
  }

}