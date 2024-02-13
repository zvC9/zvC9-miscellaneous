#!/bin/bash

echo you must put download URLs into text file URLs_for_wget.txt \(1 line = 1 URL\).
echo You must edit domain list \(from where to download recursively\) in variable \$domains_csv_list
echo read, copy and edit this script before running it
exit 1

#rm log.txt -f

function zvC9-sync {
 #echo skipping sync...
 echo -n 2×sync...
 sync ; sync
 echo done
}

domains_csv_list="example.org,www.example.org"
# note: ftp.example.org, www.example.org, *.example.org are implied by example.org

# i = depth. i=0 means only the pages from URL list
for ((i=0;i<12;++i)) ; do
 str="depth-$i-$(date -u +%Y-%m-%d-%H-%M-%S)-UTC"
	mkdir -p "mirror/$str" || exit 1
	pushd "mirror/$str" || exit 2
	 echo "starting \"$str\"" >> ../../log.txt
	 zvC9-sync
	 wget_args="--span-hosts --retry-on-http-error=503,429 --retry-connrefused  --retry-on-host-error    --no-clobber --page-requisites --html-extension --connect-timeout=8   --timeout 8 --adjust-extension   --timestamping --no-remove-listing --convert-links  \
         --domains \
	 ${domains_csv_list} \
         --protocol-directories  \
         --tries 3 \
	 --input-file  ../../URLs_for_wget.txt"   # --span-hosts   --no-parent
	 if [ "$i" = "0" ] ; then
	  wget --user-agent="Mozilla/5.0 (X11; Linux x86_64; rv:100.0) Gecko/20100101 Firefox/100.0" \
	   $wget_args \
	      2> ../"${str}-stderr.txt"
	 else
	  wget --user-agent="Mozilla/5.0 (X11; Linux x86_64; rv:100.0) Gecko/20100101 Firefox/100.0" \
	   --recursive --level $i \
	   $wget_args \
	      2> ../"${str}-stderr.txt"
	 fi
	 zvC9-sync
	 echo -e "i=$i (finished \"$str\" and sync done)\\n" >> ../../log.txt
	 zvC9-sync
	popd || exit 3
done

zvC9-sync
echo sync FINISHED, all done

exit 0
## more potantial wget options (these fail):
#         --reject-regex https://ftp.example.org/.*\\.iso \
#         --reject-regex http://ftp.example.org/.*\\.iso \

