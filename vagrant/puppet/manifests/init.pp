include 'stdlib'
include locales

# globals
Exec {
  path => ['/bin', '/sbin', '/usr/bin', '/usr/local/bin', '/usr/sbin'],
}

# sub-manifests
import 'ntp.pp'
import 'apt.pp'
import 'users.pp'
import 'zsh.pp'
# import 'motd.pp'
import 'nginx.pp'
import 'ini.pp'
import 'php.pp'
import 'xdebug.pp'
import 'mysql.pp'
import 'nodejs.pp'
# import 'ruby_and_gems.pp'