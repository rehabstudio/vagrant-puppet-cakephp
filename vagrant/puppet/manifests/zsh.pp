if $zsh_values == undef {
  $zsh_values = hiera('ohmyzsh', false)
}
class { 'ohmyzsh': }

if count($zsh_values['users']) > 0 {
  each( $zsh_values['users'] ) |$user| {
    ohmyzsh::install { $user: }
  }
}