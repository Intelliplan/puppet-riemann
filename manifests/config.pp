class riemann::config {
  $host            = $riemann::host
  $port            = $riemann::port
  $config_file     = $riemann::config_file
  $config_source   = $riemann::config_file_source ? {
    ''      => undef,
    default => $riemann::config_file_source,
  }
  $config_content  = $riemann::config_file_source ? {
    ''      => template($riemann::config_file_template),
    default => undef,
  }
  $user            = $riemann::user
  $group           = $riemann::group
  $log_dir         = $riemann::log_dir
  $manage_firewall = $riemann::manage_firewall

  file { '/etc/riemann':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  file { $config_file:
    ensure  => present,
    source  => $config_source,
    content => $config_content,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => File['/etc/riemann'],
  }
  
  file { $log_dir:
    ensure => directory,
    owner  => $user,
    group  => $group,
    mode   => '0755',
  }

  file { '/etc/puppet/riemann.yaml':
    ensure  => present,
    content => template('riemann/puppet/riemann.yaml.erb'),
  }

  if $manage_firewall {
    firewall { "100 allow riemann:$port":
      proto   => 'tcp',
      state   => ['NEW'],
      dport   => $port,
      action  => 'accept',
      source  => $riemann::firewall_subnet,
    }
    firewall { "101 allow riemann:$port":
      proto   => 'udp',
      state   => ['NEW'],
      dport   => $port,
      action  => 'accept',
      source  => $riemann::firewall_subnet,
    }
    firewall { "102 allow riemann-websockets:5556":
      proto   => 'tcp',
      state   => ['NEW'],
      dport   => 5556,
      action  => 'accept',
      source  => $riemann::firewall_subnet,
    }
  }
}