# This profile sets up a Cloudera Danger Hadoop manager.
#
# It accepts an optional parameter 'deployment' to explicitly mark its exported
# resources with a string, so that host machines can collect that explicit
# string.  However, the default of deployment name using the $::environment
# fact should be fine for getting started.
#
# This class depends on the razorsedge-cloudera module, to function.

class profile::cdh::manager (
  $deployment          = $::environment,
  $manage_ntp          = true,
  $manage_firewall     = false,
  $manage_nagios       = false,
  $manage_java         = true,
  $private_key_content = undef,    # likely stored in Hiera
  $public_key_content  = undef,    # likely stored in Hiera
) {

  # Export a host file entry for this machine so that other hosts
  # in the deployment can find it by the alias 'cm_server'.
  @@host { $::fqdn:
    ensure       => 'present',
    ip           => $::ipaddress,
    host_aliases => 'cm_server',
    comment      => "Cloudera 5 Manager (${deployment})",
    tag          => [ 'cloudera', $deployment ],
  }

  # Collect all host file entries for cloudera machines in this deployment.
  Host <<| tag == 'cloudera' and tag == $deployment |>>

  # Cloudera recommends that the deployment's manager run an NTP server.
  if ( $manage_ntp ) { include ntp }

  # This class declaration sets up the node as a Cloudera manager.
  # The initial install uses the default admin credentials and port 7180.
  class { '::cloudera':
    cm_server_host   => $::fqdn,
    install_cmserver => true,
    install_java     => $manage_java,
  }

  # The puppetlabs-firewall module can open the proper ports, if desired.
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

  # SSH Keys -- When configured with Puppet, the Cloudera 5 Manager and Hosts
  #             Do NOT need ssh keys distributed.  This option is provided
  #             as a convenience, for command-line ssh connections from the
  #             Manager to the Hosts in the deployment.

  # If the parameter is provided, manage a private key in root's home directory.
  if ( $private_key_content ) {
    file { '/root/.ssh/cloudera-manager.id_rsa.pem':
      ensure => file,
      owner  => 'root',
      group  => 'root',
      content => "-----BEGIN RSA PRIVATE KEY-----\n${private_key_content}\n-----END RSA PRIVATE KEY-----\n",
      mode => '0400',
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
    ssh_authorized_key { 'cloudera-manager':
      ensure => absent,
      user   => 'root',
    }
  }

}
