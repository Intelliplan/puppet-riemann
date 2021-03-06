# Use for bootstrapping the dashboard configuration file,
# with useful parameters. Ensures there's a
# '/etc/riemann-dash.rb' file afterwards.
#
class riemann::dash::config {
  $config_file_source   = $riemann::dash::config_file_source
  $config_file_template = $riemann::dash::config_file_template
  $host                 = $riemann::dash::host
  $port                 = $riemann::dash::port
  $manage_firewall      = $riemann::dash::manage_firewall
  $ws_config            = "${riemann::dash::home}/config/config.json"

  $_source = $config_file_source ? {
    ''      => undef,
    undef   => undef,
    default => $config_file_source,
  }

  $_content = $config_file_source ? {
    ''      => template($config_file_template),
    undef   => template($config_file_template),
    default => undef,
  }

  file { "$riemann::dash::home/config":
    ensure => directory,
    owner  => $riemann::dash::user,
    group  => $riemann::dash::group,
  }

  file { '/etc/riemann/riemann-dash.rb':
    ensure  => present,
    source  => $_source,
    content => $_content,
  }

  if $manage_firewall {
    firewall { "201 allow riemann-dash:$port":
      proto  => 'tcp',
      state  => ['NEW'],
      dport  => $port,
      action => 'accept',
    }
  }
}