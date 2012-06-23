# Based on the excellent pgsql puppet modules from Eivind Uggedal
# https://github.com/uggedal/puppet-module-postgresql

# Copyright (C) 2011 by Eivind Uggedal <eivind@uggedal.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.


class postgresql::database {
    define createdb($owner, $ensure = present, $pgpass = '', $usrprop = '') {
        include postgresql::user
        $dbexists = "/usr/bin/psql -ltA | grep '^$name|'"

        postgresql::user::pguser {"$name - $owner":
            pguser  => $owner,
            ensure  => $ensure,
            pgpass  => $pgpass,
            usrprop => $usrprop,
        }

        if $ensure == 'present' {
            exec { "createdb $name":
                command => "/usr/bin/createdb -O $owner $name",
                user    => "postgres",
                unless  => $dbexists,
                require => Postgresql::User::Pguser["$name - $owner"],
            }
        }
    }
}
