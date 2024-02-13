#!/bin/bash

mkdir build
cd build
sync
meson setup --prefix=/opt/custom -Damber=true -Dgallium=true ..
sync
ninja
sync
sudo ninja install
echo \$\?=$?
sync

echo DONE

