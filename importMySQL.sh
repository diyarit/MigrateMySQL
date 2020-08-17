#!/bin/bash

if ! command -v gunzip > /dev/null; then
	echo  " gzip not found, not compressed "
fi

if ! command -v mysqldump > /dev/null; then
    echo  " mysqldump not found, aborting "

	exit 1
fi

# IMPORT

echo -n "DB file: "
read ARCHIVO_DB

if [ ! -f "$ARCHIVO_DB" ]; then
	echo "Archive $ARCHIVO_DB not found, aborting. "
	exit 1
fi

echo -n "DB user: "
read USUARIO_DB

if [ "$USUARIO_DB" != "root" ]; then
	USUARIO_COMMAND="-u$USUARIO_DB -p"
else
	if [ -f /root/.my.cnf ]; then
		echo "Exporting using credentials of /root/.my.cnf"
	else
		USUARIO_COMMAND="-u$USUARIO_DB -p"
	fi
fi

echo -n "DB name: "
read NOMBRE_DB

echo -n "Host (default 127.0.0.1): "
read HOST
if [ ! -z $HOST ]; then
	HOST="-h $HOST"
fi

if [ "$USUARIO_DB" != "root" ]; then
	echo -n "MySQL " # FOR engages ORDER OF THE COMMAND PASSWORD Mysqldump
fi

if command -v gunzip > /dev/null && (echo "$ARCHIVO_DB" | grep ".gz$" > /dev/null); then
	gunzip < "$ARCHIVO_DB" | mysql $USUARIO_COMMAND $HOST $NOMBRE_DB && echo "Database $ARCHIVO_DB imported into $NOMBRE_DB"
else
	mysql $USUARIO_COMMAND $HOST $NOMBRE_DB < "$ARCHIVO_DB" && echo "Database $ARCHIVO_DB imported into $NOMBRE_DB"
fi

