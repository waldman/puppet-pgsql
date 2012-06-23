#!/bin/bash
###
# Copyright (c) 2009, Leon Waldman, le.waldman@gmail.com
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


###
# Backup Script -  PostGreSQL Server Side.
# ----------------------------------------
#
# This script make a dump of all PostgreSQL databases and the system
# Global Data to the /var/dbbackup/last_bkps folder, move the old files from the
# /var/dbbackup/last_bkps folder to the /var/dbbackup/week_archive folder and remove the
# backup files that are older then 7 days.
#
# This script was built and tested on Debian/Ubuntu Linux distributions.
###


# ========
# = Vars =
# ========
MAINDIR="/var/dbbackup"
LASTBKPDIR=${MAINDIR}"/last_bkps"
WEEKBKPDIR=${MAINDIR}"/week_archive"
TIMEWA=`date -d "7 days ago" +%y%m%d`
HOSTNAME=`hostname`
DUMPALL="/usr/bin/pg_dumpall -g"
DUMP_START="/usr/bin/pg_dump -Z 9 -b -Fc"
DUMP_END=" -f"
TIME=`date +%y%m%d`
COMPRESS="/bin/gzip"
DBS=`psql -l| awk '{ print $1}'| sed -n '/------------/,$p'|sed '/template/d'| sed -e :a -e '$d;N;2,2ba' -e 'P;D'| sed '/---------/d'`
DBNU=`echo $DBS|wc -w`
DBNUM=$(( $DBNU + 1 ))
WEEKBKPNUM=$(( $DBNUM * 7 ))
WEEKFILENU=`ls -l $WEEKBKPDIR | wc -l`
WEEKFILENUM=$(( $WEEKFILENU - 1 ))
FIND="/usr/bin/find"


# ==============
# = Action! :P =
# ==============
# Moving Lastbkp to weekbkp
mv ${LASTBKPDIR}/* ${WEEKBKPDIR}

# Globals Only Dump (Users, passwords and more, not-so-much more ;) )
${DUMPALL} | ${COMPRESS} > ${LASTBKPDIR}/pgbkp_${HOSTNAME}_globals_only_${TIME}.sql.gz

# DBs Dumps
for DB in ${DBS}; do
    ${DUMP_START} ${DB} ${DUMP_END} ${LASTBKPDIR}/pgbkp_${HOSTNAME}_${DB}_${TIME}.pgdump
done

# Check if it should clean the bkp from one week before or not
if [ $WEEKFILENUM -gt $WEEKBKPNUM ]; then
    # Cleaning one week old files
    $FIND $WEEKBKPDIR -type f -mtime +7 -print0 | xargs -0 rm
    exit 0
else
    exit 0
fi
