#!/bin/bash

input_folder="files-to-add-into-iso"

xorrisofs -o zvC9-mkiso.iso "$input_folder" \
 -iso-level 3 \
 -U \
 -allow-lowercase \
 -l \
 -J \
 -joliet-long \
 -V zvC9-mkiso  \
 -d \
 -max-iso9660-filenames \
  -r

#-max-iso9660-filenames

exit 0

## tested:
#xorrisofs -o 1.iso ./1 \
#  -iso-level 3 \
#  -U \
#  -d \
#  -allow-lowercase \
#  -l \
#  -r \
#  -max-iso9660-filenames \
#  -J \
#  -joliet-long \
#  -r \
#  -V cd1

