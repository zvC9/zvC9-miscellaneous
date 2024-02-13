#!/bin/bash

echo "Danger! Опасность! Continue? Продолжить?"
echo -n \"y\" Enter или \(or\) \"n\" Enter:" "

read answer

if test ! "$answer" = "y" ; then
	echo Aborted
	exit 1
fi

find -iname "*-600dpi.ppm" -type f -exec bash -c "rm -fv \"\$(dirname \"{}\")/\$(basename  \"{}\" -600dpi.ppm)\"-300dpi.ppm; convert  \"{}\" -resize 50% -filter Cubic  \"\$(dirname \"{}\")/\$(basename  \"{}\" -600dpi.ppm)\"-300dpi.ppm ; sync ; echo DONE: \"{}\"" \;

