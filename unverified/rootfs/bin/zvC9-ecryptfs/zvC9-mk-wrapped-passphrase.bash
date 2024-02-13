#!/bin/bash -x

umask 7077

echo -n "DANGER!. Continue? (y/n): "
read ans
if [ "x$ans" = "xy" ] ; then
	mkdir ~/.ecryptfs
	( stty -echo; printf "Passphrase: " 1>&2; read PASSWORD; stty echo; echo 1>&2; head -c 48 /dev/random | base64; echo "$PASSWORD"; ) \
  	| ecryptfs-wrap-passphrase ~/.ecryptfs/wrapped-passphrase >/dev/null
else
	echo aborting
fi

