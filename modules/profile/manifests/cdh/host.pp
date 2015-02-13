# This class sets up a machine as a Cloudera agent host and aims it at its
# deployment's manager.  The address of the local manager server is determined
# by collecting a tagged host record that the manager has exported.
#
# The optional $deployment parameter should be set to the same string that
# this host's Manager is using.  The deployment's Manager exports resources
# that configure Hosts to aim the cdh Agent at it.
#
# To test in a lab, for instance, apply this classification to a new machine.
#
#   node 'my-cdh-host.localdomain' {
#     class { 'profile::cdh::host':
#       deployment => 'lab',
#     }
#   }

# This class depends on the razorsedge-cloudera module to function.
# If manage_ntp is set to true, this module requires puppetlabs-ntp
# If manage_firewall is set to true, this module requires puppetlabs-firewall
# If manage_java is set to true, this module requires puppetlabs-java


class profile::cdh::host (
  $deployment = $::environment,
  $manage_ntp          = false,
  $manage_firewall     = false,
  $manage_nagios       = false,
  $manage_java         = true,
) {

  # Set up a basic Cloudera agent on this node, and have it connect to the
  # Manager in this particular deployment, based on a collected host entry.
  class { '::cloudera':
    cm_server_host   => 'cm_server',
    install_java     => $manage_java,
  }

  # Export a host file entry for this machine so that other hosts
  # in the deployment do not need to use DNS to find each other.
  @@host { $::fqdn:
    ensure  => 'present',
    ip      => $::ipaddress,
    comment => "Cloudera 5 Host (${deployment})",
    host_aliases => $::hostname,
    tag     => ['cloudera',$deployment],
  }

  # Collect all host file entries for cloudera machines in this deployment.
  # This includes a record for the Manager server in this particular deployment.
  Host <<| tag == 'cloudera' and tag == $deployment |>> {
    before => Class['cloudera'],
  }

  # Cloudera recommends that all hosts synchronize time with the Manager.
  if ( $manage_ntp ) { class { 'ntp': servers => ['cm_server'], } }

  # The puppetlabs-firewall module can open the proper ports, if desired.
  if ( $manage_firewall ) {
    firewall { '030 Cloudera Manager Agent Debug Port':
      port   => '9000',
      proto  => 'tcp',
      action => 'accept',
    }
  }

  # Export resources for monitoring.  A nagios server could collect these.
  if ( $manage_nagios ) {
    @@nagios_host { "${::fqdn}":
      ensure  => present,
      alias   => "${::hostname}",
      address => "${::ipaddress}",
      tag     => ['cloudera', $deployment],
    }
    @@nagios_service { "check_ping_${::hostname}":
      check_command       => 'check_ping!100.0,20%!500.0,60%',
      use                 => 'generic-service',
      host_name           => "${::fqdn}",
      notification_period => '24x7',
      service_description => "${hostname}_check_ping",
      tag                 => [ 'cloudera', $deployment ],
    }
  }

  # Collect any public keys that the Manager may have exported.
  Ssh_authorized_key <<| tag == 'cloudera' and tag == $deployment |>>

}
