puppet-pgsql
============

Puppet PostgreSQL Module.

This module is compatible and was tested with Ubuntu 08.04 LTS and 10.04 LTS.
Future LTS versions support planned. Contributions are welcome! :)


ToDo
----
* Add support for Ubuntu 12.04 LTS
* Add support for CentOS current stable release.
* Add support for Debian current stable release.


Module Installation
------------

Clone this repository inside your puppet modules folder renaming it to postgresql:

    git clone git://github.com/waldman/puppet-pgsql.git postgresql


Usage
-----

To install PostgreSQL include and import the module:

	include postgresql::server
    include postgresql::client
    include postgresql::user
    import 'postgresql'
	

To configure the server:

- The postgresql.conf file:

	postgresql::server::pgconf { 'My_Postgres_Server':
		max_connections				=> '100',
		shared_buffers				=> '256MB',
		shmmax						=> '280000000',
		effective_cache_size		=> '128MB',
		work_mem					=> '1MB',
		maintenance_work_mem		=> '16MB',
		log_min_duration_statement  => '-1',
	}

Suported parameters list with default values (when applicable):

    max_connections
    listening_ip = $ipaddress_eth0
    shared_buffers = '256MB'
    effective_cache_size = '128MB'
    log_min_duration_statement = '-1'
    work_mem = '1MB'
    maintenance_work_mem = '16MB'
    shmmax = "280000000"

- The pg\_hba.conf file:

    postgresql::server::pg_hba{'Postgres_Allow_Networks':
		networks	=> ['Network\Host_1_in_CIDR_Notation', 'Network\Host_2_in_CIDR_Notation', '...']
	}

- The backup script:

    postgresql::server::simple_backup {'Backup_Script':
        bkp_user     => 'username_of_the_user_that_fetchs_the_backuped_files',
        bkp_user_key => '<ssh-key from the user_that_fetchs_the_backuped_files>',
    }

Suported parameters list with default values (when applicable):

    cron_hour = '7'
    cron_minute = '00'
    bkp_user= ''
    bkp_user_key = ''

- A Database:

    postgresql::database::createdb {'Database_name':
        ensure  => present,
        owner   => 'user_that_owns_the_database, \# (will be created if it doesn't exists)
        pgpass  => 'md52257151269b83ef0e139c3eec8bbcbcb', \# (It suports the pgsql md5 hashed pass or plain text)
        usrprop => 'ALTER ROLE user_that_owns_the_database SET search_path=Schema_1, Schema_2;', \#(Small SQL snippet that will be executed after the user creation)
    }

- A Regular User:

    postgresql::user::pguser {'Regular_User':
        ensure  => present,
        pguser  => 'Regular_User',
        pgpass  => 'md52257151269b83ef0e139c3eec8bbcbcb', \# (It suports the pgsql md5 hashed pass or plain text)
        usrprop => 'ALTER ROLE user_that_owns_the_database SET search_path=Schema_1, Schema_2;', \#(Small SQL snippet that will be executed after the user creation)
    }

- A Super User:
 
    postgresql::user::superuser {'Super_User':
        ensure  => present,
        pguser  => 'Super_User',
        pgpass  => 'md52257151269b83ef0e139c3eec8bbcbcb', \# (It suports the pgsql md5 hashed pass or plain text)
    }

- A Role:
 
    postgresql::user::pgrole {'database_role':
        ensure  => present,
        pgrole  => 'database_role',
    }


Some Remarks
------------
- Backup Script:
The backup script will run daily and do a dump of all databases and global variables 
on the server and put this dumps on the folder /var/dbbackup/last\_bkps.

It will also keep seven days old dumps on the folder
/var/dbbackup/week\_archive.

The fetch operation (fetch backup files from this server) is not covered on this
script, but the folder and subsequent dump files will be owned by the bkp\_user
group and the postgres user. You need to set this user on another box and
prepare a script to do the fetching.


- DB Owner creation:
During Database creation if the database owner user doesn't exists it will be
created.


Thanks
------
Some parts of this module were inspired or based on the puppet modules from
Eivind Uggedal (https://github.com/uggedal/puppet-module-postgresql) and 
Luke Kanies (https://github.com/puppetlabs/puppetlabs-postgres).

I added remarks about this on the header of the pertinent files and the original copyright message were I
found to be needed.

I would like to thanks both of them for their work and for release it so I could
integrate and learn from it! :)
