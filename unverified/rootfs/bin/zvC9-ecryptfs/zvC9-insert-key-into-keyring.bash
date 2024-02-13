#!/bin/bash -x

( stty -echo; printf "Passphrase: " 1>&2; read PASSWORD; stty echo; echo "$PASSWORD"; ) | ecryptfs-insert-wrapped-passphrase-into-keyring ~/.ecryptfs/wrapped-passphrase -
