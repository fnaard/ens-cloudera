# Overview

This pair of profiles is intended to simplify the creation of a new Cloudera 5 deployment.  By classifying nodes as either a manager or a host, with an optional name for the deployment, a Manager will be created and Hosts will automatically add themselves to its list of Hosts.

These profiles currently work in a deployment where parcels will be used to distribute binaries, and where the Manager will do all Management of clusters and such in its GUI.

# Building a Lab Environment

## Security Groups

  * You will need port 7180 open to the Manager from wherever your web browser is.

## Master

To begin, of course you will need a Puppet Master running somewhere.  These profiles are known to work on version 3.7 of Puppet.  They *should* work on anything in the 3 series.  They don't do anything fancy.

You will need a few puppet modules installed.

  puppet module install razorsedge-cloudera
  puppet module install puppetlabs-ntp

## Cloudera 5 Manager

Deploy a machine for this purpose and connect them to your Puppet Master.  The Cloudera Manager likes to have all sorts of RAM.  An m3.large seems to work.  This module has been tested on a basic Debian 7.8 AMI.  (ami-17510927)

Then classify the new node.  In the example site.pp provided here, the Cloudera 5 Manager is called Ambrosius.  It is going to manage a deployment called 'labyrinth.'  The name of the deployment is not significant to Cloudera -- it is used by Puppet to tag exported resources is such a way that machines in the same deployment know about each other, and aim at the right Manager for their deployment.

  class { 'profile::cdh::manager':
    deployment => 'labyrinth',
  }

The next `puppet agent --test` on the Manager node will take a longer-than-usual time to run, as it will be installing some large packages, including Oracle Java and Cloudera's CDH packages.

After the run is complete, the Manager software will begin to come online.  This may take a few minutes while Java gets going.  The Manager GUI at this point has the default configuration.

  port: 7180
  username: admin
  password: admin

Out of the box, the various Management roles are not assigned to any machine, including this new Manager.  You will need to enable and assign them in the GUI.

  * Log in to the GUI on port 7180 with a web browser.
  * On the first login you will need to, choose your license type.
  * Click the 'admin' menu in the upper right and choose 'Change Password.'
  * Update your password.
  * Click the 'cloudera manager' logo in the upper-left to go to the main page.
  * Click the 'Add Cloudera Management Service' button in the upper-right.
  * For a lab, you can leave all host names set to this new Manager machine.
  * Click 'Continue'
  * Supply mail server information and file storage options.
  * Click 'Continue'
  * The Add Service Wizard will kick off a First Run of the services.
  * When done, click 'Continue'
  * Finally, click Finish on the last page of the wizard.

Your new Manager instance will begin to collect data for its services.  You may see quite a few warnings at first, as things come online and delta metrics get enough measurements to actually calculate a delta.

## Cloudera 5 Hosts

Deploy some machines for this purpose and connect them to your Puppet Master.  In a lab, they don't need much RAM.  An m3.small seems to work.  This module has been tested on a basic Debian 7.8 AMI.  (ami-17510927)

Classify the new nodes as Cloudera 5 Hosts.  For this example, they will be in a deployment called 'labyrinth.'

  class { 'profile::cdh::host':
    deployment => 'labyrinth',
  }

The next `puppet agent --test` on the Manager node will take a longer-than-usual time to run, as it will be installing some large packages, including Oracle Java and Cloudera's CDH packages.

Once the run is complete, the new Host's Agent will have checked-in with the deployment's Manager.  It should now be available in the Manager GUI.

