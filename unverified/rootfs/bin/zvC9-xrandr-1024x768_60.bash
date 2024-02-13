#!/bin/bash

output="VGA-1"

echo "outputs (set one in variable \"output\" in this script):"
xrandr -q | grep connected | cut -d " " -f 1

echo -e \\n\\n\\n

# use gtf to get modeline:
gtf 1024 768 60
cvt 1024 768
cvt 1024 768 60

xrandr --delmode "$output"        "320x240_60.00"
xrandr --rmmode                   "320x240_60.00"
# get this mode with gtf
xrandr --newmode                  "320x240_60.00"  5.26  320 304 336 352  240 241 244 249  -HSync +Vsync
xrandr --addmode "$output"        "320x240_60.00"
xrandr --output  "$output" --mode "320x240_60.00"

xrandr --delmode "$output"        "1024x768_60.00"
xrandr --rmmode                   "1024x768_60.00"
# get this mode with gtf
xrandr --newmode                  "1024x768_60.00"  64.11  1024 1080 1184 1344  768 769 772 795  -HSync +Vsync
xrandr --addmode "$output"        "1024x768_60.00"
xrandr --output  "$output" --mode "1024x768_60.00"


