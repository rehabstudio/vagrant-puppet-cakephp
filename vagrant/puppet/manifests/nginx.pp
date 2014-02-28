# Installing nginx package and setting up its conf file.

if $nginx_values == undef {
   $nginx_values = hiera('nginx', false)
}

$php5_fpm_sock = '/var/run/php5-fpm.sock'
$fastcgi_pass = "unix:${php5_fpm_sock}"
$fastcgi_param_parts = [
  'PATH_INFO $fastcgi_path_info',
  'PATH_TRANSLATED $document_root$fastcgi_path_info',
  'SCRIPT_FILENAME $document_root$fastcgi_script_name'
]

class { 'nginx': }

# Create vhosts
if count($nginx_values['vhosts']) > 0 {
  # each( $nginx_values['vhosts'] ) |$key, $vhost| {
  #   exec { "exec mkdir -p ${vhost['www_root']} @ key ${key}":
  #     command => "mkdir -p ${vhost['www_root']}",
  #     creates => $vhost['docroot'],
  #   }

  #   if ! defined(File[$vhost['www_root']]) {
  #     file { $vhost['www_root']:
  #       ensure  => directory,
  #       require => Exec["exec mkdir -p ${vhost['www_root']} @ key ${key}"]
  #     }
  #   }
  # }

  create_resources(nginx_vhost, $nginx_values['vhosts'])
}

define nginx_vhost (
  $server_name,
  $server_aliases = [],
  $www_root,
  $listen_port,
  $index_files,
  $envvars = [],
){
  $merged_server_name = concat([$server_name], $server_aliases)

  if is_array($index_files) and count($index_files) > 0 {
    $try_files = $index_files[count($index_files) - 1]
  } else {
    $try_files = 'index.php'
  }

  nginx::resource::vhost { $server_name:
    server_name => $merged_server_name,
    www_root    => $www_root,
    listen_port => $listen_port,
    index_files => $index_files,
    try_files   => ['$uri', '$uri/', "/${try_files}?\$args"],
    vhost_cfg_append => {
       sendfile => 'off'
    }
  }

  $fastcgi_param = concat($fastcgi_param_parts, $envvars)

  nginx::resource::location { "${server_name}-php":
    ensure              => present,
    vhost               => $server_name,
    location            => '~ \.php$',
    proxy               => undef,
    try_files           => ['$uri', '$uri/', "/${try_files}?\$args"],
    www_root            => $www_root,
    location_cfg_append => {
      'fastcgi_split_path_info' => '^(.+\.php)(/.+)$',
      'fastcgi_param'           => $fastcgi_param,
      'fastcgi_pass'            => $fastcgi_pass,
      'fastcgi_index'           => 'index.php',
      'include'                 => 'fastcgi_params'
    },
    notify              => Class['nginx::service'],
  }
}