# Public: Installs a version of Packer
#
# Params:
#
#  ensure  -- must be present or absent, default present
#  root    -- the path to install packer to, see packer::params for default
#  user    -- the user to install packer as, see packer::params for default
#  version -- the version of packer to ensure, see packer::params for default

class packer(
  $ensure  = present,
  $root    = $packer::params::root,
  $user    = $packer::params::user,
  $version = $packer::params::version,
) inherits packer::params {

  case $ensure {
    present: {
      # get the download URI
      $download_uri = "http://dl.bintray.com/mitchellh/packer/packer_${version}_${packer::params::_real_platform}.zip?direct"

      # the dir inside the zipball uses the major version number segment
      $major_version = split($version, '[.]')
      $extracted_dirname = $major_version[0]

      $install_command = join([
        # blow away any previous attempts
        "rm -rf /tmp/packer* /tmp/${extracted_dirname}",
        # download the zip to tmp
        "curl -L ${download_uri} > /tmp/packer-v${version}.zip",
        # extract the zip to tmp spot
        'mkdir /tmp/packer',
        "unzip -o /tmp/packer-v${version}.zip -d /tmp/packer",
        # blow away an existing version if there is one
        "rm -rf ${root}",
        # move the directory to the root
        "mv /tmp/packer ${root}",
        # chown it
        "chown -R ${user} ${root}"
      ], ' && ')

      exec {
        "install packer v${version}":
          command => $install_command,
          unless  => "test -x ${root}/packer && ${root}/packer version | grep '\\bv${version}\\b'",
          user    => $user,
      }

      if $::operatingsystem == 'Darwin' {
        include boxen::config

        boxen::env_script { 'packer':
          content  => template('packer/env.sh.erb'),
          priority => 'lower',
        }

        file { "${boxen::config::envdir}/packer.sh":
          ensure => absent,
        }
      }
    }

    absent: {
      file { $root:
        ensure  => absent,
        recurse => true,
        force   => true,
      }
    }

    default: {
      fail('Ensure must be present or absent')
    }
  }
}
