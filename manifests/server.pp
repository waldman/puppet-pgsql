###
# Copyright (c) 2010, Leon Waldman, le.waldman@gmail.com
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
###


class postgresql::server {
    case $lsbdistrelease {
        8.04: {
            $version = '8.3'
        }
        
        10.04: {
            $version = '8.4'            
        }
    }

    package { ['postgresql', 'postgresql-contrib']:
        ensure	=> installed
    }
    
	file { '/etc/init.d/postgres':
		ensure	=> symlink,
		target	=> "/etc/init.d/postgresql-${version}",
		require	=> Package['postgresql'],
	}

    file { '/etc/logrotate.d/postgresql-common':
        owner	=> 'root',
	    group	=> 'root',
	    mode	=> '644',
        source  => "puppet:///postgresql/logrotate.postgresql-common"
    }

    service { "postgresql-${version}":
        ensure    => running,
        enable    => true,
        hasstatus => true,
        require   => Package['postgresql'],
        subscribe => Package['postgresql'],
    }

    define pg_hba($networks){
        case $lsbdistrelease {
            8.04: {
                $version = '8.3'
            }

            10.04: {
                $version = '8.4'            
            }
        }

        file { "/etc/postgresql/${version}/main/pg_hba.conf":
            owner   => "postgres",
            group   => "postgres",
            mode    => "644",
            content => template("postgresql/${version}-pg_hba.conf.erb"),
            require => Package["postgresql"],
        }    
    }
    
    define pgconf($listening_ip = $ipaddress_eth0, $max_connections = '100', $shared_buffers = '256MB', $effective_cache_size = '128MB', $log_min_duration_statement = '-1', $work_mem = '1MB', $maintenance_work_mem = '16MB', $shmmax = "280000000"){
        case $lsbdistrelease {
            8.04: {
                $version = '8.3'
            }

            10.04: {
                $version = '8.4'            
            }
        }

        sysctl { "kernel.shmmax": 
            val => $shmmax,
        }

        file { "/etc/postgresql/${version}/main/postgresql.conf":
            owner   => "postgres",
            group   => "postgres",
            mode    => "644",
            content => template("postgresql/postgresql.conf.${version}.erb"),
            require => Package["postgresql"],
        }
    }

	define simple_backup($cron_hour = '7', $cron_minute = '00', $bkp_user= '', $bkp_user_key = ''){
		file {['/var/dbbackup', '/var/dbbackup/last_bkps', '/var/dbbackup/week_archive']:
			ensure  => directory,	
			owner   => 'postgres',
   			group   => 'postgres',
   			mode    => '750',			
		}
		
		file {'/var/dbbackup/dbbackup.sh':
			ensure  => present,
			owner   => 'postgres',
	   		group   => 'postgres',
	   		mode    => '700',
	   		source  => 'puppet:///postgresql/dbbackup.sh',
			require	=> File['/var/dbbackup'],
		}
		
		cron {'simple_backup':
			command => '/var/dbbackup/dbbackup.sh',
			user	=> postgres,
			hour	=> $cron_hour,
			minute	=> $cron_minute,
			require	=> File['/var/dbbackup/dbbackup.sh'],
		}
	
	    if $bkp_user != '' and $bkp_user_key != '' {
            user { $bkp_user: 
                ensure	=> 'present',
                uid	=> '2001',
                groups	=> ['ssh', 'users', 'postgres'],
                comment	=> 'PostGreSQL Backup User',
                home	=> "/home/${bkp_user}",
                shell	=> '/bin/bash',
            }
            
            file {["/home/${bkp_user}", "/home/${bkp_user}/.ssh"]:
                ensure  => directory,	
                owner   => $bkp_user,
                group   => $bkp_user,
                mode    => '750',	
                require	=> User[$bkp_user],
            }
            
            file { "/home/${bkp_user}/.ssh/authorized_keys":
                ensure  => present,
                content => $bkp_user_key,
                owner   => $bkp_user,
                group   => $bkp_user,
                mode    => '400',
                require => [ User["${bkp_user}"], File["/home/${bkp_user}/.ssh"] ],
            }
        }
    }
}
