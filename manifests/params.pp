# Internal: Default configuration for packer

class packer::params {
  $version = '0.7.5'

  $_real_kernel = downcase($::kernel)
  $_real_arch   = $::architecture ? {
    'amd64'  => 'amd64',
    'x86_64' => 'amd64',
    'x86'    => '386',
    'i386'   => '386',
    default  => 'arm'
  }

  $_real_platform = "${_real_kernel}_${_real_arch}"

  case $::operatingsystem {
    'Darwin': {
      include boxen::config

      $user = $::boxen_user

      $root = "${boxen::config::home}/packer"
    }

    default: {
      $user = 'root'
      $root = '/usr/local/packer'
    }
  }
}
