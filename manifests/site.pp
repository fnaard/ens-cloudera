# Example site.pp
#

# Avoid deprecation warnings when Puppet installs packages.
# This has nothing to do with Cloudera.
Package { allow_virtual => true, }

# Don't do anything if a node is not found.  Report it.
node default {
  notify { "Darn, ${::clientcert} did not match a node definition.": }
}


# Puppet Master
node 'hoggle.puppetlabs.vm' {
  include profile::base
}


# Cloudera Manager
node 'ambrosius.puppetlabs.vm' {
  include profile::base
  class { 'profile::cdh::manager':
    deployment => 'labyrinth',
  }
}

# Cloudera Hosts in a deployment named 'labyrinth' -- in general.
node 'cdh-host.labyrinth' {
  include profile::base
  class { 'profile::cdh::host':
    deployment => 'labyrinth',
  }
}

# Cloudera Hosts in a deployment named 'labyrinth' -- actual nodes.
node 'ip-10-0-20-233.us-west-2.compute.internal'   inherits 'cdh-host.labyrinth' { }
node 'toby.puppetlabs.vm'    inherits 'cdh-host.labyrinth' { }
node 'jareth.puppetlabs.vm'  inherits 'cdh-host.labyrinth' { }
node 'ludo.puppetlabs.vm'    inherits 'cdh-host.labyrinth' { }
node 'didymus.puppetlabs.vm' inherits 'cdh-host.labyrinth' { }
