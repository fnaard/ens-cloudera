# This profile sets up a Cloudera Danger Hadoop manager.
#
# It accepts an optional parameter 'deployment' to explicitly mark its exported
# resources with a string, so that host machines can collect those tagged
# resources.  The effect is that Managers and Hosts with the same $deployment
# will associate with each other, without interacting with nodes that have a
# different $deployment.
#
# To test in a lab, for instance, apply this classification to a new machine.
#
#   node 'my-cdh-manager.localdomain' {
#     class { 'profile::cdh::manager':
#       deployment => 'lab',
#     }
#   }
#
# This class depends on the razorsedge-cloudera module to function.
# If manage_ntp is set to true, this module requires puppetlabs-ntp
# If manage_firewall is set to true, this module requires puppetlabs-firewall
# If manage_java is set to true, this module requires puppetlabs-java

class profile::cdh::manager (
  $deployment          = $::environment,
  $manage_ntp          = false,
  $manage_firewall     = false,
  $manage_nagios       = false,
  $manage_java         = true,
  $private_key_content = undef,    # likely stored in Hiera
  $public_key_content  = undef,    # likely stored in Hiera
) {

  # Set up the node as a Cloudera Manager node.
  # Provides a default GUI on port 7180 with admin:admin credentials.
  class { '::cloudera':
    cm_server_host   => $::fqdn,
    install_cmserver => true,
    install_java     => $manage_java,
  }

  # Export a host file entry for this machine so that other hosts
  # in the deployment can find it by the alias 'cm_server'.
  @@host { $::fqdn:
    ensure       => 'present',
    ip           => $::ipaddress,
    host_aliases => [ $::hostname, 'cm_server' ],
    comment      => "Cloudera 5 Manager (${deployment})",
    tag          => [ 'cloudera', $deployment ],
  }

  # Collect all host file entries for cloudera machines in this deployment.
  Host <<| tag == 'cloudera' and tag == $deployment |>>

  # Cloudera recommends that the deployment's manager run an NTP server.
  if ( $manage_ntp ) {
    include ntp
  }

  # The puppetlabs-firewall module can open the proper ports, if desired.
  # These example rules open a minimal subset of all the possible ports.
  # In a monolithic install, most additional ports are only used on loopback.
  if ( $manage_firewall ) {
    firewall { '030 Cloudera Manager Web UI HTTP':
      port   => '7180',
      proto  => 'tcp',
      action => 'accept',
    }
    firewall { '030 Cloudera Manager Web UI HTTPS':
      port   => '7183',
      proto  => 'tcp',
      action => 'accept',
    }
  }

  # Export resources for monitoring.  A nagios server could collect these.
  # These example rules provide only the most basic checks.
  # A 'check_cdh_manager' script would need to exist on the Nagios server.
  if ( $manage_nagios ) {
    @@nagios_host { "${::fqdn}":
      ensure  => present,
      alias   => "${::hostname}",
      address => "${::ipaddress}",
      tag     => ['cloudera', $deployment],
    }
    Nagios_service {    # Set defaults in this scope.
      use                 => 'generic-service',
      host_name           => "${::fqdn}",
      notification_period => '24x7',
      tag                 => [ 'cloudera', $deployment ],
    }
    @@nagios_service { "check_ping_${::hostname}":
      ensure              => present,
      check_command       => 'check_ping!100.0,20%!500.0,60%',
      service_description => "${hostname}_check_ping",
    }
    @@nagios_service { "check_cdh_manager_${::hostname}":
      ensure              => present,
      check_command       => 'check_cdh_manager!7180',
      service_description => "${hostname}_check_cdh_manager",
    }

  }

  # SSH Keys -- When configured with Puppet, the Cloudera 5 Manager and Hosts
  #             Do NOT need ssh keys distributed.  This option is provided
  #             as a convenience, for command-line ssh connections from the
  #             Manager to the Hosts in the deployment, as root.

  # If the parameter is provided, manage a private key in root's home directory.
  if ( $private_key_content ) {
    file { '/root/.ssh/cloudera-manager.id_rsa.pem':
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      content => "-----BEGIN RSA PRIVATE KEY-----\n${private_key_content}\n-----END RSA PRIVATE KEY-----\n",
      mode    => '0400',
    }
  }
  else {
    file { '/root/.ssh/cloudera-manager.id_rsa.pem':
      ensure => absent,
    }
  }

  # If the parameter is provided, export a public key that hosts can collect.
  if ( $public_key_content ) {
    @@ssh_authorized_key { 'cloudera-manager':
      ensure => present,
      key    => "${public_key_content}",
      user   => 'root',
      type   => 'ssh-rsa',
      tag    => [ 'cloudera', $deployment ],
    }
  }
  else {
    @@ssh_authorized_key { 'cloudera-manager':
      ensure => absent,
      user   => 'root',
      tag    => [ 'cloudera', $deployment ],
    }
  }

}
