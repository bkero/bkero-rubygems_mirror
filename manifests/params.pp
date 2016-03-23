# == Class: rubygems_mirror::params
#
# These parameters need to be accessed from several locations and
# should be considered to be constant

class rubygems_mirror::params {
    case $::osfamily {
        'RedHat': { $ruby_package_name = 'ruby' }
        'Debian': { $ruby_package_name = 'ruby' }
        default:  { $ruby_package_name = 'ruby' }
    }
}
