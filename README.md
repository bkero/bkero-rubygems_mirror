# rubygems_mirror

#### Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with rubygems_mirror](#setup)
    * [Setup requirements](#setup-requirements)
    * [Beginning with rubygems_mirror](#beginning-with-rubygems_mirror)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

This module will give a host the functionality of mirroring the rubygems set.
This can be useful if you want a local copy to speed up local gem fetches, for
example in continuous integration systems or local development.

This module will ensure ruby and rubygems is installed, then install the
rubygems-mirror gem to enable the 'gem mirror' command. Then it will enable
a cron job for the 'gem mirror' command using a basic form of mutual exclusion.

This module has been tested to work with CentOS 7 and Ubuntu Trusty using
Puppet version 3.x.

## Setup

### Setup Requirements **OPTIONAL**

The host should be running Ubuntu (trusty) or CentOS (7+), and have at least
the parent directory of the data directory given.

### Beginning with rubygems_mirror

Running rubygems_mirror requires no parameters, so one can simply:

    class { 'rubygems_mirror': }

to install it. This will set up a rubygems mirror in /data/mirror with no
logs.

## Usage

Below is an example of using the rubygems_mirror module and specifying all
options. For more details see `manifest/init.pp`.

    class { 'rubygems_mirror':
      mirror_home      => '/data/mirror',
      user             => 'root'
      gem_home         => '/root/.gem',
      parallelism      => 10,
      upstream_url     => 'http://rubygems.org',
      update_frequency => 'daily',
      delete           => true,
      log_file         => '/var/log/rubygems_mirror.log'
    }


## Reference

The module simply installs ruby and rubygems from your system package manager,
then installs rubygems-mirror from gem. Afterwards it ensures your specified
data directory and gem home exist. Then it creates the .mirrorrc file, which
contains configuration options for the mirror command.

After that it creates a cron entry to actually run the 'gem mirror' command.

## Limitations

The cron format is rudamentary. This can likely be improved by depending on a
better Puppet module to handle the cron entry. Look for the todo in
`manifest/init.pp`

Another limitation is the bug in Ruby 2.0 (and accompanying rubygems version)
that disables rubygems-mirror from working. This can be fixed by upgrading
rubygems, which is what this module does on EL7.

## Development

There is no formal development process yet. If you would like to contribute
please ping me (bkero on Freenode IRC). If you send me a Github pull request
I might take a look at it.

## Release Notes/Contributors/Etc. **Optional**

## Release 0.1.0: Initial release
