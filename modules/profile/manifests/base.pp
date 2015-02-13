

class profile::base {

  file { '/root/.ssh':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0500',
  }

  package { [ 'ntpdate', 'git' ]:
    ensure => present,
  }


}
