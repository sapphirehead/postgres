#!/bin/sh
#-------------------------------------------------------------------------
#
# initarea.sh--
#     Create (initialize) a secondary Postgres database storage area.  
# 
#     A database storage area contains individual Postgres databases.
#
#     To create the database storage area, we create a root directory tree.
#
# Copyright (c) 1994, Regents of the University of California
#
#
# IDENTIFICATION
#    $Header: /cvsroot/pgsql/src/bin/initlocation/Attic/initlocation.sh,v 1.1 1997/11/07 06:21:39 thomas Exp $
#
#-------------------------------------------------------------------------

CMDNAME=`basename $0`

while [ "$#" -gt 0 ]
do
	case "$1" in
		--location=*) PGALTDATA="`echo $1 | sed 's/^--pgdata=//'`"; ;;
		--username=*) POSTGRES_SUPERUSERNAME="`echo $1 | sed 's/^--username=//'`" ;;

		--location) shift; PGALTDATA="$1"; ;;
		--username) shift; POSTGRES_SUPERUSERNAME="$1"; ;;

		-u) shift; POSTGRES_SUPERUSERNAME="$1"; ;;
		-D) shift; PGALTDATA="$1"; ;;
		-*) badparm=$1; usage=1; ;;
		*) PGALTDATA="$1"; ;;
	esac
	shift
done

if [ -n "$badparm" ]; then
	echo "$CMDNAME: Unrecognized parameter '$badparm'"
fi

if [ -n "$usage" ]; then
	echo "Usage: $CMDNAME [-u SUPERUSER] DATADIR"
	exit 1
fi

#-------------------------------------------------------------------------
# Make sure he told us where to build the database area
#-------------------------------------------------------------------------

if [ -z "$PGALTDATA" ]; then
	echo "$CMDNAME: You must identify the target area, where the new data"
	echo "for this database system can reside.  Do this with --location"
	exit 1
fi

#---------------------------------------------------------------------------
# Figure out who the Postgres superuser for the new database system will be.
#---------------------------------------------------------------------------

if [ 1 -eq 0 ]; then
if [ -z "$POSTGRES_SUPERUSERNAME" ]; then 
	$POSTGRES_SUPERUSERNAME=pg_id
fi

if [ -z "$POSTGRES_SUPERUSERNAME" ]; then 
	echo "Can't tell what username to use.  You don't have the USER"
	echo "environment variable set to your username and didn't specify the "
	echo "--username option"
	exit 1
fi

POSTGRES_SUPERUID=`pg_id $POSTGRES_SUPERUSERNAME`

if [ $POSTGRES_SUPERUID = NOUSER ]; then
	echo "Valid username not given.  You must specify the username for "
	echo "the Postgres superuser for the database system you are "
	echo "initializing, either with the --username option or by default "
	echo "to the USER environment variable."
	exit 1
fi

if [ $POSTGRES_SUPERUID -ne `pg_id` -a `pg_id` -ne 0 ]; then 
	echo "Only the unix superuser may initialize a database with a different"
	echo "Postgres superuser.  (You must be able to create files that belong"
	echo "to the specified unix user)."
	exit 1
fi

echo "We are initializing the database area with username" \
	"$POSTGRES_SUPERUSERNAME (uid=$POSTGRES_SUPERUID)."   
echo "This user will own all the files and must also own the server process."
echo
fi

# -----------------------------------------------------------------------
# Create the data directory if necessary
# -----------------------------------------------------------------------

# umask must disallow access to group, other for files and dirs
umask 077

if [ ! -d $PGALTDATA ]; then
	echo "Creating Postgres database system directory $PGALTDATA"
	echo
	mkdir $PGALTDATA
	if [ $? -ne 0 ]; then exit 1; fi
fi
if [ ! -d $PGALTDATA/base ]; then
	echo "Creating Postgres database system directory $PGALTDATA/base"
	echo
	mkdir $PGALTDATA/base
	if [ $? -ne 0 ]; then exit 1; fi
fi

exit
