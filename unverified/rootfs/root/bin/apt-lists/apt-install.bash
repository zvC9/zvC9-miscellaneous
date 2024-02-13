#!/bin/bash

source "$(dirname "$0")/apt-lists.bashlib"

apt install --no-install-recommends --no-install-suggests  \
 $apt_dl_install_pkgs_list   #  $apt_dl_pkgs_list 

echo \$\?=$?

sync
sync

echo DONE


# skipped, omitted and missing: isc-dhcp-server openssh-server openssh-sftp-server bind9 bind9-doc bind9-utils bind9utils vsftpd minidlna samba brave-browser vivaldi-stable x11vnc ssvnc tigervnc-viewer tigervnc-tools tigervnc-xorg-extension tigervnc-standalone-server tigervnc-scraping-server tightvncpasswd tightvncserver xtightvncviewer vinagre vino vncsnapshot vtgrab xrdp sshpass tinysshd network-manager-ssh minitube smtube ytfzf quvi


# conflicts: mtr-tiny wxhexeditor
