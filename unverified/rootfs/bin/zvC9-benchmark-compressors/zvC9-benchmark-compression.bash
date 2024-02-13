#!/bin/bash


# this directory will be compressed
name="compress_me"
# "yes" or "no"
run_zstd=yes

# next lines you can skip

function user-zvC9-sync {
 sync
}

function zvC9-rm-if-not-devnull {
 if test "$1" != "/dev/null" ; then
  rm -fv "$1"
 fi
}

function user-zvC9-extract-times {
 cat "${result_times_file}" | \
  sed -E -e "/time:/d" | sed -E -e "s/.* ([0-9]+):([0-9.]+)elapsed.*/0 \\1 \\2/g" | \
  sed -E -e "s/.* ([0-9]+):([0-9]+):([0-9.]+)elapsed.*/\\1 \\2 \\3/g" | \
  sed -E -e "s/\\./,/g" | sed -E -e "/inputs/d" | sed -E -e "/^\\s*\$/d" > ${result_times_file_short}

}
function user-zvC9-extract-compressors-levels-and-sizes-for-libreoffice {
 cat "$results_file" | sed -E -e "s/^([^ ]+) -([^ ]+) byte_count: ([0-9]+)\$/\\1 =\"-\\2\" \\3/g" > $results_file_for_libreoffice_calc
}

export LC_ALL=C
export LANG=C

results_file="compressed-sizes.txt"
results_file_for_libreoffice_calc="compressed-sizes-for-libreOffice-calc.txt"
result_times_file="compression-times-full.txt"
result_times_file_short="compression-times-short.txt"

## not accurate
#result_dd_file="compression-speeds-dd.txt"
## can be file or /dev/null
result_dd_file="/dev/null" ## not accurate

zvC9-rm-if-not-devnull "$results_file"
zvC9-rm-if-not-devnull "$result_times_file"
zvC9-rm-if-not-devnull "$result_dd_file"
zvC9-rm-if-not-devnull "$result_times_file_short"
zvC9-rm-if-not-devnull "$results_file_for_libreoffice_calc"
user-zvC9-sync

echo -n "UNCOMPRESSED -NOLEVEL byte_count: " >> $results_file
echo "UNCOMPRESSED -NOLEVEL time: " >> $result_times_file
echo "UNCOMPRESSED -NOLEVEL dd_speed: " >> $result_dd_file

user-zvC9-sync

echo compressor: NONE
echo level: NONE
tar -c "$name" | dd bs=1M status=progress | /bin/time --append -o "$result_times_file" dd bs=1M 2>> $result_dd_file |  wc --bytes >> $results_file
user-zvC9-sync

for compressor in gzip  bzip2  xz  ; do
 if [ "x$compressor" = "xxz" ] ; then
  echo compressor: xz
  echo level: -0
  echo -n "xz -0 byte_count: " >> $results_file
  echo -e "\\nxz -0 time: " >> "$result_times_file"
  echo -e "\\nxz -0 dd_speed: " >> $result_dd_file
  user-zvC9-sync
  tar -c "$name" | dd bs=1M status=progress | dd bs=1M 2>> $result_dd_file | /bin/time --append -o "$result_times_file" $compressor -0 |  wc --bytes >> $results_file
  user-zvC9-sync
 fi
 for ((level=1;level<10;++level)) ; do
  echo compressor: $compressor
  echo level: $level
  echo -n "$compressor -$level byte_count: " >> $results_file
  echo -e "\\n$compressor -$level time: " >> "$result_times_file"
  echo -e "\\n$compressor -$level dd_speed: " >> $result_dd_file
  user-zvC9-sync
  tar -c "$name" | dd bs=1M status=progress | dd bs=1M  2>> $result_dd_file | /bin/time --append -o "$result_times_file" $compressor -$level |  wc --bytes >> $results_file
  user-zvC9-sync
 done
done

if test "$run_zstd" = yes ; then
 if which zstd ; then
  compressor=zstd
  for ((level=1;level<20;++level)) ; do
   echo compressor: $compressor
   echo level: $level
   echo -n "$compressor -$level byte_count: " >> $results_file
   echo -e "\\n$compressor -$level time: " >> "$result_times_file"
   echo -e "\\n$compressor -$level speed: " >> $result_dd_file
   user-zvC9-sync
   tar -c "$name" | dd bs=1M status=progress | dd bs=1M  2>> $result_dd_file | /bin/time --append -o "$result_times_file" $compressor -$level |  wc --bytes >> $results_file
   user-zvC9-sync
  done
 fi
fi

user-zvC9-extract-times
user-zvC9-sync

user-zvC9-extract-compressors-levels-and-sizes-for-libreoffice
user-zvC9-sync

