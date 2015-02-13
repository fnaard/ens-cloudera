# Example site.pp
#

# Avoid deprecation warnings when Puppet installs packages.
# This has nothing to do with Cloudera.
Package { allow_virtual => true, }

# Don't do anything if a node is not found.  Report it.
node default {
  notify { "No node definition for ${::clientcert}.": }
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

# Cloudera Hosts in a deployment named 'labyrinth' -- to be inherited.
node 'cdh-host.labyrinth' {
  include profile::base
  class { 'profile::cdh::host':
    deployment => 'labyrinth',
  }
}

# Cloudera Hosts in a deployment named 'labyrinth' -- actual nodes.
node 'ip-10-0-20-26.us-west-2.compute.internal' inherits 'cdh-host.labyrinth' { }
node 'ip-10-0-20-27.us-west-2.compute.internal' inherits 'cdh-host.labyrinth' { }
node 'ip-10-0-20-28.us-west-2.compute.internal' inherits 'cdh-host.labyrinth' { }
node 'ip-10-0-20-30.us-west-2.compute.internal' inherits 'cdh-host.labyrinth' { }
node 'ip-10-0-20-31.us-west-2.compute.internal' inherits 'cdh-host.labyrinth' { }
node 'ip-10-0-20-35.us-west-2.compute.internal' inherits 'cdh-host.labyrinth' { }
