#!/bin/bash

source "$(dirname "$0")/apt-lists.bashlib"

apt install --no-install-recommends --no-install-suggests --download-only \
 $apt_dl_install_pkgs_list $apt_dl_pkgs_list 

echo \$\?=$?

sync
sync

echo DONE


# skipped, omitted and missing: mtr-tiny

# conflicts: wxhexeditor mtr-tiny
