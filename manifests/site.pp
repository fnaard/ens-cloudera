
Package { allow_virtual => true, }

node default {
  notify { "Darn, ${::clientcert} did not match a node definition.": }
}

# Puppet Master
node 'animal.puppetlabs.vm' {
  service { 'firewalld': ensure => stopped, enable => false, } #shotgun
  include profile::base
}

# CDH Master
node 'grover.puppetlabs.vm' {
  include profile::base
  include profile::cdh::manager
}

# CDH Nodes
node 'bert.puppetlabs.vm' {
  include profile::base
  include profile::cdh::host
}

node 'ernie.puppetlabs.vm' {
  include profile::base
  include profile::cdh::host
}

#
# New cdh5 deployment 'janice'
#

# Cloudera Manager machine
node 'janice.puppetlabs.vm' {
  include profile::base
  class { 'profile::cdh::manager':
    deployment => 'janice',
  }
}

node 'zoot.puppetlabs.vm' {
  include profile::base
  class { 'profile::cdh::host':
    deployment => 'janice',
  }
}
node 'teeth.puppetlabs.vm' {
  include profile::base
  class { 'profile::cdh::host':
    deployment => 'janice',
  }
}
