

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

  ssh_authorized_key { 'gabe@puppetlabs.com':
    ensure => present,
    type => 'ssh-rsa',
    key => 'AAAAB3NzaC1yc2EAAAADAQABAAABAQDGQQQpjUTzPoSy3UzELRiW8wNyg+tTZCu+Ic1/hiBaWkh5gNeFY8sAIKGGrpUu0EQaJVNLCTVZMP23Ok0uVCtkxJP2KAtu3VQXQYjcB8E1VTzaarbEmySlAjWvFTTPr020qcMddeYFYIURZSw6wv69ufrV1QMCES8mZCLlA/mwDpn8Mwd0R72KcGGcV8IeHoJPD6a1hVMa8xpT2KE9nBCg3HqXausOEgYKM9Cz1nrWaGSPFhconztqypMgq3nf25eMtviJJ2r5IlTvWOaOMxFJzxEe82oT8amff2eUOT+Co4M7kaxkJ/l9RnVLI5D31JzcfRJBIDLyuuF9iHTesSNN',
    user => root,
  }


}
