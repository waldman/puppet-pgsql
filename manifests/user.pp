###
# Copyright (c) 2011, Leon Waldman, le.waldman@gmail.com
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

# Inspired by the excellent pgsql puppet modules from Eivind Uggedal
# (puppet-module-postgresql) and Luke Kanies (puppetlabs-postgres)
# 
# https://github.com/uggedal/puppet-module-postgresql
# https://github.com/puppetlabs/puppetlabs-postgres/

class postgresql::user{
    define superuser($pguser, $ensure = present, $pgpass) {
        # Variables
        $userexists = "/usr/bin/psql --tuples-only -c 'SELECT rolname FROM pg_catalog.pg_roles;' | grep '^ ${pguser}$'"
        $user_owns_zero_databases = "/usr/bin/psql --tuples-only --no-align -c \"SELECT COUNT(*) FROM pg_catalog.pg_database JOIN pg_authid ON pg_catalog.pg_database.datdba = pg_authid.oid WHERE rolname = '${pguser}';\" | grep -e '^0$'"

        if $ensure == 'present' {
            if $pgpass =~ /^md5.*/ {
                exec { "Create $name PostGreSQL Superuser":
                    command => "/usr/bin/psql -c \"CREATE ROLE \\\"$pguser\\\" LOGIN ENCRYPTED PASSWORD '${pgpass}' SUPERUSER INHERIT CREATEDB CREATEROLE;\"",
                    user    => "postgres",
                    unless  => $userexists,
                    require => Class["postgresql::server"],
                }
            } else {
                exec { "Create $name PostGreSQL Superuser":
                    command => "/usr/bin/psql -c \"CREATE ROLE \\\"$pguser\\\" LOGIN PASSWORD '${pgpass}' SUPERUSER INHERIT CREATEDB CREATEROLE;\"",
                    user    => "postgres",
                    unless  => $userexists,
                    require => Class["postgresql::server"],
                }
            }
        } else {
            exec { "dropuser $name":
                command => "/usr/bin/psql -c \"DROP USER ${pguser};\"",
                user => "postgres",
                onlyif => "$userexists && $user_owns_zero_databases",
            }
        }
    }

    define pguser($pguser, $ensure = present, $pgpass, usrprop = '') {
        # Variables
        $userexists = "/usr/bin/psql --tuples-only -c 'SELECT rolname FROM pg_catalog.pg_roles;' | grep '^ ${pguser}$'"
        $user_owns_zero_databases = "/usr/bin/psql --tuples-only --no-align -c \"SELECT COUNT(*) FROM pg_catalog.pg_database JOIN pg_authid ON pg_catalog.pg_database.datdba = pg_authid.oid WHERE rolname = '${pguser}';\" | grep -e '^0$'"

        if $ensure == 'present' {
            if $pgpass =~ /^md5.*/ {
                exec { "Create $name PostGreSQL Regular User":
                    command => "/usr/bin/psql -c \"CREATE ROLE \\\"$pguser\\\" LOGIN ENCRYPTED PASSWORD '${pgpass}' NOSUPERUSER NOINHERIT CREATEDB NOCREATEROLE; ${usrprop}\"",
                    user    => "postgres",
                    unless  => $userexists,
                    require => Class["postgresql::server"],
                }
            } else {
                exec { "Create $name PostGreSQL Regular User":
                    command => "/usr/bin/psql -c \"CREATE ROLE \\\"$pguser\\\" LOGIN PASSWORD '${pgpass}' NOSUPERUSER NOINHERIT CREATEDB NOCREATEROLE; ${usrprop}\"",
                    user    => "postgres",
                    unless  => $userexists,
                    require => Class["postgresql::server"],
                }
            }
        } else {
            exec { "dropuser $name":
                command => "/usr/bin/psql -c \"DROP USER ${pguser};\"",
                user => "postgres",
                onlyif => "$userexists && $user_owns_zero_databases",
            }
        }
    }

    define pgrole($pgrole, $ensure = present, usrprop = '') {
        # Variables
        $userexists = "/usr/bin/psql --tuples-only -c 'SELECT rolname FROM pg_catalog.pg_roles;' | grep '^ ${pgrole}$'"
        $user_owns_zero_databases = "/usr/bin/psql --tuples-only --no-align -c \"SELECT COUNT(*) FROM pg_catalog.pg_database JOIN pg_authid ON pg_catalog.pg_database.datdba = pg_authid.oid WHERE rolname = '${pgrole}';\" | grep -e '^0$'"

        if $ensure == 'present' {
            exec { "Create $name PostGreSQL Regular Role":
                command => "/usr/bin/psql -c \"CREATE ROLE \\\"$pgrole\\\" NOSUPERUSER NOINHERIT CREATEDB NOCREATEROLE; ${usrprop}\"",
                user    => "postgres",
                unless  => $userexists,
                require => Class["postgresql::server"],
            }
            
        } else {
            exec { "dropuser $name":
                command => "/usr/bin/psql -c \"DROP USER ${pgrole};\"",
                user => "postgres",
                onlyif => "$userexists && $user_owns_zero_databases",
            }
        }
    }
}
