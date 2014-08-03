#!/bin/sh

local POSTGRESQL_HOME="/data/postgresql"
local POSTGRESQL_CONFIG="/etc/postgresql/postgresql.conf"

create_db() {
	local result=0

	if [[ ! -d $POSTGRESQL_HOME/base ]]; then
		local cmd="initdb --pgdata $POSTGRESQL_HOME --encoding 'UTF-8' --no-locale"

		echo "=> No PostgreSQL database found in $POSTGRESQL_HOME"
		echo "=> Creating initial data..."
		mkdir -p $POSTGRESQL_HOME
		chown -Rf postgres:postgres $POSTGRESQL_HOME

		# avoid 'root' access issue
		local dir=$(pwd)
		cd $POSTGRESQL_HOME
		su -c "$cmd" postgres > /dev/null 2>&1
		cd $dir

		if [ $? -eq 0 ]; then
			# remove generated configuration files
			rm $POSTGRESQL_HOME/*.conf
			echo "=> Done!"
			result=1
		fi
	fi

	return $result
}

set_admin_account() {
	# use provided password or generate a random one
	local PASS=${POSTGRESQL_PASS:-$(pwgen -s 16 1)}
	local _type=$( [ ${POSTGRESQL_PASS} ] && echo "defined" || echo "generated" )

	echo "=> Creating 'admin' user using a ${_type} password"

	# create user and grant privileges
	echo "CREATE USER admin WITH SUPERUSER;" | \
		su -c "postgres --single -c config_file=$POSTGRESQL_CONFIG" postgres > /dev/null
	echo "ALTER USER admin WITH PASSWORD '$PASS';" | \
		su -c "postgres --single -c config_file=$POSTGRESQL_CONFIG" postgres > /dev/null
	# create admin database to avoid connection issues
	echo "CREATE DATABASE admin OWNER admin TEMPLATE DEFAULT" | \
		su -c "postgres --single -c config_file=$POSTGRESQL_CONFIG" postgres > /dev/null

	echo "=> Done!"

	# TODO: show connection information
	echo "======================================================================"
	echo " Use the following information to connect to this PostgreSQL server:"
	echo ""
	echo "   psql -h <host> -p <port> -U admin -W $PASS <dbname>"
	echo ""

	if [ ${_type} == "generated" ]; then
		echo "  !!! IMPORTANT !!!"
		echo ""
		echo "  For security reasons, it is recommended you change the above"
		echo "  password as soon as possible!"
		echo ""
	fi

	echo "======================================================================"
}

shutdown() {
	echo "=> Shutdown requested, stopping PostgreSQL..."

	su -c "pg_ctl stop -D $POSTGRESQL_HOME" postgres

	exit $?
}

start() {
	create_db

	if [ $? -ne 0 ]; then
		set_admin_account
	fi

	# launch postgres as background process
	echo "=> Starting PostgreSQL server..."
	su -c "postgres -c config_file=$POSTGRESQL_CONFIG" postgres &

	# catch INT/TERM and use pg_ctl to control postgres process
	trap shutdown SIGINT SIGTERM

	wait
}

start
