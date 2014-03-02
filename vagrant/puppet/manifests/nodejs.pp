if $nodejs_values == undef {
  $nodejs_values = hiera('nodejs', false)
}

# Installing nodejs.
class { 'nodejs':
  manage_repo => true
}

# install global packages
if count($nodejs_values['packages']) > 0 {
  package { $nodejs_values['packages']:
      ensure   => present,
      provider => 'npm',
      require  => Class['nodejs']
  }
}

# Install local packages
if defined(File[$nodejs_values['package_path']]) {
  nodejs::npm { $nodejs_values['package_path']:
    ensure  => present,
  }
}