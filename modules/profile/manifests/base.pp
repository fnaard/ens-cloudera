# This class manages a few things that would normally be already managed
# by your existing profile::base module.  It is provided here as a convenience
# when testing the profile::cdh:: classes.
#
# For instance, most sites already manage the presence, owner and permissions
# of /root/.ssh.  However, on a test node, the profile::cdh:: classes may be
# being applied by themselves.  Including this class simulates a machine
# where a pre-existing profile::base would have been normally installed.

class profile::base {

  file { '/root/.ssh':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0500',
  }
  package { [ 'ntpdate' ]:
    ensure => present,
  }

}
