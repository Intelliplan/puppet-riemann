# Includes Package['riemann-dash'].
#
# Parameters:
#   config_file: the path to the configuration file
#     to use for parameters for the dashboard. It is a
#     Sinatra web configuration file. Defaults to a sane
#     default if left empty.
class riemann::dash(
  $config_file_source   = '',
  $config_file_template = 'riemann/riemann-dash.rb.erb',
  $host                 = $riemann::params::dash_host,
  $port                 = $riemann::params::dash_port,
  $log_dir              = $riemann::params::dash_log_dir,
  $ruby_version         = $riemann::params::ruby_version,
  $config_file          = $riemann::params::dash_config_file,
  $user                 = $riemann::params::dash_user,
  $home                 = $riemann::params::dash_home,
  $group                = $riemann::params::group,
  $manage_firewall      = false
) inherits riemann::params {
  include svcutils

  anchor { 'riemann::dash::start': }
  svcutils::svcuser { $user:
    group   => $group,
    home    => $home,
    shell   => '/bin/bash',
    require => [
      Anchor['riemann::dash::start'],
      Class['riemann::common']
    ],
    before  => Anchor['riemann::dash::end'],
  } ->

  class { 'riemann::dash::package':
    require => Anchor['riemann::dash::start'],
    before  => Anchor['riemann::dash::end'],
  } ->
  class { 'riemann::dash::config':
    require => Anchor['riemann::dash::start'],
    before  => Anchor['riemann::dash::end'],
  } ~>
  class { 'riemann::dash::service':
    require => Anchor['riemann::dash::start'],
    before  => Anchor['riemann::dash::end'],
  }

  anchor { 'riemann::dash::end': }
}