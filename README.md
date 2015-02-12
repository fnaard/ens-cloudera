# Overview

This pair of profiles is intended to simplify the creation of a new Cloudera 5 deployment.  By classifying nodes as either a manager or a host, with an optional name for the deployment, a Manager will be created and Hosts will automatically add themselves to its list of Hosts.

These profiles currently work in a deployment where parcels will be used to distribute binaries, and where the Manager will do all Management of clusters and such in its GUI.

# Building a Lab Environment

## Master

To begin, of course you will need a Puppet Master running somewhere.  These profiles are known to work on version 3.7 of Puppet.  They *should* work on anything in the 3 series.  They don't do anything fancy.

You will need a few puppet modules installed.

  puppet module install razorsedge-cloudera
  puppet module install puppetlabs-ntp

## Cloudera 5 Manager

Deploy a machine for this purpose.  The cloudera Manager likes to have all sorts of RAM.  An m3.large seems to work.  This module has been tested on a basic Debian 7.8 AMI.  (ami-17510927)

Then classify the new node.  In the example site.pp provided here, the Cloudera 5 Manager is called Ambrosius.  It is going to manage a deployment called 'labyrinth.'  The name of the deployment is not significant to Cloudera -- it is used by Puppet to tag exported resources is such a way that machines in the same deployment know about each other, but not any other deployment.

  class { 'profile::cdh::manager':
    deployment => 'labyrinth',
  }

