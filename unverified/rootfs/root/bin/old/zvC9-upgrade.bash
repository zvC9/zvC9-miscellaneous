#!/bin/bash

function user-zvC9-sync () {
 #echo skipping a sync
 # user-zvC9-sync
 sync
}

function user-zvC9-error { # error code msg, error msg, error
 echo -n "Error (aborting): "
 if [ $# -ge 2 ] ; then
  echo "$2"
  echo "Press Enter to exit (нажмите Enter, чтобы выйти)"
  read
  exit $1
 else
  if [ $# -ge 1 ] ; then
   echo "$1"
   echo "Press Enter to exit (нажмите Enter, чтобы выйти)"
   read
   exit 1
  else
   echo
   echo "Press Enter to exit (нажмите Enter, чтобы выйти)"
   read
   exit 1
  fi
 fi
}

function zvC9-user-confirms-continue-or-exit {
 echo Continue? \(Продолжить?\)
 echo -n \"y\" Enter or \"n\" Enter \("y" Enter или "n" Enter\): 
 read answer
 if test "x$answer" = "xy" ; then
  :
 else
  echo "Aborted by user (отменено пользователем)"
  exit 120
 fi
}

function user-zvC9-isMint () {
	if grep -q -i "Linux Mint" /etc/os-release ; then
		echo -e "\\n\\nDetected Linux Mint system\\n\\n"
		#sleep 3
		return 0
	else
		echo -e "\\n\\nDetected NOT Linux Mint system\\n\\n"
		#sleep 3
		return 1
	fi
}


apt update || user-zvC9-error 1 update
user-zvC9-sync

apt-get --download-only --yes dist-upgrade || user-zvC9-error 1 download upgrades
user-zvC9-sync

echo "Downloaded upgrades (скачаны обновления)"
zvC9-user-confirms-continue-or-exit


if user-zvC9-isMint ; then
	mintupdate-cli upgrade || user-zvC9-error 1 mintupdate-cli upgrade
	user-zvC9-sync
	
	apt update || user-zvC9-error 1 update
	apt-get --download-only --yes dist-upgrade || user-zvC9-error 1 download upgrades
	user-zvC9-sync
	
	echo "Downloaded upgrades (скачаны обновления)"
 zvC9-user-confirms-continue-or-exit
	
	mintupdate-cli upgrade || user-zvC9-error 1 mintupdate-cli upgrade
	user-zvC9-sync
	echo "successful upgrade (выполнено обновление)"
else
 apt-get --download-only --yes dist-upgrade || user-zvC9-error 1 download upgrades
 user-zvC9-sync
 echo "Downloaded upgrades (скачаны обновления)"
 zvC9-user-confirms-continue-or-exit
 
	apt dist-upgrade || user-zvC9-error 1 dist-upgrade
	user-zvC9-sync
	echo "successful upgrade (выполнено обновление)"
fi

echo "Press Enter to exit (нажмите Enter, чтобы выйти)"
read

exit 0


