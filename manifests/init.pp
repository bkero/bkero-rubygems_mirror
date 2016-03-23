# Class: rubygems_mirror
# ===========================
#
# This class creates a rubygems mirror fit for production use.
#
# Parameters
# ----------
#
# Document parameters here.
#
# [*mirror_home*]
#   (optional) The path that will be mirrored to
#   Defaults to '/data/mirror'
#
# [*user*]
#   (optional) The user that will execute the clone and cronjob
#   Defaults to 'root'
#
# [*gem_home*]
#   (optional) The GEM_HOME of the user
#   Defaults to '/root/.gem' or '/home/$user/.gem' depending on user
#
# [*parallelism*]
#   (optional) The number of parallel fetches to mirror with
#   Defaults to 10
#
# [*upstream_url*]
#   (optional) The URL of the upstream repository to mirror from
#   Defaults to 'http://rubygems.org'
#
# [*update_frequency*]
#   (optional) The frequency that the mirror will be updated
#   Defaults to 'daily'
#
# [*delete*]
#   (optional) Whether to delete files that have been deleted upstream
#   Defaults to true
#
# [*log_file*]
#   (optional) The file to log the status of the sync execution
#   Defaults to undef (disabled)
#
# Examples
# --------
#
# @example
#    class { 'rubygems_mirror':
#      mirror_home      => '/data/mirror',
#      user             => 'root'
#      gem_home         => '/root/.gem',
#      parallelism      => 10,
#      upstream_url     => 'http://rubygems.org',
#      update_frequency => 'daily',
#      delete           => true,
#      log_file         => '/var/log/rubygems_mirror.log'
#    }
#
# Authors
# -------
#
# Ben Kero <bkero@redhat.com>
#
# Copyright
# ---------
#
# Copyright 2016 Red Hat, Inc.
#
class rubygems_mirror($mirror_home='/data/mirror',
                      $user='root',
                      $parallelism=10,
                      $upstream_url='http://rubygems.org',
                      $update_frequency='*/10 * * * *',
                      $delete=true,
                      $gem_home = undef,
                      $log_file=undef) inherits rubygems_mirror::params {

    if !$gem_home {
        if $user == 'root' { $gem_home_real = '/root/.gem' }
        else               { $gem_home_real = "/home/${user}/.gem" }
    }

    package { [$ruby_package_name]:
        ensure => installed;
    }

    package { 'rubygems-mirror':
        ensure   => installed,
        provider => 'gem'
    }

    file {
        [ $mirror_home,
          $gem_home_real ]:
            ensure => directory,
            owner  => $user;

        "${gem_home_real}/.mirrorrc":
            ensure => present,
            owner   => $user,
            content => template('rubygems_mirror/mirrorrc.erb');
    }

    if $log_file {
        file { $log_file:
            ensure => present,
            owner  => $user
        }
        $redir = ">> ${log_file}"
    }

    # CentOS 7 and friends exhibit this bug, so rubygems must be updated
    # https://github.com/rubygems/rubygems-mirror/issues/20
    if $::operatingsystem == 'CentOS' or $::operatingsystem == 'RedHat' {
        exec { 'gem-update':
            command     => 'gem update --system',
            user        => $user,
            path        => '/usr/sbin:/usr/bin:/sbin:/bin',
            environment => "GEM_HOME=${gem_home_real}",
                # TODO: Find a better method for updating rubygems
            creates     => "${gem_home_real}/gems/rubygems-update-2.6.2";
        }
        package { 'rubygem-json_pure':
            ensure => present,
        }
    }

    cron { 'mirror-sync':
        command     => "pgrep -f 'gem mirror' || gem mirror ${redir}",
        user        => $user,
        minute      => '*/10',
        environment => "GEM_HOME=${gem_home_real} PATH=/usr/sbin:/usr/bin:/sbin:/bin";
    }

    Package[$ruby_package_name] ->
    Package['rubygems-mirror'] ->
    File[$mirror_home] ->
    File[$gem_home_real] ->
    File["${gem_home_real}/.mirrorrc"] ->
    Cron['mirror-sync']
}
