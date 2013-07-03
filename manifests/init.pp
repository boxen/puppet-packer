class packer(
  $ensure  = present,
  $root    = $packer::params::root,
  $user    = $packer::params::user,
  $version = $packer::params::version,
) inherits packer::params {

  case $ensure {
    present: {
      # the dir inside the zipball uses the major version number segment
      $major_version = split($version, '.')
      $extracted_dirname = $major_version[0]

      $install_command = join([
        # blow away any previous attempts
        "rm -rf /tmp/packer* /tmp/${extracted_dirname}",
        # download the zip to tmp
        "curl ${packer::params::download_url} > /tmp/packer-v${version}.zip",
        # extract the zip to root
        "unzip -o /tmp/packer-v${version}.zip -d /tmp",
        # blow away an existing version if there is one
        "rm -rf ${root}",
        # move the directory to the root
        "mv /tmp/${extracted_dirname} ${root}",
        # chown it
        "chown -R ${user} ${root}"
      ], ' && ')

      exec {
        "install packer v${version}":
          command => $install_command,
          unless  => "test -x ${root}/packer && ${root}/packer -v | grep '\\bv${version}\\b'",
          user    => $user,
      }

      if $::operatingsystem == 'Darwin' {
        include boxen::config

        file { "${boxen::config::envdir}/packer.sh":
          content => template("packer/env.sh.erb"),
          owner   => $user
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
      fail("Ensure must be present or absent")
    }
  }
}
