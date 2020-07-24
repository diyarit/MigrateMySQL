#!/bin/bash

if ! command -v gzip > /dev/null; then
	echo  " gzip not found, not compressed "
fi

if ! command -v mysqldump > /dev/null; then
	echo  " mysqldump not found, aborting "
	exit 1
fi

# EXPORT

echo -n "Usuario DB: "
read USUARIO_DB

if [ "$USUARIO_DB" != "root" ]; then
	USUARIO_COMMAND="-u$USUARIO_DB -p"
else
	if [ -f /root/.my.cnf ]; then
		echo "Exporting using /root/.my.cnf"
	else
		USUARIO_COMMAND="-u$USUARIO_DB -p"
	fi
fi

echo -n "DB Name: "
read NOMBRE_DB

if [ "$USUARIO_DB" != "root" ]; then
	echo -n "MySQL " # TO MATCH PASSWORD ORDER FROM MYSQLDUMP COMMAND
fi

echo -n "Host (default 127.0.0.1): "
read HOST
if [ ! -z $HOST ]; then
	HOST="-h $HOST"
fi

if command -v gzip > /dev/null; then
	MYSQLFILE="./$NOMBRE_DB.sql.gz"
	mysqldump $USUARIO_COMMAND $HOST --no-create-db --routines --skip-comments --add-drop-table $NOMBRE_DB | sed -E 's/DEFINER=`[^`]+`@`[^`]+`/DEFINER=CURRENT_USER/g' | gzip > $MYSQLFILE
else
	MYSQLFILE="./$NOMBRE_DB.sql"
	mysqldump $USUARIO_COMMAND $HOST --no-create-db --routines --skip-comments --add-drop-table $NOMBRE_DB | sed -E 's/DEFINER=`[^`]+`@`[^`]+`/DEFINER=CURRENT_USER/g' > $MYSQLFILE
fi

if [ ! -f $MYSQLFILE ] || [ ! -s $MYSQLFILE ]; then
	echo ""
	echo " The exported file does not seem valid, aborting. "
	exit 1
fi

echo "Database  $NOMBRE_DB exported in $MYSQLFILE."

# TRANSFERENCIA

echo -n " Do you want to transfer the export to a remote server? [s / n]: "
read TRANSFER

if [ "$TRANSFER" = "n" ] || [ -z $TRANSFER ]; then
	echo "No se tranfiere"
	exit 0
fi

if ! command -v rsync > /dev/null; then
	echo  " rsync not detected, does not transfer. "
	exit 0
fi

echo -n "Remote Host: "
read HOST_REMOTO

echo -n "Remote user: "
read USUARIO_REMOTO

echo -n "SSH Port (default 22): "
read PUERTO_SSH
if [ -z $PUERTO_SSH ]; then
	PUERTO_SSH=22
fi

echo -n "Remote Path (default ~): "
read PATH_REMOTO
if [ -z $PATH_REMOTO ]; then
	PATH_REMOTO="~"
fi

echo "Transferring file $MYSQLFILE a $HOST_REMOTO..."
rsync -avz -e "ssh -p $PUERTO_SSH" --progress $MYSQLFILE $USUARIO_REMOTO@$HOST_REMOTO:$PATH_REMOTO

