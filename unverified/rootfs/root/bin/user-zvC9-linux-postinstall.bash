#!/bin/bash

umask 7022

function user-zvC9-sync () {
 #return
 #echo skipping a sync
 # user-zvC9-sync
 echo -n 2×sync…
 sync
 echo -n 1 done…
 sync
 echo 2 done
}

function zvC9-apt-postinstall-and-postupgrade () {
 # acct
 for i in ssh postfix osspd ofono machines isc-dhcp-server  isc-dhcp-server6 aptly-api apt-cacher-ng  xrdp xrdp-sesman ukui-media-control-mute-led ; do
  systemctl stop "$i"
  systemctl disable "$i"
 done
 
 systemctl  disable NetworkManager-wait-online.service
 systemctl  disable network-online.target
 
 systemctl stop smbd
 systemctl stop nmbd
 systemctl disable smbd
 systemctl disable nmbd
}

function zvC9-add_info_about_CtrlAltF7_to_etc_issue () {
 local msg="Ctrl+Alt+F7 = k rabochemu stoly (Ctrl+Alt+F7 = to desktop) (Ctrl+Alt+F7 = K PA6O4EMy CTO/\\\\Y)"
 if grep -q -F "$msg" /etc/issue ; then
  echo "/etc/issue already contains needed message, skipping"
  #sleep 3
 else
  echo "$msg" >> /etc/issue
  user-zvC9-sync
  echo added "$msg" to /etc/issue
  #sleep 3
 fi
}

function user-zvC9-error { # error code msg, error msg, error
 echo -n "Error (aborting): "
 if [ $# -ge 2 ] ; then
  echo "$2"
  exit $1
 else
  if [ $# -ge 1 ] ; then
   echo "$1"
   exit 1
  else
   echo
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

function user-zvC9-isSparkyLinux () {
	if grep -q -i "SparkyLinux" /etc/os-release ; then
		echo -e "\\n\\nDetected Sparky Linux system\\n\\n"
		#sleep 3
		return 0
	else
		echo -e "\\n\\nDetected NOT Sparky Linux system\\n\\n"
		#sleep 3
		return 1
	fi
}

function zvC9-isMint-21 () {
	if user-zvC9-isMint ; then
		if grep -q -i "VERSION=\"21 (Vanessa)\"" /etc/os-release ; then
			echo -e "\\n\\nDetected Linux Mint 21 system\\n\\n"
			#sleep 3
			return 0
		fi
	fi
	echo -e "\\n\\nDetected NOT Linux Mint 21 system\\n\\n"
	#sleep 3
	return 1
}

function user-zvC9-isLMDE () {
	if grep -q "LMDE" /etc/os-release ; then
		echo -e "\\n\\nDetected LMDE system\\n\\n"
		#sleep 3
		return 0
	else
		echo -e "\\n\\nDetected NOT LMDE system\\n\\n"
		#sleep 3
		return 1
	fi
}


function zvC9-adjust-etc-default-grub {
 if test -e /etc/default/grub.zvC9.bak ; then
  echo skipping /etc/default/grub adjusting \(/etc/default/grub.zvC9.bak exists\)
 else
  if cp /etc/default/grub /etc/default/grub.zvC9.bak ; then
   cat /etc/default/grub.zvC9.bak | sed -E -e "s/^(GRUB_TIMEOUT_STYLE=.*)\$/#\\1\\nGRUB_TIMEOUT_STYLE=menu/g" \
    | sed -E -e "s/^(GRUB_CMDLINE_LINUX_DEFAULT=\"([^\"]*)\")\$/#\\1\\nGRUB_CMDLINE_LINUX_DEFAULT=\"\\2 consoleblank=30\"/g" \
      > /etc/default/grub
  else
   echo error copying /etc/default/grub to /etc/default/grub.zvC9.bak
   echo Aborting /etc/default/grub adjustment
   return 1
  fi
 fi
}
function zvC9-adjust-etc-apt-sources.list.d {
 if test -e /etc/apt/sources.list.d.zvC9.bak ; then
  echo skipping /etc/apt/sources.list.d adjusting \(/etc/apt/sources.list.d.zvC9.bak exists\)
 else
  if mkdir /etc/apt/sources.list.d.zvC9.bak ; then
   chmod -c 0755 /etc/apt/sources.list.d.zvC9.bak || return 2
   cp /etc/apt/sources.list.d/official-package-repositories.list /etc/apt/sources.list.d.zvC9.bak/ || return 3
   cp /etc/apt/sources.list.d/official-source-repositories.list /etc/apt/sources.list.d.zvC9.bak/ || return 4
   user-zvC9-sync
   cat /etc/apt/sources.list.d.zvC9.bak/official-package-repositories.list | \
    sed -E -e "s/http:\\/\\/mirror\\.yandex\\.ru\\//https:\\/\\/mirror\\.yandex\\.ru\\//g" \
    > /etc/apt/sources.list.d/official-package-repositories.list
   cat /etc/apt/sources.list.d.zvC9.bak/official-source-repositories.list | \
    sed -E -e "s/http:\\/\\/mirror\\.yandex\\.ru\\//https:\\/\\/mirror\\.yandex\\.ru\\//g" \
    > /etc/apt/sources.list.d/official-source-repositories.list
   user-zvC9-sync
   nano /etc/apt/sources.list.d/official-package-repositories.list
   nano /etc/apt/sources.list.d/official-source-repositories.list
  else
   echo "couldn't create /etc/apt/sources.list.d.zvC9.bak, aborting"
   return 1
  fi
 fi
}


function zvC9-download-HTML-page-with-requisites () { # call: zvC9-download-HTML-page-with-requisites URL dirname
 if test "$#" != "2" ; then
  user-zvC9-error  14 "wrong call of function zvC9-download-HTML-page-with-requisites (\$# = $#, must be 2)"
 fi
 
 
 rmdir  "$2"
 if test -e "$2" ; then
  chmod -c 0755 "$2"
  : # true, NOP
 else
  #wget -O "$2"  "$1"
  mkdir --parents --mode 0755 "$2"
  chmod -c 0755 "$2"
  if pushd "$2" ; then
   #wget --user-agent="Mozilla/5.0 (X11; Linux x86_64; rv:100.0) Gecko/20100101 Firefox/100.0" \
   #wget \
   #  --retry-on-http-error=503,429 --retry-connrefused  --retry-on-host-error    --no-clobber \
   #  --page-requisites --html-extension --connect-timeout=8   --timeout 8 --adjust-extension  \
   #  --timestamping --no-remove-listing --convert-links --protocol-directories \
   #  "$1"
    wget \
     --retry-on-http-error=503,429 --retry-connrefused  --retry-on-host-error    --no-clobber \
     --page-requisites --html-extension --connect-timeout=8   --timeout 8 --adjust-extension  \
     --convert-links --protocol-directories \
     --tries 3 \
     "$1"
   user-zvC9-sync
   popd
  fi
 fi
}

function zvC9-download-file () { # call: zvC9-download-file URL filename [sha256sum]
 if test "$#" -lt "2" ; then
  user-zvC9-error  14 "wrong call of function zvC9-download-file (\$# = $#, must be 2 or more)"
 fi
 
 
 if test -e "$2" ; then
  : # true, NOP
 else
  wget -O "$2"  "$1"
  user-zvC9-sync
 fi
 if test "$#" -ge "3" ; then # sha256sum is specified as argument $3
  if test ! -e "${2}.sha256sum" ; then
	  echo "$3 *$2" > ${2}.sha256sum
	  user-zvC9-sync
  fi
 else
  rm -fv "${2}.sha256sum"
 fi
}

# zvC9-unpack-memtest86plus-6.00
function zvC9-unpack-memtest86plus-6.00 () {
 if test ! -e memtest86+_6.00_64.bin || test ! -e memtest86+_6.00_64.grub.cfg ; then
  if sha256sum -c "memtest86+_6.00_64.grub.iso.zip.sha256sum" ; then
   rm -rfv           memtest86+_6.00_64.grub.iso.zip.d
   mkdir --mode 0700 memtest86+_6.00_64.grub.iso.zip.d
   if pushd memtest86+_6.00_64.grub.iso.zip.d ; then
    7z x ../memtest86+_6.00_64.grub.iso.zip
    mkdir --mode 0700 mt86plus64.grub.iso.d
    if pushd mt86plus64.grub.iso.d ; then 
     7z x ../mt86plus64.grub.iso
     if test ! -e ../../memtest86+_6.00_64.grub.cfg ; then
      cat  boot/grub/grub.cfg > ../../memtest86+_6.00_64.grub.cfg
     fi
     if test ! -e ../../memtest86+_6.00_64.bin ; then
      cat boot/memtest > ../../memtest86+_6.00_64.bin
     fi
     if test ! -e ../../memtest86+_6.00_64.grub.cfg.sha256sum ; then
      echo "d983c108fdaae0f1470647ea9d8baabb1492e5937b3430a943779b161c359435 *memtest86+_6.00_64.grub.cfg" > ../../memtest86+_6.00_64.grub.cfg.sha256sum
     fi
     if test ! -e ../../memtest86+_6.00_64.bin.sha256sum ; then
      echo "46c8dccb3e67131f11c0159993ad30b4e3c1312ac2131fd7746457c8bf30d7dd *memtest86+_6.00_64.bin" > ../../memtest86+_6.00_64.bin.sha256sum
     fi
     popd
    fi
    popd
    rm -rfv memtest86+_6.00_64.grub.iso.zip.d
    user-zvC9-sync
   else
    echo "failed to \"pushd memtest86+_6.00_64.grub.iso.zip.d\""
    sleep 5
   fi
  else
   echo "wrong sha256sum of \"memtest86+_6.00_64.grub.iso.zip\", skipping extraction"
   sleep 5
  fi
 fi
}

function zvC9-download-sources () { # sources and other files (virtualbox .deb, ext pack, VBoxGA.iso)
	# git must be installed
	mkdir -p ~root/zvC9/build/git/glib
	pushd ~root/zvC9/build/git/glib || user-zvC9-error  21 "can't cd into" ~root/zvC9/build/git/glib
  git clone https://gitlab.gnome.org/GNOME/glib.git
	 user-zvC9-sync
	 pushd ./glib || user-zvC9-error  21 "can't cd into" ~root/zvC9/build/git/glib/glib # mistake here
	  git pull || user-zvC9-error  21 "can't git pull for glib"
	  user-zvC9-sync
	 popd
	popd
	
	mkdir -p ~root/zvC9/build/git/zvC9
	pushd ~root/zvC9/build/git/zvC9 || user-zvC9-error  27 "can't cd into" ~root/zvC9/build/git/zvC9
  git clone https://github.com/user-zvC9/miscellaneous-zvC9.git
	 user-zvC9-sync
	 pushd ./miscellaneous-zvC9 || user-zvC9-error  21 "can't cd into" ~root/zvC9/build/git/zvC9/miscellaneous-zvC9 # mistake here
	  git pull || user-zvC9-error  21 "can't git pull for miscellaneous-zvC9"
	  user-zvC9-sync
	 popd
	 git clone https://github.com/user-zvC9/openvpn-scripts-zvC9.git
	 user-zvC9-sync
	 pushd ./openvpn-scripts-zvC9 || user-zvC9-error  21 "can't cd into" ~root/zvC9/build/git/zvC9/openvpn-scripts-zvC9 # mistake here
	  git pull || user-zvC9-error  21 "can't git pull for openvpn-scripts-zvC9"
	  user-zvC9-sync
	 popd
	popd
	
 
 local dldir=~root/zvC9/downloads
 mkdir -p "$dldir"
 pushd "$dldir" || user-zvC9-error  13 "can't cd into download folder"
 
  #zvC9-download-file URL filename sha256sum
  
  zvC9-download-file "https://download.anydesk.com/linux/anydesk_6.2.0-1_amd64.deb" "anydesk_6.2.0-1_amd64.deb" "0c0823b49f722774c406cefae7fb0814ebd264a8774a41200e757423bb45d115"
  zvC9-download-file "https://download.anydesk.com/linux/anydesk-6.2.0-amd64.tar.gz" "anydesk-6.2.0-amd64.tar.gz" "93ce67407d855b21170e007e3dde324ad7cd0a3922206136bc0fd84d72da2b8a"
  zvC9-download-file "https://dl.teamviewer.com/download/linux/version_15x/teamviewer_15.32.3_amd64.deb" "teamviewer_15.32.3_amd64.deb" "a128bba2cd14603fe54c637eda027e0178e1646870e24b0cf04a0e1ef4e3d540"
  zvC9-download-file "https://dl.teamviewer.com/download/linux/version_15x/teamviewer_15.32.3_amd64.tar.xz" "teamviewer_15.32.3_amd64.tar.xz" "28312864e47bf37ed1e61c17aa524bd0e5f80d3b19a68dde27c01b77836c44f9"
  
  zvC9-download-file "https://www.cairographics.org/releases/pixman-0.40.0.tar.gz" "pixman-0.40.0.tar.gz" "6d200dec3740d9ec4ec8d1180e25779c00bc749f94278c8b9021f5534db223fc"
  #user-zvC9-sync
  zvC9-download-file "https://download.qemu.org/qemu-7.0.0.tar.xz" "qemu-7.0.0.tar.xz" "f6b375c7951f728402798b0baabb2d86478ca53d44cedbefabbe1c46bf46f839"
  #user-zvC9-sync
  zvC9-download-file "https://www.memtest.org/download/archives/5.31b/memtest86+-5.31b.bin" "memtest86+-5.31b.bin" "7bd0940333d276a1731e21f5e2be18bf3d8b5e61b4a42ea15cdfeba64b21a554"
  #user-zvC9-sync
  zvC9-download-file "https://github.com/mesonbuild/meson/releases/download/0.63.0/meson-0.63.0.tar.gz" "meson-0.63.0.tar.gz" "3b51d451744c2bc71838524ec8d96cd4f8c4793d5b8d5d0d0a9c8a4f7c94cd6f"
  #user-zvC9-sync
  
  mkdir -p  virtualBox/7/7.0.2
  
  zvC9-download-file "https://download.virtualbox.org/virtualbox/7.0.2/virtualbox-7.0_7.0.2-154219~Debian~bullseye_amd64.deb" "virtualBox/7/7.0.2/virtualbox-7.0_7.0.2-154219~Debian-11~bullseye_amd64.deb"
  zvC9-download-file "https://download.virtualbox.org/virtualbox/7.0.2/VBoxGuestAdditions_7.0.2.iso" "virtualBox/7/7.0.2/VBoxGuestAdditions_7.0.2.iso"
  zvC9-download-file "https://download.virtualbox.org/virtualbox/7.0.2/UserManual.pdf" "virtualBox/7/7.0.2/VirtualBox-7.0.2-UserManual.pdf"
  
  zvC9-download-file "https://download.virtualbox.org/virtualbox/7.0.2/Oracle_VM_VirtualBox_Extension_Pack-7.0.2-154219.vbox-extpack" \
    "virtualBox/7/7.0.2/Oracle_VM_VirtualBox_Extension_Pack-7.0.2-154219.vbox-extpack"
  
  zvC9-download-file "https://download.virtualbox.org/virtualbox/7.0.2/SDKRef.pdf" \
    "virtualBox/7/7.0.2/VirtualBox-7.0.2-SDKRef.pdf"
  
  zvC9-download-file "https://download.virtualbox.org/virtualbox/7.0.2/virtualbox-7.0_7.0.2-154219~Ubuntu~jammy_amd64.deb" \
    "virtualBox/7/7.0.2/virtualbox-7.0_7.0.2-154219~Ubuntu-22.04~jammy_amd64.deb"
  
  #https://download.virtualbox.org/virtualbox/7.0.2/virtualbox-7.0_7.0.2-154219~Debian~bullseye_amd64.deb
  #https://download.virtualbox.org/virtualbox/7.0.2/VBoxGuestAdditions_7.0.2.iso
  #https://download.virtualbox.org/virtualbox/7.0.2/UserManual.pdf
  #https://download.virtualbox.org/virtualbox/7.0.2/Oracle_VM_VirtualBox_Extension_Pack-7.0.2-154219.vbox-extpack
  #https://download.virtualbox.org/virtualbox/7.0.2/SDKRef.pdf
  #https://download.virtualbox.org/virtualbox/7.0.2/virtualbox-7.0_7.0.2-154219~Ubuntu~jammy_amd64.deb
  
  if test ! -e virtualBox.sha256sum ; then
   cat > virtualBox.sha256sum << "EOF"
9cf5413399f59cfa4ba9ed89a9295b1b2ef3b997cb526a100637b5c59a526872 *virtualBox/7/7.0.2/VBoxGuestAdditions_7.0.2.iso
f692008df0fe03c4d7397b3104e0ef71464385eb911858611c628fa32eb610a4 *virtualBox/7/7.0.2/Oracle_VM_VirtualBox_Extension_Pack-7.0.2-154219.vbox-extpack
1f4b09d07e697f855dbe63961864940b0610d5a942f520a0f5d686357a88d18b *virtualBox/7/7.0.2/VirtualBox-7.0.2-UserManual.pdf
51ab890eee2ece8c5fe0234c1ef1c1fc5135cc21e13f1f4864ffe26b6c052919 *virtualBox/7/7.0.2/virtualbox-7.0_7.0.2-154219~Ubuntu-22.04~jammy_amd64.deb
38e15a6733c7ae8cd8868f3431193c192f95a98ee68f6d38611b950f0cc42a77 *virtualBox/7/7.0.2/VirtualBox-7.0.2-SDKRef.pdf
074aa9c23ed6382a915fea3518263620e6cbce35dcd237e11174e5d2d787ae93 *virtualBox/7/7.0.2/virtualbox-7.0_7.0.2-154219~Debian-11~bullseye_amd64.deb
EOF
  user-zvC9-sync
  fi
  
  zvC9-download-file "https://download.virtualbox.org/virtualbox/6.0.24/virtualbox-6.0_6.0.24-139119~Ubuntu~eoan_amd64.deb" "virtualbox-6.0_6.0.24-139119~Ubuntu~19-20-eoan_amd64.deb" "71ce6583e40edde90d4af84a63a6bf6f7cfbc8f2f825b62d75657a2a8c0b2087"
  #user-zvC9-sync
  zvC9-download-file "https://download.virtualbox.org/virtualbox/6.0.24/virtualbox-6.0_6.0.24-139119~Debian~buster_amd64.deb" "virtualbox-6.0_6.0.24-139119~Debian~10-buster_amd64.deb" "abe45a5fb9de5b3caccc27296f17ec08232fa171a0b3aacfc2f5e4e24d7f631e"
  #user-zvC9-sync
  zvC9-download-file "https://download.virtualbox.org/virtualbox/6.0.24/VirtualBox-6.0.24-139119-Linux_amd64.run" "VirtualBox-6.0.24-139119-ALL_Linux_amd64.run" "8ff8aabddef3e9213a3e8da2cac81bab68cea870ac6d01ca6df21b54dd4b0bb2"
  #user-zvC9-sync
  zvC9-download-file "https://download.virtualbox.org/virtualbox/6.0.24/Oracle_VM_VirtualBox_Extension_Pack-6.0.24.vbox-extpack" "Oracle_VM_VirtualBox_Extension_Pack-6.0.24.vbox-extpack" "708cca4a2d88e14c3c41e6be4b44227763decc94bc45cbe4d661f43bc75cf84c"
  #user-zvC9-sync
  zvC9-download-file "https://www.virtualbox.org/download/hashes/6.0.24/SHA256SUMS" "vbox-6.0.24-sha256sums.txt" "5620059065beaba3eb2c69a4d0bb5e22eb4d5a33edbcc63f4e7f10bac2eed8c9"
  #user-zvC9-sync
  zvC9-download-file "https://download.virtualbox.org/virtualbox/6.0.24/VBoxGuestAdditions_6.0.24.iso" "VBoxGuestAdditions_6.0.24.iso" "bcdf4f3eb20cf6f57cad5ff3b20921670cdd3859654952c092e9fdf5e19203e8"
  #user-zvC9-sync
  zvC9-download-file "https://download.virtualbox.org/virtualbox/6.1.36/virtualbox-6.1_6.1.36-152435~Ubuntu~jammy_amd64.deb" "virtualbox-6.1_6.1.36-152435~Ubuntu~22-jammy_amd64.deb" "5a66f180e220342eacbb7b3d111658949ccdd61588f017e880e74c5fc3d2d450"
  #user-zvC9-sync
  zvC9-download-file "https://download.virtualbox.org/virtualbox/6.1.36/virtualbox-6.1_6.1.36-152435~Ubuntu~focal_amd64.deb" "virtualbox-6.1_6.1.36-152435~Ubuntu~20-focal_amd64.deb" "6bc0bcf2b8ca5a49aac208ee35d4c1e3f75cb36b099a0c38953ef3bf31224f92"
  #user-zvC9-sync
  zvC9-download-file "https://download.virtualbox.org/virtualbox/6.1.36/virtualbox-6.1_6.1.36-152435~Debian~bullseye_amd64.deb" "virtualbox-6.1_6.1.36-152435~Debian~11-bullseye_amd64.deb" "9012c11b2956224a0cf801fb08dca03be0886846f0ce4eb4273b83d58042fcf1"
  #user-zvC9-sync
  zvC9-download-file "https://download.virtualbox.org/virtualbox/6.1.36/VirtualBox-6.1.36-152435-Linux_amd64.run" "VirtualBox-6.1.36-152435-ALL_Linux_amd64.run" "214586f62034e31f1a25e021752398019817a2dfd005bf1fadaa4e935708cb66"
  #user-zvC9-sync
  zvC9-download-file "https://www.virtualbox.org/download/hashes/6.1.36/SHA256SUMS" "vbox-6.1.36.sha256sums.txt" "8a3d24cc8390ef4a4237d7d46f3540ffc45faa492c190ac417167eb18159098e"
  #user-zvC9-sync
  zvC9-download-file "https://download.virtualbox.org/virtualbox/6.1.36/Oracle_VM_VirtualBox_Extension_Pack-6.1.36a-152435.vbox-extpack" "Oracle_VM_VirtualBox_Extension_Pack-6.1.36a-152435.vbox-extpack" "3c84f0177a47a1969aff7c98e01ddceedd50348f56cc52d63f4c2dd38ad2ca75"
  #user-zvC9-sync
  zvC9-download-file "https://download.virtualbox.org/virtualbox/6.1.36/VBoxGuestAdditions_6.1.36.iso" "VBoxGuestAdditions_6.1.36.iso" "c987cdc8c08c579f56d921c85269aeeac3faf636babd01d9461ce579c9362cdd"
  #user-zvC9-sync
  #zvC9-download-file "" "" ""
  #user-zvC9-sync
  
  zvC9-download-file "https://download.virtualbox.org/virtualbox/6.1.36/UserManual.pdf" "virtualbox-6.1.36-UserManual.pdf" "e8623508cbb61b59bb125ea9ae7bff202ab8151194033a1b61bace183b991114"
  #user-zvC9-sync
  zvC9-download-file "https://download.virtualbox.org/virtualbox/UserManual.pdf" "virtualbox-UserManual.pdf"
  #user-zvC9-sync
  zvC9-download-file "https://download.virtualbox.org/virtualbox/6.1.36/SDKRef.pdf" "virtualbox-6.1.36-SDKRef.pdf" "2356c2a7afc268f6ab389e5a6a3ce1b9856caf4df6316e19d65374c8549e027d"
  #user-zvC9-sync
  zvC9-download-HTML-page-with-requisites "https://www.virtualbox.org/manual/UserManual.html" "virtualbox-user-manual-HTML-this"
  #user-zvC9-sync

  zvC9-download-HTML-page-with-requisites "https://www.virtualbox.org/manual/" "virtualbox-user-manual-HTML-that"
  
  mkdir trinity-rescue-kit
  
  zvC9-download-file "https://ftp.osuosl.org/pub/trk/trinity-rescue-kit.3.4-build-372.iso" "trinity-rescue-kit/trinity-rescue-kit.3.4-build-372.iso"
  zvC9-download-file "https://ftp.osuosl.org/pub/trk/trinity-rescue-kit.3.4-build-400.iso" "trinity-rescue-kit/trinity-rescue-kit.3.4-build-400.iso"
  
  #"https://ftp.osuosl.org/pub/trk/trinity-rescue-kit.3.4-build-372.iso"
  #"https://ftp.osuosl.org/pub/trk/trinity-rescue-kit.3.4-build-400.iso"
  
  if test ! -e trinity-rescue-kit.sha256sum ; then
   cat > trinity-rescue-kit.sha256sum << "EOF"
f363740c36c0e8df8ed454c2b062e1f385ef8857bb83e3675bbe54f44a0b683f *trinity-rescue-kit/trinity-rescue-kit.3.4-build-400.iso
3adcbf47947e503026539e0639831eacfcc5d441e47d9c58b248c6db24754b82 *trinity-rescue-kit/trinity-rescue-kit.3.4-build-372.iso
EOF
  user-zvC9-sync
  fi
  
  mkdir -p spice-guest-tools/1
  mkdir -p spice-guest-tools/2

  mkdir -p spice-guest-tools/3/not-nneded-if-used-spice-guest-tools/win_spice_agent
  mkdir -p spice-guest-tools/3/not-nneded-if-used-spice-guest-tools/qxl/non-WDDM
  mkdir -p spice-guest-tools/3/not-nneded-if-used-spice-guest-tools/qxl/wddm-dod

zvC9-download-file "https://www.spice-space.org/download/windows/spice-guest-tools/spice-guest-tools-latest.exe" "spice-guest-tools/2/spice-guest-tools-latest.exe"
zvC9-download-file "https://www.spice-space.org/download/windows/spice-guest-tools/spice-guest-tools-0.141/spice-guest-tools-0.141.exe" "spice-guest-tools/2/spice-guest-tools-0.141.exe"
zvC9-download-file "https://www.spice-space.org/download/windows/spice-guest-tools/spice-guest-tools-0.141/spice-guest-tools-0.141.exe.sign" "spice-guest-tools/2/spice-guest-tools-0.141.exe.sign"
zvC9-download-file "https://www.spice-space.org/download/windows/spice-guest-tools/spice-guest-tools-latest.exe.sign" "spice-guest-tools/2/spice-guest-tools-latest.exe.sign"
zvC9-download-file "https://www.spice-space.org/download/windows/spice-webdavd/spice-webdavd-x86-2.4.msi.sha256" "spice-guest-tools/1/spice-webdavd-x86-2.4.msi.sha256"
zvC9-download-file "https://www.spice-space.org/download/windows/spice-webdavd/spice-webdavd-x64-2.4.msi.sha256" "spice-guest-tools/1/spice-webdavd-x64-2.4.msi.sha256"
zvC9-download-file "https://www.spice-space.org/download/windows/spice-webdavd/spice-webdavd-x64-2.4.msi" "spice-guest-tools/1/spice-webdavd-x64-2.4.msi"
zvC9-download-file "https://www.spice-space.org/download/windows/spice-webdavd/spice-webdavd-x64-2.4.msi.sig" "spice-guest-tools/1/spice-webdavd-x64-2.4.msi.sig"
zvC9-download-file "https://www.spice-space.org/download/windows/spice-webdavd/spice-webdavd-x86-2.4.msi.sig" "spice-guest-tools/1/spice-webdavd-x86-2.4.msi.sig"
zvC9-download-file "https://www.spice-space.org/download/windows/spice-webdavd/spice-webdavd-x86-2.4.msi" "spice-guest-tools/1/spice-webdavd-x86-2.4.msi"

zvC9-download-file "https://download.virtualbox.org/virtualbox/7.0.0/virtualbox-7.0_7.0.0-153978~Debian~bullseye_amd64.deb" "virtualbox-7.0_7.0.0-153978~Debian-11~bullseye_amd64.deb" "c46c962d7945baebd48b188a42f4827d48aadb48bda4479d51d0fb85dd013cd5"
zvC9-download-file "https://download.virtualbox.org/virtualbox/7.0.0/virtualbox-7.0_7.0.0-153978~Ubuntu~jammy_amd64.deb" "virtualbox-7.0_7.0.0-153978~Ubuntu-22.04~jammy_amd64.deb" "ea15f47d0df900ff1f2e57d7656762b7a014a8371d87b928e33d09769ec8bbff"
zvC9-download-file "https://download.virtualbox.org/virtualbox/7.0.0/Oracle_VM_VirtualBox_Extension_Pack-7.0.0.vbox-extpack" "Oracle_VM_VirtualBox_Extension_Pack-7.0.0.vbox-extpack" "e32555a2d2482c1e1126747f967742364ddfdfd49fce3107a9627780f373ffd7"

# this is buggy but tested:
zvC9-download-file  "https://www.memtest.org/download/v6.00b3/mt86plus_6.00b3_64.grub.iso.zip" "memtest86+_6.00b3_64.grub.iso.zip" "7d1b89f4701c19a49511ae7f6c57f481d8b82a33cd4e017fca3f594a2eec3059"

# this is not tested:
zvC9-download-file  "https://www.memtest.org/download/v6.00/mt86plus_6.00_64.grub.iso.zip" "memtest86+_6.00_64.grub.iso.zip" "e3263d1adf44a70ff6d317996b64656783ba8ccaa7094c7c032644bbd40dfc70"

zvC9-unpack-memtest86plus-6.00

#zvC9-download-file "https://www.spice-space.org/download/windows/qxl/qxl-0.1-24/Red_Hat_QXL_0.1.24.2_x64.msi" "spice-guest-tools/3/not-needed-if-used-spice-guest-tools/qxl/non-WDDM/Red_Hat_QXL_0.1.24.2_x64.msi"
#zvC9-download-file "https://www.spice-space.org/download/windows/qxl/qxl-0.1-24/qxl-win-unsigned-0.1-24-sources.zip" "spice-guest-tools/3/not-needed-if-used-spice-guest-tools/qxl/non-WDDM/qxl-win-unsigned-0.1-24-sources.zip"
#zvC9-download-file "https://www.spice-space.org/download/windows/qxl/qxl-0.1-24/qxl-win-unsigned-0.1-24-spec.zip" "spice-guest-tools/3/not-needed-if-used-spice-guest-tools/qxl/non-WDDM/qxl-win-unsigned-0.1-24-spec.zip"
#zvC9-download-file "https://www.spice-space.org/download/windows/qxl/qxl-0.1-24/qxl_w7_x86.zip" "spice-guest-tools/3/not-needed-if-used-spice-guest-tools/qxl/non-WDDM/qxl_w7_x86.zip"
#zvC9-download-file "https://www.spice-space.org/download/windows/qxl/qxl-0.1-24/qxl_w7_x64.zip" "spice-guest-tools/3/not-needed-if-used-spice-guest-tools/qxl/non-WDDM/qxl_w7_x64.zip"
#zvC9-download-file "https://www.spice-space.org/download/windows/qxl/qxl-0.1-24/qxl_8k2R2_x64.zip" "spice-guest-tools/3/not-needed-if-used-spice-guest-tools/qxl/non-WDDM/qxl_8k2R2_x64.zip"
#zvC9-download-file "https://www.spice-space.org/download/windows/qxl/qxl-0.1-24/Red_Hat_QXL_0.1.24.2_x86.msi" "spice-guest-tools/3/not-needed-if-used-spice-guest-tools/qxl/non-WDDM/Red_Hat_QXL_0.1.24.2_x86.msi"

#zvC9-download-file "https://www.spice-space.org/download/windows/qxl-wddm-dod/qxl-wddm-dod-0.21/spice-qxl-wddm-dod-0.21.zip" "spice-guest-tools/3/not-needed-if-used-spice-guest-tools/qxl/wddm-dod/spice-qxl-wddm-dod-0.21.zip"
#zvC9-download-file "https://www.spice-space.org/download/windows/qxl-wddm-dod/qxl-wddm-dod-0.21/spice-qxl-wddm-dod-8.1-compatible.zip" "spice-guest-tools/3/not-needed-if-used-spice-guest-tools/qxl/wddm-dod/spice-qxl-wddm-dod-8.1-compatible.zip"
#zvC9-download-file "https://www.spice-space.org/download/windows/qxl-wddm-dod/qxl-wddm-dod-0.21/QxlWddmDod_0.21.0.0_x64.msi" "spice-guest-tools/3/not-needed-if-used-spice-guest-tools/qxl/wddm-dod/QxlWddmDod_0.21.0.0_x64.msi"
#zvC9-download-file "https://www.spice-space.org/download/windows/qxl-wddm-dod/qxl-wddm-dod-0.21/spice-qxl-wddm-dod-0.21-0-sources.zip" "spice-guest-tools/3/not-needed-if-used-spice-guest-tools/qxl/wddm-dod/spice-qxl-wddm-dod-0.21-0-sources.zip"
#zvC9-download-file "https://www.spice-space.org/download/windows/qxl-wddm-dod/qxl-wddm-dod-0.21/QxlWddmDod_0.21.0.0_x86.msi" "spice-guest-tools/3/not-needed-if-used-spice-guest-tools/qxl/wddm-dod/QxlWddmDod_0.21.0.0_x86.msi"
#zvC9-download-file "https://www.spice-space.org/download/windows/qxl-wddm-dod/qxl-wddm-dod-0.21/spice-qxl-wddm-dod-0.21-no-MSIs.zip" "spice-guest-tools/3/not-needed-if-used-spice-guest-tools/qxl/wddm-dod/spice-qxl-wddm-dod-0.21-no-MSIs.zip"
#zvC9-download-file "https://www.spice-space.org/download/windows/vdagent/vdagent-win-0.10.0/vdagent-win-0.10.0.tar.xz" "spice-guest-tools/3/not-needed-if-used-spice-guest-tools/win_spice_agent/vdagent-win-0.10.0.tar.xz"
#zvC9-download-file "https://www.spice-space.org/download/windows/vdagent/vdagent-win-0.10.0/spice-vdagent-x86-0.10.0.msi" "spice-guest-tools/3/not-needed-if-used-spice-guest-tools/win_spice_agent/spice-vdagent-x86-0.10.0.msi"
#zvC9-download-file "https://www.spice-space.org/download/windows/vdagent/vdagent-win-0.10.0/spice-vdagent-x64-0.10.0.msi" "spice-guest-tools/3/not-needed-if-used-spice-guest-tools/win_spice_agent/spice-vdagent-x64-0.10.0.msi"
#zvC9-download-file "https://www.spice-space.org/download/windows/vdagent/vdagent-win-0.10.0/vdagent-win-0.10.0-x64.zip" "spice-guest-tools/3/not-needed-if-used-spice-guest-tools/win_spice_agent/vdagent-win-0.10.0-x64.zip"
#zvC9-download-file "https://www.spice-space.org/download/windows/vdagent/vdagent-win-0.10.0/vdagent-win-0.10.0-x86.zip" "spice-guest-tools/3/not-needed-if-used-spice-guest-tools/win_spice_agent/vdagent-win-0.10.0-x86.zip"

# zvC9-download-file "https://www.spice-space.org/download/windows/spice-guest-tools/spice-guest-tools-latest.exe" "spice-guest-tools/2/spice-guest-tools-0.141.exe"
# zvC9-download-file "https://www.spice-space.org/download/windows/spice-guest-tools/spice-guest-tools-0.141/spice-guest-tools-0.141.exe" "spice-guest-tools/2/spice-guest-tools-0.141.exe.sign"
# zvC9-download-file "https://www.spice-space.org/download/windows/spice-guest-tools/spice-guest-tools-0.141/spice-guest-tools-0.141.exe.sign" "spice-guest-tools/2/spice-guest-tools-latest.exe"
# zvC9-download-file "https://www.spice-space.org/download/windows/spice-guest-tools/spice-guest-tools-latest.exe.sign" "spice-guest-tools/2/spice-guest-tools-latest.exe.sign"
# zvC9-download-file "https://www.spice-space.org/download/windows/spice-webdavd/spice-webdavd-x86-2.4.msi.sha256" "spice-guest-tools/1/spice-webdavd-x64-2.4.msi"
# zvC9-download-file "https://www.spice-space.org/download/windows/spice-webdavd/spice-webdavd-x64-2.4.msi.sha256" "spice-guest-tools/1/spice-webdavd-x64-2.4.msi.sha256"
# zvC9-download-file "https://www.spice-space.org/download/windows/spice-webdavd/spice-webdavd-x64-2.4.msi" "spice-guest-tools/1/spice-webdavd-x64-2.4.msi.sig"
# zvC9-download-file "https://www.spice-space.org/download/windows/spice-webdavd/spice-webdavd-x64-2.4.msi.sig" "spice-guest-tools/1/spice-webdavd-x86-2.4.msi"
# zvC9-download-file "https://www.spice-space.org/download/windows/spice-webdavd/spice-webdavd-x86-2.4.msi.sig" "spice-guest-tools/1/spice-webdavd-x86-2.4.msi.sha256"
# zvC9-download-file "https://www.spice-space.org/download/windows/spice-webdavd/spice-webdavd-x86-2.4.msi" "spice-guest-tools/1/spice-webdavd-x86-2.4.msi.sig"
# zvC9-download-file "https://www.spice-space.org/download/windows/qxl/qxl-0.1-24/Red_Hat_QXL_0.1.24.2_x64.msi" "spice-guest-tools/3/not-needed-if-used-spice-guest-tools/qxl/non-WDDM/qxl_8k2R2_x64.zip"
# zvC9-download-file "https://www.spice-space.org/download/windows/qxl/qxl-0.1-24/qxl-win-unsigned-0.1-24-sources.zip" "spice-guest-tools/3/not-needed-if-used-spice-guest-tools/qxl/non-WDDM/qxl-win-unsigned-0.1-24-sources.zip"
# zvC9-download-file "https://www.spice-space.org/download/windows/qxl/qxl-0.1-24/qxl-win-unsigned-0.1-24-spec.zip" "spice-guest-tools/3/not-needed-if-used-spice-guest-tools/qxl/non-WDDM/Red_Hat_QXL_0.1.24.2_x64.msi"
# zvC9-download-file "https://www.spice-space.org/download/windows/qxl/qxl-0.1-24/qxl_w7_x86.zip" "spice-guest-tools/3/not-needed-if-used-spice-guest-tools/qxl/non-WDDM/Red_Hat_QXL_0.1.24.2_x86.msi"
# zvC9-download-file "https://www.spice-space.org/download/windows/qxl/qxl-0.1-24/qxl_w7_x64.zip" "spice-guest-tools/3/not-needed-if-used-spice-guest-tools/qxl/non-WDDM/qxl_w7_x86.zip"
# zvC9-download-file "https://www.spice-space.org/download/windows/qxl/qxl-0.1-24/qxl_8k2R2_x64.zip" "spice-guest-tools/3/not-needed-if-used-spice-guest-tools/qxl/non-WDDM/qxl-win-unsigned-0.1-24-spec.zip"
# zvC9-download-file "https://www.spice-space.org/download/windows/qxl/qxl-0.1-24/Red_Hat_QXL_0.1.24.2_x86.msi" "spice-guest-tools/3/not-needed-if-used-spice-guest-tools/qxl/non-WDDM/qxl_w7_x64.zip"
# zvC9-download-file "https://www.spice-space.org/download/windows/qxl-wddm-dod/qxl-wddm-dod-0.21/spice-qxl-wddm-dod-0.21.zip" "spice-guest-tools/3/not-needed-if-used-spice-guest-tools/qxl/wddm-dod/QxlWddmDod_0.21.0.0_x86.msi"
# zvC9-download-file "https://www.spice-space.org/download/windows/qxl-wddm-dod/qxl-wddm-dod-0.21/spice-qxl-wddm-dod-8.1-compatible.zip" "spice-guest-tools/3/not-needed-if-used-spice-guest-tools/qxl/wddm-dod/QxlWddmDod_0.21.0.0_x64.msi"
# zvC9-download-file "https://www.spice-space.org/download/windows/qxl-wddm-dod/qxl-wddm-dod-0.21/QxlWddmDod_0.21.0.0_x64.msi" "spice-guest-tools/3/not-needed-if-used-spice-guest-tools/qxl/wddm-dod/spice-qxl-wddm-dod-0.21-0-sources.zip"
# zvC9-download-file "https://www.spice-space.org/download/windows/qxl-wddm-dod/qxl-wddm-dod-0.21/spice-qxl-wddm-dod-0.21-0-sources.zip" "spice-guest-tools/3/not-needed-if-used-spice-guest-tools/qxl/wddm-dod/spice-qxl-wddm-dod-0.21.zip"
# zvC9-download-file "https://www.spice-space.org/download/windows/qxl-wddm-dod/qxl-wddm-dod-0.21/QxlWddmDod_0.21.0.0_x86.msi" "spice-guest-tools/3/not-needed-if-used-spice-guest-tools/qxl/wddm-dod/spice-qxl-wddm-dod-8.1-compatible.zip"
# zvC9-download-file "https://www.spice-space.org/download/windows/qxl-wddm-dod/qxl-wddm-dod-0.21/spice-qxl-wddm-dod-0.21-no-MSIs.zip" "spice-guest-tools/3/not-needed-if-used-spice-guest-tools/qxl/wddm-dod/spice-qxl-wddm-dod-0.21-no-MSIs.zip"
# zvC9-download-file "https://www.spice-space.org/download/windows/vdagent/vdagent-win-0.10.0/vdagent-win-0.10.0.tar.xz" "spice-guest-tools/3/not-needed-if-used-spice-guest-tools/win_spice_agent/vdagent-win-0.10.0-x86.zip"
# zvC9-download-file "https://www.spice-space.org/download/windows/vdagent/vdagent-win-0.10.0/spice-vdagent-x86-0.10.0.msi" "spice-guest-tools/3/not-needed-if-used-spice-guest-tools/win_spice_agent/spice-vdagent-x64-0.10.0.msi"
# zvC9-download-file "https://www.spice-space.org/download/windows/vdagent/vdagent-win-0.10.0/spice-vdagent-x64-0.10.0.msi" "spice-guest-tools/3/not-needed-if-used-spice-guest-tools/win_spice_agent/vdagent-win-0.10.0.tar.xz"
# zvC9-download-file "https://www.spice-space.org/download/windows/vdagent/vdagent-win-0.10.0/vdagent-win-0.10.0-x64.zip" "spice-guest-tools/3/not-needed-if-used-spice-guest-tools/win_spice_agent/spice-vdagent-x86-0.10.0.msi"
# zvC9-download-file "https://www.spice-space.org/download/windows/vdagent/vdagent-win-0.10.0/vdagent-win-0.10.0-x86.zip" "spice-guest-tools/3/not-needed-if-used-spice-guest-tools/win_spice_agent/vdagent-win-0.10.0-x64.zip"

if test ! -e spice-guest-tools.sha256sum ; then
	cat > spice-guest-tools.sha256sum <<"EOF"
b5be0754802bcd7f7fe0ccdb877f8a6224ba13a2af7d84eb087a89b3b0237da2 *spice-guest-tools/2/spice-guest-tools-0.141.exe
caf9349714242b7507b5267c8d71fdf55d6f3772d5e3ddee2da8c6696dbeca62 *spice-guest-tools/2/spice-guest-tools-0.141.exe.sign
b5be0754802bcd7f7fe0ccdb877f8a6224ba13a2af7d84eb087a89b3b0237da2 *spice-guest-tools/2/spice-guest-tools-latest.exe
caf9349714242b7507b5267c8d71fdf55d6f3772d5e3ddee2da8c6696dbeca62 *spice-guest-tools/2/spice-guest-tools-latest.exe.sign
f278c17fca6b129eb5c9a46b8634af2ecfaf3bca8903eb9a5c7874f0e45f82b9 *spice-guest-tools/1/spice-webdavd-x64-2.4.msi
0a59881331afd785995661231e91d3c46e4aa13f9849eb9fe7ec1a68bfbdab1f *spice-guest-tools/1/spice-webdavd-x64-2.4.msi.sha256
79454ce3ff8c02e317ada7127447db3eec64e555d3ed139488c2288f89f497f0 *spice-guest-tools/1/spice-webdavd-x64-2.4.msi.sig
6b267fde65e0b9d26a5a5b89ec5bfb0b980b4adca4ffb933d407118f17dce5ac *spice-guest-tools/1/spice-webdavd-x86-2.4.msi
6ded07c12da2e8d6300fc51f68e6cc16133fb01bca20f6568bcdae903f4c6d38 *spice-guest-tools/1/spice-webdavd-x86-2.4.msi.sha256
022c2c503209df48b29c76a89af20275e4d6ce020c2f5433927df7da2cefb35b *spice-guest-tools/1/spice-webdavd-x86-2.4.msi.sig
#12d78409c1b5510b8feebc9b96d40dd55e2a28ade38d7991cbad0cb5d6c03588 *spice-guest-tools/3/not-needed-if-used-spice-guest-tools/qxl/non-WDDM/qxl_8k2R2_x64.zip
#9c9159d8f7194b07506a40ac8538281b95bd4142e0564a261be9079cd53b7473 *spice-guest-tools/3/not-needed-if-used-spice-guest-tools/qxl/non-WDDM/qxl-win-unsigned-0.1-24-sources.zip
#ad1ec91fe143c62e36c7111d7d51a962f153d0421019393916edceaa435ec6ca *spice-guest-tools/3/not-needed-if-used-spice-guest-tools/qxl/non-WDDM/Red_Hat_QXL_0.1.24.2_x64.msi
#49517cdd2e47b3bb2583a8aa8eac861f59be90e4ced1c15e1c5f5d5d748571d6 *spice-guest-tools/3/not-needed-if-used-spice-guest-tools/qxl/non-WDDM/Red_Hat_QXL_0.1.24.2_x86.msi
#286dff62094cc0830e1faea038994475444cde42cb36fe8f0b9e3c644e507a7c *spice-guest-tools/3/not-needed-if-used-spice-guest-tools/qxl/non-WDDM/qxl_w7_x86.zip
#3dd7e4bba947f6bb2955b121b682ea27d98662fea7da1981343a8781c3015651 *spice-guest-tools/3/not-needed-if-used-spice-guest-tools/qxl/non-WDDM/qxl-win-unsigned-0.1-24-spec.zip
#e0168679800ea3147fccccc92810f9fae3efc0c4be65d5d18f1fafedd94785a5 *spice-guest-tools/3/not-needed-if-used-spice-guest-tools/qxl/non-WDDM/qxl_w7_x64.zip
#0f13c07b0d3e4ee0916ded1686d93c8214cf863b2038d96ee593b5b0a1d16af9 *spice-guest-tools/3/not-needed-if-used-spice-guest-tools/qxl/wddm-dod/QxlWddmDod_0.21.0.0_x86.msi
#cdc3031a30bbab2c22d0ee211a1ede49cd809ff3b208f7fdd07f5108b0b4c52b *spice-guest-tools/3/not-needed-if-used-spice-guest-tools/qxl/wddm-dod/QxlWddmDod_0.21.0.0_x64.msi
#1d90b839bd706b9f195848bc3a744ec8c02b1368bcdbc9be508d202f813d92da *spice-guest-tools/3/not-needed-if-used-spice-guest-tools/qxl/wddm-dod/spice-qxl-wddm-dod-0.21-0-sources.zip
#18882b77bba7b6928dd66e581d56e94f277523ff8e68a7e1738c0ede1f29587a *spice-guest-tools/3/not-needed-if-used-spice-guest-tools/qxl/wddm-dod/spice-qxl-wddm-dod-0.21.zip
#3380d0c76c4a7655c9eccaa1767d8f5523dd1f92605261193d00e1ca02298c98 *spice-guest-tools/3/not-needed-if-used-spice-guest-tools/qxl/wddm-dod/spice-qxl-wddm-dod-8.1-compatible.zip
#78c079c53b84cc0550841a1a8f71b6bb1fbd4caa48682cd9db132524fd9332d9 *spice-guest-tools/3/not-needed-if-used-spice-guest-tools/qxl/wddm-dod/spice-qxl-wddm-dod-0.21-no-MSIs.zip
#810910897fd05c87fabf40062ad71bc14ecaee2d428828296bc967ac31054c90 *spice-guest-tools/3/not-needed-if-used-spice-guest-tools/win_spice_agent/vdagent-win-0.10.0-x86.zip
#77629435705bc27dd7d2525e9d2084f72dbab5fdbf310e812f91332fe18d00eb *spice-guest-tools/3/not-needed-if-used-spice-guest-tools/win_spice_agent/spice-vdagent-x64-0.10.0.msi
#918be9638164212d1787f9a9107584c5445adc638e592ae9260ec0797b25020d *spice-guest-tools/3/not-needed-if-used-spice-guest-tools/win_spice_agent/vdagent-win-0.10.0.tar.xz
#db2779e2f746c1c7bb45d90203dde1691269a57b99bdf39afbe4aa391e04fced *spice-guest-tools/3/not-needed-if-used-spice-guest-tools/win_spice_agent/spice-vdagent-x86-0.10.0.msi
#713c14456846ee62431afdc269cffefd437b0cd4474fa24ed8338cd2e8665cf4 *spice-guest-tools/3/not-needed-if-used-spice-guest-tools/win_spice_agent/vdagent-win-0.10.0-x64.zip
EOF
fi



  # https://www.virtualbox.org/manual/UserManual.html
  
  # https://download.virtualbox.org/virtualbox/6.1.36/UserManual.pdf
  # https://download.virtualbox.org/virtualbox/6.1.36/SDKRef.pdf
  # https://download.virtualbox.org/virtualbox/UserManual.pdf
  ## wget html+requisites
  # https://www.virtualbox.org/manual/UserManual.html
  
  # 2356c2a7afc268f6ab389e5a6a3ce1b9856caf4df6316e19d65374c8549e027d *virtualbox-6.1.36-SDKRef.pdf
  # e8623508cbb61b59bb125ea9ae7bff202ab8151194033a1b61bace183b991114 *virtualbox-6.1.36-UserManual.pdf
  # e8623508cbb61b59bb125ea9ae7bff202ab8151194033a1b61bace183b991114 *virtualbox-UserManual.pdf
  if test ! -e hp-plugin.URLs.txt ; then
   cat > hp-plugin.URLs.txt << "EOF"
https://developers.hp.com/sites/default/files/hplip-3.17.11-plugin.run
https://developers.hp.com/sites/default/files/hplip-3.17.11-plugin.run.asc
https://developers.hp.com/sites/default/files/hplip-3.18.3-plugin.run
https://developers.hp.com/sites/default/files/hplip-3.18.3-plugin.run.asc
https://developers.hp.com/sites/default/files/hplip-3.18.4-plugin.run
https://developers.hp.com/sites/default/files/hplip-3.18.4-plugin.run.asc
https://developers.hp.com/sites/default/files/hplip-3.18.5-plugin.run
https://developers.hp.com/sites/default/files/hplip-3.18.5-plugin.run.asc
https://developers.hp.com/sites/default/files/hplip-3.18.6-plugin.run
https://developers.hp.com/sites/default/files/hplip-3.18.6-plugin.run.asc
https://developers.hp.com/sites/default/files/hplip-3.18.7-plugin.run
https://developers.hp.com/sites/default/files/hplip-3.18.7-plugin.run.asc
https://developers.hp.com/sites/default/files/hplip-3.18.9-plugin.run
https://developers.hp.com/sites/default/files/hplip-3.18.9-plugin.run.asc
https://developers.hp.com/sites/default/files/hplip-3.18.10-plugin.run
https://developers.hp.com/sites/default/files/hplip-3.18.10-plugin.run.asc
https://developers.hp.com/sites/default/files/hplip-3.18.12-plugin.run
https://developers.hp.com/sites/default/files/hplip-3.18.12-plugin.run.asc
https://developers.hp.com/sites/default/files/hplip-3.19.1-plugin.run
https://developers.hp.com/sites/default/files/hplip-3.19.1-plugin.run.asc
https://developers.hp.com/sites/default/files/hplip-3.19.3-plugin.run
https://developers.hp.com/sites/default/files/hplip-3.19.3-plugin.run.asc
https://developers.hp.com/sites/default/files/hplip-3.19.5-plugin.run
https://developers.hp.com/sites/default/files/hplip-3.19.5-plugin.run.asc
https://developers.hp.com/sites/default/files/hplip-3.19.6-plugin.run
https://developers.hp.com/sites/default/files/hplip-3.19.6-plugin.run.asc
https://developers.hp.com/sites/default/files/hplip-3.19.8-plugin.run
https://developers.hp.com/sites/default/files/hplip-3.19.8-plugin.run.asc
https://developers.hp.com/sites/default/files/hplip-3.19.10-plugin.run
https://developers.hp.com/sites/default/files/hplip-3.19.10-plugin.run.asc
https://developers.hp.com/sites/default/files/hplip-3.19.11-plugin.run
https://developers.hp.com/sites/default/files/hplip-3.19.11-plugin.run.asc
https://developers.hp.com/sites/default/files/hplip-3.19.12-plugin.run
https://developers.hp.com/sites/default/files/hplip-3.19.12-plugin.run.asc
https://developers.hp.com/sites/default/files/hplip-3.20.3-plugin.run
https://developers.hp.com/sites/default/files/hplip-3.20.3-plugin.run.asc
https://developers.hp.com/sites/default/files/hplip-3.20.5-plugin.run
https://developers.hp.com/sites/default/files/hplip-3.20.5-plugin.run.asc
https://developers.hp.com/sites/default/files/hplip-3.20.6-plugin.run
https://developers.hp.com/sites/default/files/hplip-3.20.6-plugin.run.asc
https://developers.hp.com/sites/default/files/hplip-3.20.9-plugin.run
https://developers.hp.com/sites/default/files/hplip-3.20.9-plugin.run.asc
https://developers.hp.com/sites/default/files/hplip-3.20.11-plugin.run
https://developers.hp.com/sites/default/files/hplip-3.20.11-plugin.run.asc
https://developers.hp.com/sites/default/files/hplip-3.21.2-plugin.run
https://developers.hp.com/sites/default/files/hplip-3.21.2-plugin.run.asc
https://developers.hp.com/sites/default/files/hplip-3.21.4-plugin.run
https://developers.hp.com/sites/default/files/hplip-3.21.4-plugin.run.asc
https://developers.hp.com/sites/default/files/hplip-3.21.6-plugin.run
https://developers.hp.com/sites/default/files/hplip-3.21.6-plugin.run.asc
https://developers.hp.com/sites/default/files/hplip-3.21.8-plugin.run
https://developers.hp.com/sites/default/files/hplip-3.21.8-plugin.run.asc
https://developers.hp.com/sites/default/files/hplip-3.21.10-plugin.run
https://developers.hp.com/sites/default/files/hplip-3.21.10-plugin.run.asc
https://developers.hp.com/sites/default/files/hplip-3.21.12-plugin.run
https://developers.hp.com/sites/default/files/hplip-3.21.12-plugin.run.asc
https://developers.hp.com/sites/default/files/hplip-3.22.2-plugin.run
https://developers.hp.com/sites/default/files/hplip-3.22.2-plugin.run.asc
https://developers.hp.com/sites/default/files/hplip-3.22.4-plugin.run
https://developers.hp.com/sites/default/files/hplip-3.22.4-plugin.run.asc
https://developers.hp.com/sites/default/files/hplip-3.22.6-plugin.run
https://developers.hp.com/sites/default/files/hplip-3.22.6-plugin.run.asc
EOF
  fi
  if test ! -e hp-plugin.sha256sum ; then
   cat > hp-plugin.sha256sum << "EOF"
957c5df31b2fcaf0ed02885f1c600579686a1981731717d9554dbc373d58c7f7 *hp-plugin/hplip-3.21.4-plugin.run
10d6cfa0e3f00644feb9283885475844bda40093f9a0c8a2c795ca4bd2baf1b8 *hp-plugin/hplip-3.19.11-plugin.run
781bbe5cb03cfd4bad3231a158766beda89c9c62c712117c7c0b40799ad7e0ed *hp-plugin/hplip-3.21.4-plugin.run.asc
b13e85b85987bdc01bcd12d48322305ac8bb9466384e1791c00abf25670e060b *hp-plugin/hplip-3.21.6-plugin.run
54ed57ffc666efb1e60a9b413243bd8d5897974cf2a2dab6da99d3325e37efe1 *hp-plugin/hplip-3.18.5-plugin.run.asc
c0561c7f49c4c48e7f2f4dc50507a3b10e0d5714aa656380a2e2d8c1691d414c *hp-plugin/hplip-3.19.8-plugin.run
4224c9b717016e3f517ceea56f25d223e2237ed70ecac93adc71ef8bda75685e *hp-plugin/hplip-3.21.6-plugin.run.asc
363a467925ecca8a0856821ea74a2ae74445f654313f59427289452032d6aef3 *hp-plugin/hplip-3.21.2-plugin.run
c888f93256f48230685053d9baf3e34fb6f2969a79a7c9289356e5fee9bfb81c *hp-plugin/hplip-3.22.4-plugin.run
d6786c9a294373419c714ddf2d99b588dbdc17fc0f5f092f1812adfa7f2c81c5 *hp-plugin/hplip-3.18.10-plugin.run
2faf4d2ceca3995f607a0b8b11662c5f32e14dc585b240e64193830a555b02a1 *hp-plugin/hplip-3.18.9-plugin.run
618a29570c702ccccbe6a9476d40b422a7c29ed457657cc47e88dcdacefff207 *hp-plugin/hplip-3.18.4-plugin.run.asc
7b260d86e7dff2633822945f9ff7cb063409db726b4ddb07050fc41fb520d20c *hp-plugin/hplip-3.21.12-plugin.run
0f51c5bc5c87d3a10aaa70d12ce6c6605d20f1b1fe01f8ce74da4b2cc1d8be8f *hp-plugin/hplip-3.20.3-plugin.run
c89a33e30da0a0786b0ea87931cda6048567fbf7ebeb8b3d57fedec28a2fc83f *hp-plugin/hplip-3.21.2-plugin.run.asc
2d94d3973be03130168e59cd656690d600b3db7141782add280b263c6525216f *hp-plugin/hplip-3.19.11-plugin.run.asc
bb424c1533b6f82c646c460aa16e957330d3272b15fa408af642d85df2fc3e6e *hp-plugin/hplip-3.18.4-plugin.run
a238564577eb21e2f46ba208b7b9bdd877e509a4a8d64722ff97df5e1bb38498 *hp-plugin/hplip-3.18.3-plugin.run.asc
ce3ce0f05a6339a17d69af95f0cd552ea3920bdd6bfc05f0ba4ba8b2feb1c2a0 *hp-plugin/hplip-3.22.2-plugin.run
a8f5d61074f733fc2cdc2ab357a3e570d35cd49aa8e7a6c65eb0f27fe66e7b3e *hp-plugin/hplip-3.20.6-plugin.run.asc
ee4f3e507d4483c42778160c7a4d7e6b88683fbda4f0197aea2d2f738eb17bdf *hp-plugin/hplip-3.20.11-plugin.run.asc
f7c4803ccd0b9cae096cf8f0d97c67efdf03c060c0260ff9c63f1ca0bc24c7c9 *hp-plugin/hplip-3.18.5-plugin.run
7bc2b10fa8c77b555201264e50f68b685521cb7f58e834b9ca3e4ba4713c4dcd *hp-plugin/hplip-3.20.9-plugin.run.asc
3124023e749754bad74b59cf208be5531d31b216f25343a5a5f2ce82164c82fb *hp-plugin/hplip-3.22.6-plugin.run
230a175b381f23feab194b6ed8ddb1a174d816ec3ecc1d723ed1331ffcf592bb *hp-plugin/hplip-3.19.1-plugin.run
d5553d617257af7def17996ba897d40d7f19a814c5c5b963218b7cb19f72116c *hp-plugin/hplip-3.19.3-plugin.run.asc
7ed7d993f0bf0bf933ddbf0da5b73aebb4ff14b0ad35c2e4a26f806be126bf9f *hp-plugin/hplip-3.19.6-plugin.run.asc
ff3dedda3158be64b985efbf636890ddda5b271ae1f1fbd788219e1344a9c2e7 *hp-plugin/hplip-3.20.5-plugin.run
e4ccfaf41f9261fa2a663f1dd7e0cdb889c1aa62fa1ffe05d340973df748af7c *hp-plugin/hplip-3.18.6-plugin.run
3e78296766ebb546028a7f0ab07b3185d1bebc088855090ffe8e1c3692547a80 *hp-plugin/hplip-3.20.3-plugin.run.asc
5509b799cd0bf03feb182be75adf89215ee10183897e15b828f1a9dac5e03328 *hp-plugin/hplip-3.21.8-plugin.run
6f99aa23d13f09698b6388f39732f25d1a89e54e77297e5ff0845ac72e076856 *hp-plugin/hplip-3.20.5-plugin.run.asc
878c9f3f4490ee9da0f1fc192448605c7790b96fd2c570009458da5f5480c8ba *hp-plugin/hplip-3.19.12-plugin.run
ad5e021f2dea9b73191cec8db5932c20b31582b26a53f67ce9810d09970008bf *hp-plugin/hplip-3.20.9-plugin.run
5c6bd91ee3861a142af03cc038882ccd8d97bf942237700f135034e8221bcc86 *hp-plugin/hplip-3.18.3-plugin.run
f8ff8f46d85d8de80945c46730dcbd9a032a9fb0b9591a86c4e04fcd0f261626 *hp-plugin/hplip-3.19.3-plugin.run
d115f2939c10a47bf3b99e636e4ed814535170252f3a286d5ad3bdb62a849e7f *hp-plugin/hplip-3.18.7-plugin.run.asc
065551308472bf8425dc2fc16ff314982b9b1cc2481cf9273e8a8283fd84ab81 *hp-plugin/hplip-3.18.6-plugin.run.asc
617199329633a5cff1090d067e69152fe8c6c5bb345ecdb04bb4cc9e8aa81f41 *hp-plugin/hplip-3.19.10-plugin.run
2f11bbf8b76bdf3a71035ce69519555d28e8aee724606ccca60c77f86ab5d8b9 *hp-plugin/hplip-3.21.10-plugin.run
d1e97c155e24fcb8474eb5fe99446e61b1bb610fea85c66ac072c347e28b0a45 *hp-plugin/hplip-3.17.11-plugin.run.asc
9700cb20c259417e7678a1347634d8c3fb2f03d13369ad96e6536a49f0f1e3cf *hp-plugin/hplip-3.20.6-plugin.run
032f39b907cb74b8a4b6bae680c520032b507078050c8d5fa78b37e4dc10ae7a *hp-plugin/hplip-3.21.12-plugin.run.asc
6493020c2f24b5a20a67509bcd3f523d0f46071eb1b5ee2a62a1ff7e8e803de8 *hp-plugin/hplip-3.21.10-plugin.run.asc
bd1ff8ba5b41fc7799b8b37fe5b993761bb6f32065fbfc3ff80fd7198ec68266 *hp-plugin/hplip-3.22.2-plugin.run.asc
83b90c8f3cf283cc13867c89ad7589a41a25d46c9259a542a11affb203db7bd7 *hp-plugin/hplip-3.21.8-plugin.run.asc
2b17aa25c7afb740bdb899cfbfebefd36054e1f0194b9f9a3aac4d45e723d6d6 *hp-plugin/hplip-3.19.1-plugin.run.asc
7dc2d4669bf504e15375475efdf5bfcd10dafa326c12c5de9bf5d6a13c3c53fc *hp-plugin/hplip-3.18.7-plugin.run
0df3cd3f3e9ac2d50674ed1aff82b60359318940066273930435283f862384ed *hp-plugin/hplip-3.19.8-plugin.run.asc
fe75e68467866e147d9f8e81706ea734637eeca99e3fdd75e2d1fb2b417a8dc5 *hp-plugin/hplip-3.22.4-plugin.run.asc
3c31a04508aa25cbb99e50b07caee573f7ccf25b90b5bf6063b6ef3118e6106f *hp-plugin/hplip-3.17.11-plugin.run
ff60df5f27eb156290c608aed82a93f75920980d2271ccfbd8c9b58cedcc361d *hp-plugin/hplip-3.19.12-plugin.run.asc
c0ed09635d2f4c371ac4f8dcbb643d6ca1cd4a4fe1302ef82f2bb9ac2870784b *hp-plugin/hplip-3.22.6-plugin.run.asc
88959c938a67852ad3e7daaa2426cb017028f6a4c335ca19bcdc10642ae5cda3 *hp-plugin/hplip-3.18.9-plugin.run.asc
afc3e841015f8dd1cac923c2170b4347c4e5eafe446a0f605e9040a7ab0217d4 *hp-plugin/hplip-3.20.11-plugin.run
98bba5ce2ca8d632526342cc28688e9238c156bbf4e793cf7b81c04980f6afac *hp-plugin/hplip-3.19.6-plugin.run
925b7dd490bf747f4f491383d224d423d8ed0ec9f4ea13d13ad9a97a67317048 *hp-plugin/hplip-3.19.10-plugin.run.asc
97b637f704f02579e012bc205d310ca1bb8602a21db181ed50144b3c83723910 *hp-plugin/hplip-3.18.12-plugin.run.asc
84a0dc385083ffc9acd66d3ab9a22a9a0943b9f6ed7db8e406682f6bc7f642a6 *hp-plugin/hplip-3.18.12-plugin.run
62cb6e71e474f07687089df5679b49d71bfcc041e781783f87cb14f808b77c2c *hp-plugin/hplip-3.19.5-plugin.run
4de5b3d426d1363c0519bef55dcd2481396252389332b4eb25bc5baefce30a83 *hp-plugin/hplip-3.18.10-plugin.run.asc
fed1958aff3cc4b29424767bda7e131788d2663afaa0723193fbef2002f43865 *hp-plugin/hplip-3.19.5-plugin.run.asc
EOF
  fi
  if test ! -e hp-plugin.sha256sum.sha256sum ; then
   echo "6c99fc36f4eb4bbebc7df329493a0eed60ef148effb5733374afe33ca50e4d8a *hp-plugin.sha256sum" > hp-plugin.sha256sum.sha256sum
  fi
  user-zvC9-sync
  
  mkdir -p hp-plugin
  pushd hp-plugin || user-zvC9-error  13 "can't cd into hp-plugin download folder"
   wget --no-clobber --input-file ../hp-plugin.URLs.txt
   user-zvC9-sync
  popd
  if LC_ALL=C sha256sum -c *.sha256sum ; then
   echo "  All checksums OK"
  else
   echo "  Checksums verification error!"
  fi
  sleep 5
 popd
 
	# wget -O /root/downloads/pixman-0.40.0.tar.gz.sha512  https://www.cairographics.org/releases/pixman-0.40.0.tar.gz.sha512
}


function zvC9-download-deb-packages-with-apt () { # must be run after dist-upgrade
 ## /var/cache/apt/archives/ and /var/cache/apt/saved-by-zvC9/archives/
 ## must be on same filesystem (for hardlinking with "cp -l")
 
 mkdir --mode 0755 -v --parents /var/cache/apt/saved-by-zvC9
 mkdir --mode 0755 -v --parents /var/cache/apt/saved-by-zvC9/archives
 chmod -c 0755 /var/cache/apt/saved-by-zvC9
 chmod -c 0755 /var/cache/apt/saved-by-zvC9/archives
 cp -nlv /var/cache/apt/archives/*.deb /var/cache/apt/saved-by-zvC9/archives/
 cp -nlv /var/cache/apt/archives/*.rpm /var/cache/apt/saved-by-zvC9/archives/
 apt clean
 apt-get clean
 rm -fv /var/cache/apt/archives/*.deb
 rm -fv /var/cache/apt/archives/*.rpm
 cp -lvn /var/cache/apt/saved-by-zvC9/archives/*.deb /var/cache/apt/archives/
 cp -lvn /var/cache/apt/saved-by-zvC9/archives/*.rpm /var/cache/apt/archives/
 user-zvC9-sync
  

for apt_add_args in "--no-install-recommends" "" "--install-suggests" "--no-install-recommends --install-suggests" ; do
 apt-get --download-only --yes $apt_add_args reinstall $apt_recommended_install_pkg_list || user-zvC9-error  22 "apt-get download recommended pkgs"
 apt-get --download-only --yes $apt_add_args reinstall $apt_suggested_install_pkg_list   || user-zvC9-error  23 "apt-get download suggested   pkgs"
 
	apt-get --download-only --yes $apt_add_args reinstall $apt_pkglist_01   || user-zvC9-error  6 "apt-get download pkgs 01"
	apt-get --download-only --yes $apt_add_args reinstall $apt_pkglist_02   || user-zvC9-error  7 "apt-get download pkgs 02"
	apt-get --download-only --yes $apt_add_args reinstall $apt_pkglist_03   || user-zvC9-error  8 "apt-get download pkgs 03"
	apt-get --download-only --yes $apt_add_args reinstall $apt_pkglist_04   || user-zvC9-error  9 "apt-get download pkgs 04"
	apt-get --download-only --yes $apt_add_args reinstall $apt_pkglist_05   || user-zvC9-error 10 "apt-get download pkgs 05"
	#apt-get --download-only --yes --install-suggests reinstall $apt_pkglist_06   || user-zvC9-error 19 "apt-get download pkgs 06"
	apt-get --download-only --yes $apt_add_args reinstall $apt_pkglist_07   || user-zvC9-error 24 "apt-get download pkgs 07"
	apt-get --download-only --yes $apt_add_args reinstall $apt_pkglist_08   || user-zvC9-error 25 "apt-get download pkgs 08"
	
 apt-get --download-only --yes  dist-upgrade $apt_add_args || user-zvC9-error  25 "apt-get download for dist-upgrade"
 
 apt-get --download-only --yes $apt_add_args reinstall $(apt-mark showinstall)  || user-zvC9-error 11 "apt-get download pkgs (installed)"
 
 apt-get --download-only --yes $apt_add_args reinstall $apt_suggested_icon_themes   || user-zvC9-error  30 "apt-get download suggested  icon themes (packages)"
done
#	umask 7022
 mkdir --mode 0755 -v --parents /var/cache/apt/saved-by-zvC9
 mkdir --mode 0755 -v --parents /var/cache/apt/saved-by-zvC9/archives
 chmod -c 0755 /var/cache/apt/saved-by-zvC9
 chmod -c 0755 /var/cache/apt/saved-by-zvC9/archives
# chmod -c 0755 /var/cache/apt/saved-by-zvC9/archives
 cp -nlv /var/cache/apt/archives/*.deb /var/cache/apt/saved-by-zvC9/archives/
 cp -nlv /var/cache/apt/archives/*.rpm /var/cache/apt/saved-by-zvC9/archives/
 rm -fv /var/cache/apt/saved-by-zvC9/pkgcache.bin
 rm -fv /var/cache/apt/saved-by-zvC9/srcpkgcache.bin
 cp -v /var/cache/apt/pkgcache.bin  /var/cache/apt/saved-by-zvC9/pkgcache.bin
 cp -v /var/cache/apt/srcpkgcache.bin  /var/cache/apt/saved-by-zvC9/srcpkgcache.bin
 user-zvC9-sync
 echo -e "DONE trying to save /var/cache/apt/archives/... and pkgcache.bin, srcpkgcache.bin"
 sleep 5
	rm -rfv /var/cache/apt-saved-by-zvC9
	mkdir -p --mode 0755 /var/lib/saved-by-zvC9
	chmod -c 0755 /var/lib/saved-by-zvC9
	pushd /var/lib/saved-by-zvC9 || user-zvC9-error  26 "can't pushd into /var/lib/saved-by-zvC9"
	 rm -rf apt.zvC9.autosave.old
	 mv -iv apt.zvC9.autosave apt.zvC9.autosave.old
	 rm -rf apt.zvC9.autosave
	 mkdir --mode 0755 apt.zvC9.autosave || user-zvC9-error  27 "can't mkdir --mode 0755 apt.zvC9.autosave"
	 chmod -c 0755 apt.zvC9.autosave
	 rsync -aH ../apt ./apt.zvC9.autosave/
	 user-zvC9-sync
	 rm -rf apt.zvC9.autosave.old
	 user-zvC9-sync
	popd
 echo -e "DONE trying to save /var/lib/apt"
 echo It\'s recommended to manually rename saved folder \(\"/var/lib/saved-by-zvC9/apt.zvC9.autosave\"\)
 echo to prevent it from being deleted on next run of script \"$0\".
 
 echo "Press Enter (nazhmite Enter) (HA*MuTE Enter)"
 read
#	chmod -c 0755 /var/cache/apt-saved-by-zvC9
#	cp - -nrlv /var/cache/apt /var/cache/apt-saved-by-zvC9/
	# pkgcache.bin srcpkgcache.bin
#	cp -nrlv /var/cache/apt/archives/*.rpm /var/cache/apt/archives-saved-by-zvC9/
	
	
	#/var/cache/apt/archives
}

function zvC9-dist-upgrade-with-apt-or-mintupdate-cli () {
 apt-get --download-only --yes --install-suggests dist-upgrade
 user-zvC9-sync
 if user-zvC9-isMint || user-zvC9-isLMDE ; then
  zvC9-user-confirms-continue-or-exit
  
	 mintupdate-cli upgrade || user-zvC9-error 1 mintupdate-cli upgrade
	 user-zvC9-sync
	 #zvC9-user-confirms-continue-or-exit
	 
	 apt update || user-zvC9-error 1 update
	 apt-get --download-only --yes --install-suggests dist-upgrade
	 user-zvC9-sync
	 zvC9-user-confirms-continue-or-exit
	 
	 mintupdate-cli upgrade || user-zvC9-error 1 mintupdate-cli upgrade
	 user-zvC9-sync
	 #zvC9-user-confirms-continue-or-exit
 else
  zvC9-user-confirms-continue-or-exit
  
	 apt dist-upgrade || user-zvC9-error 1 dist-upgrade
	 user-zvC9-sync
	 #zvC9-user-confirms-continue-or-exit
 fi
}

function zvC9-define-package-lists () {
	## also: gocryptfs sirikali zulumount-gui zulumount-gui
	## pkg: ipip?
	## find duplicates:
	## fdupes, findup, jdupes, rdfind
	
	if user-zvC9-isMint; then
		 mint_packages="mint-meta-xfce mint-meta-codecs"
 	else
 		 if user-zvC9-isLMDE ; then
			 mint_packages="mint-meta-codecs"
		 else
		 	  mint_packages=""
		  fi
	 fi
	
	
	
 # chromium-l10n  firefox-esr-l10n-ru 
 # epiphany-browser (does not allow to disable javaScript)
 # kodi (not needed)
 # epiphany-browser kodi
 apt_recommended_install_pkg_list="htop vlock pwgen screen mc calc build-essential xorriso xfburn brasero genisoimage k3b k3b-i18n \
 growisofs dvdbackup dvd+rw-tools cdw cdrkit-doc wodim \
 isolinux syslinux syslinux-utils syslinux-efi extlinux \
 hplip hplip-doc hplip-gui \
 compiz compiz-mate compiz-plugins-default compiz-plugins-extra compiz-plugins-main compizconfig-settings-manager compiz-gnome compiz-core  \
 emerald emerald-themes \
 simple-ccsm fusion-icon compiz-plugins-experimental \
 acetoneiso fuseiso iat mdf2iso \
 gnome-system-tools \
 cpuid tree catfish di  \
 acetoneiso mdf2iso iat fuseiso  \
 bash bash-doc bash-completion \
 chromium  dillo falkon  hv3 konqueror luakit midori netrik netsurf-gtk \
 qutebrowser qutebrowser-qtwebengine qutebrowser-qtwebkit surf w3m w3m-img \
 firefox-esr   \
 surfraw \
 thunderbird thunderbird-l10n-ru \
 dov4l fswebcam megapixels qv4l2 ustreamer  v4l-conf v4l-utils vgrabbj yavta motion \
 isenkram \
 adwaita-icon-theme adwaita-qt \
 wikipedia2text \
 xpad \
 fonts-dejavu fonts-dejavu-extra \
 password-gorilla \
 king \
 when \
 quotatool \
 yudit yudit-doc zim vis pluma-doc nedit ne ne-doc nano-tiny mle \
 adapta-gtk-theme arc-theme blackbird-gtk-theme bluebird-gtk-theme breeze-gtk-theme darkblood-gtk-theme greybird-gtk-theme \
 darkcold-gtk-theme darkfire-gtk-theme darkmint-gtk-theme materia-gtk-theme numix-gtk-theme  \
 breeze-cursor-theme chameleon-cursor-theme dmz-cursor-theme xcursor-themes  \
 gnome-themes-extra mate-themes \
 gnome-accessibility-themes gnome-theme-gilouche  \
 gtk-chtheme gtk-theme-switch  \
 metacity-themes xfwm4-theme-breeze \
 pidgin-themes \
 plymouth-themes plymouth-theme-hamara plymouth-theme-breeze  \
 abiword abw2odt abw2epub gnumeric gnumeric-doc gnucash gnucash-docs \
 evolution glabels dia dia-shapes dia-rib-network dia2code  \
 grisbi skrooge ofxstatement ofxstatement-plugins  \
 calligra calligra-l10n-ru calligraplan calligrasheets calligrastage calligrawords \
 krita krita-gmic krita-l10n  karbon kexi kexi-mysql-driver kexi-postgresql-driver  \
 evolvotron \
 step tulip  \
 dnsdiag  \
 kdialog  \
 pmount libvirt-clients libvirt-daemon libvirt-daemon-driver-qemu libvirt-daemon-system libvirt-daemon-system-systemd \
 gir1.2-spiceclientglib-2.0 gir1.2-spiceclientgtk-3.0 remmina-plugin-spice spice-client-glib-usb-acl-helper spice-client-gtk \
 virt-manager virt-viewer \
 quota quotatool jfsutils parted fstransform reiser4progs reiserfsprogs gpart btrfs-progs timeshift \
 whois iputils-tracepath bind9-dnsutils bind9-host iputils-tracepath mtr-tiny apt-file \
 mate-terminal task-mate-desktop task-cinnamon-desktop  \
 geeqie gimp gimp-help-en  gimp-help-ru bpytop  aha \
 filezilla gftp gftp-gtk gftp-text sshfs 4pane jftp  \
 cinnamon-screensaver gscan2pdf gimagereader lios ocrmypdf ocrmypdf-doc tesseract-ocr tesseract-ocr-eng tesseract-ocr-rus yagf \
 kylin-scanner xsane sane sane-utils simple-scan  \
 directvnc gvncviewer ssvnc tigervnc-viewer xtightvncviewer  \
 kazam simplescreenrecorder recordmydesktop celluloid vlc obs-studio vokoscreen peek x264 vlc-plugin-* vlc-l10n \
 x265 ffmpeg ffmpeg-doc kmplayer mystiq qmmp qwinff silan slowmovideo winff winff-doc winff-gtk2 winff-qt yuview \
 djview4 djvubind djvulibre-bin djvulibre-desktop djvuserve gscan2pdf k2pdfopt minidjvu pdf2djvu pct-scanner-scripts \
 qpdfview qpdfview-djvu-plugin qpdfview-pdf-poppler-plugin zathura-djvu zathura zathura-pdf-poppler zathura-ps zathura-cb \
 bino aview  \
 thunderbird thunderbird-l10n-ru valgrind nemiver kcachegrind heaptrack heaptrack-gui cgdb gdb gdb-doc leaktracer xxgdb  \
 remmina remmina-plugin-rdp remmina-plugin-secret remmina-plugin-spice remmina-plugin-vnc remmina-plugin-xdmcp remmina-plugin-nx \
 kmplot keepass2 keepass2-doc keepassx keepassxc kpcli gnome-passwordsafe seahorse caja-seahorse  seahorse-nautilus \
  passwordmaker-cli pcmanfm nss-passwords uget kget kgpg xfe vfu youtube-dl yt-dlp cclive ffcvt gcap haruna minitube \
 quvi searx shotwell smtube webvtt ytcc handbrake handbrake-cli totem  gnome-music mkvtoolnix mkvtoolnix-gui \
 xserver-xorg-core  \
 diffoscope p7zip-full remaster-iso squashfs-tools squashfs-tools-ng squashfuse arc archivemount fuse-zip krusader  \
 img2pdf python3-img2pdf graphicsmagick groff imagemagick imagemagick-doc imgsizer worker wv autoconf autoproject \
 autoconf-doc ktorrent m4 mdetect pyconfigure  pkg-config automake acr autotools-dev mate-common libtool libtool-doc \
 cross-config debmake-doc libpcre3-dev pcregrep pcre2-utils zmk zmk-doc yelp-tools  mk-configure appstream-util \
 gawk gawk-doc gddrescue cpufrequtils enscript dpkg-awk jq jshon jigdo-file jigit mawk \
 cdrskin \
 dmidecode  \
 exuberant-ctags miller xml2 xmlstarlet vnlog txt2regex runawk pyp num-utils \
 g++ gcc gcc-doc net-tools iproute2 gparted smartmontools partitionmanager parted parted-doc fatresize gdisk fdisk kdf gpart \
  testdisk scalpel magicrescue extundelete  exfat-utils exfat-fuse disktype  e2fsprogs e2fsprogs-l10n \
 gnome-disk-utility zerofree array-info dmsetup dmraid dmeventd jdupes mdadm  hardlink fdupes findimagedupes duperemove \
 duff fldiff bsdiff ccdiff difference diffpdf diffuse diffutils diffutils-doc dirdiff docdiff dwdiff icdiff imediff \
 imediff2 kdiff3 kdiff3-doc xxdiff xmldiff wdiff wdiff-doc vbindiff uprightdiff tzdiff basez xscreensaver task-xfce-desktop \
 task-russian task-russian-desktop buildtorrent ctorrent ktorrent mktorrent qbittorrent rtorrent transmission transmission-cli \
 transmission-gtk transmission-qt deluge deluge-gtk deluge-console python3-pip openvpn network-manager-openvpn \
 network-manager-openvpn-gnome gnutls-bin gnutls-doc easy-rsa  ascii beav bcal bindechexascii bless bsdextrautils \
 cutecom minicom picocom dhex galculator gbase ghex hexchat hexcompare hexcurse  hexedit hexer hexyl holes ht \
 ipqalc nasm jeex kcalc le lfm ncurses-hexedit okteta xxd xxhash wxhexeditor wcalc vfu vbindiff uudeview \
 utf8gen uniutils uni2ascii ugrep tweak tthsum sipcalc shed    \
 gedit pluma mousepad featherpad featherpad-l10n geany \
 zstd nmap nmapsi4  ncat ndiff   gzip bzip2 bzip2-doc lbzip2 pbzip2 pixz xz-utils xzdec lzip clzip lziprecover minilzip pdlzip \
 plzip tarlz  xlunzip pdlzip lunzip \
 xzgv xzoom \
 xfce4 xfce4-*-plugin xfce4-appfinder xfce4-clipman xfce4-dict xfce4-notifyd xfce4-panel xfce4-power-manager \
 xfce4-screenshooter xfce4-session xfce4-settings xfce4-taskmanager xfce4-terminal xfwm4 xfdesktop4 lightdm \
 xarchiver file-roller squashfs-tools-ng   \
  grub-efi-amd64-bin grub-efi-amd64-signed \
 atril evince gman   xpdf xpaint  xournal xorg-docs xmlto xfig-doc xfig xfig-libs pstoedit potrace \
 kig fig2sxd figtoipe fig2ps fig2dev inkscape lyx kdenlive openshot openshot-doc openshot-qt openshot-qt-doc flowblade shotcut \
 dragonplayer gaupol gmerlin gnome-subtitles gst123 haruna imageindex kaffeine kmplayer kylin-video mplayer mplayer-doc  \
 mpv ogmrip ogmrip-doc ogmrip-plugins qmmp smplayer smplayer-l10n subtitlecomposer subtitleeditor xjadeo xine-ui xine-console \
 parole melt media-player-info juk gmerlin cmus beets beets-doc audacious \
 android-file-transfer scrcpy adb fastboot mkbootimg aqemu imvirt ipxe-qemu qemu qemu-system-gui qemu-system-x86 qemu-utils \
  highlight gucharmap libc-bin usvg tgif \
 libreoffice-calc libreoffice-dmaths libreoffice-draw libreoffice-help-en-us libreoffice-help-ru libreoffice-impress libreoffice-l10n-ru \
 libreoffice-math libreoffice-texmaths libreoffice-writer libreoffice-writer2latex libreoffice-writer2xhtml  \
 guvcview uvccapture svgtune sdf scribus scribus-doc rst2pdf retext  rednotebook recoll qpdf pympress pympress-doc purifyeps \
 pstoedit  \
 pqiv potrace posterazor pod2pdf pdftoipe pdftk-java pdfshuffler pdfsandwich pdfsam pdfproctools pdfposter pdfmod pdfgrep \
 pdfcube pdfchain pdfarranger pdf2svg pdf2djvu  pdf-presenter-console pct-scanner-scripts paperwork-gtk pandoc \
 okular okular-backend-odp okular-backend-odt ocrmypdf ocrmypdf-doc  \
 a2ps  \
 zegrapher zathura-pdf-poppler xapers wv wkhtmltopdf weasyprint veusz unpaper unoconv umlet ugrep trydiffoscope \
 doxygen doxygen-doc doxygen-gui doxygen-latex doxygen2man html2ps xhtml2ps xloadimage \
 xli phototonic gwenview mirage geeqie  pqiv qimgv qiv shotwell showfoto sxiv viewnior xsddiagram \
 ninja-build generate-ninja bluefish bluefish-plugins indent indent-doc meson  \
 magicrescue \
 ovmf \
 pidgin gajim \
 gddrescue ddrutility ddrescueview myrescue safecopy audacity kwave flac flake kid3 kid3-cli kid3-qt moc mkcue lltag loudgain mp3diags \
 mussort opencubicplayer puddletag pacpl quodlibet rename-flac ripit ripperx timidity vorbis-tools xcfa xmms2-plugin-flac abcde asunder \
 btag cmus clementine crip dir2ogg easytag entagged exfalso extract lame lame-doc \
 elisa gmtp goobox knowthelist mikmod mtp-tools ncmpc playmidi pragha randomplay rhythmbox rhythmbox-doc rhythmbox-plugins strawberry \
 autokey-gtk autokey-qt mediainfo-gui mediainfo  \
 powertop  \
 patool detox fotoxx qtox toxcore-utils utox xmlto cairosvg calibre ccd2iso cdr2odg chafa chalow convmv csvkit cue2toc cuetools \
 dos2unix docx2txt e2ps ebook2odt enca epub-utils fbi fbterm fig2sxd fh2odg flip gnupg-utils ipv6calc lookup mapcode markdown pdf2svg \
 pdf2djvu ps2eps pskc-utils pstoedit pub2odg vim vim-doc vim-gtk3 tmux \
 atftp aria2 axel curl curlftpfs snarf tftp tnftp wget wget2 wput xmlstarlet yafc pwget puf \
 edbrowse elinks elinks-doc ftp ftp-ssl ftp-upload ftpcopy ftpgrab ftpmirror lftp lynx  ncftp netrw netwox netwox-doc openssh-client \
 links links2  \
 hwinfo mkelfimage msr-tools sudo util-linux  \
 make-doc html2text \
 xfconf obs-plugins \
 initramfs-tools debian-kernel-handbook \
 gnomint gdebi openssl xmlcopyeditor util-linux netpbm \
 xvfb x11vnc xutils \
 apg traceroute \
 morla ghostwriter bvi bbe binutils binutils-doc x86dis nasm libstdc++-10-doc \
 aptitude-doc-ru aptitude-doc-en apt-doc  \
 qtqr qreator qrencode zbar-tools zbarcam-gtk zbarcam-qt zint zint-qt \
 ebook-speaker jodconverter \
 kraft lloconv loook mugshot openclipart-libreoffice openclipart openclipart-png openclipart-svg \
 libreoffice sd2epub sd2odf sent swish++ swish-e textdraw writer2latex writer2latex-manual \
 bitstormlite btcheck twatch  \
 rtorrent qbittorrent transmission-gtk \
 aspic potrace w3-recs \
  amule amule-utils amule-utils-gui ed2k-hash \
 rhash  gpick rawtherapee tcputils lshw-gtk \
 grub-pc "  # =="$apt_recommended_install_pkg_list"
 
 
 
 if user-zvC9-isSparkyLinux ; then
  apt_recommended_install_pkg_list="${apt_recommended_install_pkg_list} lightdm-settings "
	else
	 apt_recommended_install_pkg_list="${apt_recommended_install_pkg_list} firefox-l10n-en firefox-l10n-ru firefox uvcdynctrl btop nemo-seahorse \
	   duf xreader xournalpp remind-tools pix xed-doc mplayer-gui  "
	fi
 
 ## morla is pdf editor
 if user-zvC9-isMint || user-zvC9-isLMDE ; then
	 apt_recommended_install_pkg_list="${apt_recommended_install_pkg_list} mintdesktop mintlocale mintmenu mintstick mintupdate mint-themes mint-themes-legacy "
	fi
 
 apt_suggested_install_pkg_list="similarity-tester efitools efibootmgr efivar pesign sbsigntool network-manager-l2tp network-manager-l2tp-gnome"
 # note: pktstat, can use nethogs, don't use netwatch
 # weborf yaws htdig
 # excluded: 
 apt_suggested_icon_themes="adwaita-icon-theme breeze-icon-theme breeze-icon-theme-rcc deepin-icon-theme elementary-icon-theme elementary-xfce-icon-theme \
 faba-icon-theme faenza-icon-theme gnome-brave-icon-theme gnome-dust-icon-theme gnome-human-icon-theme gnome-icon-theme gnome-icon-theme-* \
 gnome-*-icon-theme hicolor-icon-theme human-icon-theme lxde-icon-theme mate-icon-theme moka-icon-theme numix-icon-theme \
 numix-icon-theme-circle obsidian-icon-theme oxygen-icon-theme paper-icon-theme papirus-icon-theme suru-icon-theme tangerine-icon-theme \
 tango-icon-theme"
 ### apt_suggested_gtk_themes=""
 # plymouth-x11 plymouth-*
 # doublecmd-gtk doublecmd-help-ru doublecmd-qt doublecmd-plugins
 # cyrus-pop3d dma solid-pop3d 
 # ooohg (maps for libreoffice)   os-autoinst 
 # NOTE: "python3-qrtools" <--> "high level library for reading and generating QR codes"
 # ure-java breaks something
 # for debian maintainers: ben
 # snek (python-like language for embedded systems)
 # wml: "off-line HTML generation toolkit"
 # ghi: for github
 # flashrom: for BIOS
 # fwupd-doc fwupd gnome-firmware
 # chromium chromium-l10n: they break something
	apt_pkglist_01=" grub-efi grub-efi-amd64 king httrack falkon dillo konqueror luakit midori netrik netsurf-gtk surfraw surf wikipedia2text webhttrack tor cog chromium certbot \
	epiphany-browser kodi \
	gedit-plugins darkstat minidlna man2html monit onionshare fail2ban  \
	 finger hw-probe iftop socket procinfo qemu-efi-aarch64 qemu-efi-arm ree  ipxe fwupd-doc fwupd gnome-firmware \
	 flashrom uhub ap-utils  kaddressbook klick kontact apf-firewall bruteforce-wallet freelan gnunet gnunet-gtk n2n  miniupnpd \
	  miniupnpd-nftables tcllib  dillo falkon filetea  w3-dtd-mathml metamath metamath-databases science-logic spass snowdrop \
	  texlive-science wml sbcl codeblocks geany-plugin-latex geany-plugin-debugger geany-plugin-commander idle kdevelop kdevelop-l10n \
	  qtcreator qtcreator-doc  zytrax ben bugz ghi hxtools kylin-burner lmms milkytracker multimedia-midi tcpick tcptrack timekpr-next \
	  tipp10 tutka  abi-tracker abi-monitor  auto-multiple-choice auto-multiple-choice-doc auto-multiple-choice-doc-pdf asterisk rclone \
	  translate-shell  gimp-cbmplugs gimp-data gimp-data-extras gimp-dds gimp-gap gimp-gluas gimp-gmic gimp-gutenprint gimp-help-common gimp-help-en gimp-help-ru gimp-lensfun gimp-plugin-registry gimp-texturize gtkam-gimp libgimp2.0-doc libgimp2.0-dev  lxqt lxqt-* task-lxqt-desktop sddm sddm-theme-debian-elarun task-english task-cyrillic task-cyrillic-desktop task-british-desktop  rmlint tpm-tools tpm-tools-pkcs11 opencryptoki pkcs11-data pkcs11-dump scute signtos simple-tpm-pk11 softhsm2 opensc opensc-pkcs11 openpace nss-plugin-pem nettle-bin apkverifier cackey coolkey gnupg-pkcs11-scd gnupg-pkcs11-scd-proxy  translate-toolkit translate-toolkit-doc ure wmhdplop  pidgin-sipe printemf printer-driver-cups-pdf  openmcdf office2003-schemas omegat ooo-thumbnailer lokalize kdegraphics kdemultimedia kdenetwork kdesdk kdeutils  education-desktop-xfce education-desktop-* bleachbit cewl ckeditor ckeditor3  wifi-qr  go-qrcode node-qrcode-generator npm opgpcard phpqrcode python3-pyqrcode python3-qrcode python3-qrencode python3-qrcodegen python3-qrtools python3-segno ant-doc xnee-doc  autogen-doc axiom-doc asterisk-doc gnome-boxes gnome-panel-control fluxbox kdocker yasm fonts-dejavu memtester aoeui  fte fte-* formiko focuswriter featherpad feathernotes emacs-gtk efte e3 dte  mle micro mg manuskript lpe levee ledit kwrite kate kimagemapeditor kakoune jupp juffed jove joe jeex jedit jed jaxe gnome-builder  scite sciteproj pageedit omegat nvi noblenote neovim neovim-qt nedit ne nano-tiny plume-creator  yudit xwpe xtrkcad xjed xemacs21 wordgrinder-x11 wordgrinder-ncurses vis vile treesheets tilde texworks texstudio tetradraw tea sublime-text sigil scite  grub2-splashimages  grub-splashimages cmospwd adjtimex bochsbios bochs bochs-* variety vtun axiom cadabra cadabra2 yacas xcas wxmaxima brotli refind multiboot memtest86 maxima maxima-doc ipgrab heaptrack heaptrack-gui f2c evtest eric dumpet duma dnswalk delve ddd ddd-doc debug-me debug-me-server d-feet dbus-tests  codeblocks clisp bustle bsh bsh-doc boogie apitrace apitrace-gui apktool fp-compiler fp-ide gdb-multiarch lazarus lazarus-ide lazarus-doc acmetool authprogs sshpass  tinysshd telnetd sshesame runoverssh thonny mu-editor mu-editor-doc mtd-utils  ahcpd xoscope xprintidle xrestop yasr ydotool ydotoold ylva xdotool xautomation wtype xserver-xspice xtrace xwayland yadifa xidle xautolock xtrlock xss-lock xsecurelock xscreensaver-gl xscreensaver-gl-extra usbguard weresync weresync-doc  adns-tools paraview paraview-doc emerald emerald-themes compiz compiz-gnome compiz-mate  grub-theme-* gfxboot-themes gfxboot multimedia-all glom glom-doc glom-utils kdemultimedia ukwm evolution-plugins* gnumeric-plugins-extra cflow cflow-doc cflow-l10n php-christianriesen-base32 zutils gnumeric durep abiword xorgxrdp rdesktop tiny-initramfs  klibc-utils wraplinux btrfsmaintenance mkdocs mkdocs-doc tightvnc-* tightvncserver vinagre vino vncsnapshot vtgrab websockify x11vnc x2vnc xpra xrdp  scanbd selektor surf surfraw thin trafficserver trojan htdig h2o gunicorn lighttpd lighttpd-mod-openssl micro-httpd mini-httpd nghttp2 nginx-full qweborf webfs yaws weborf mtd-utils ree smbios-utils vbetool vgabios nbtscan mkosi fancontrol gnu-efi  twoftpd  udfclient udpcast uftp vcheck webcam webcamd webdeploy webfs tftpd squid  squid-purge squidclient suricata tcpd    redir roger-router sendfile  owftpd patator pktstat ncrack ftp-proxy ftp-proxy-doc fail2ban debmirror faketime  dnsmasq doc-debian ap-utils avfs backup-manager chaosreader cruft cupt   sitecopy rush putty-tools putty-doc putty pterm  tuxcmd ncdc  tmate tcvt ftpsync ftpwatch git-ftp hydra hydra-gtk     l2tpns xl2tpd softether-* lemon lsh-utils flexc++ dvi2dvi dvi2ps dvipng dvisvgm debmake dh-make diploma bison  bison-doc bisonc++ bisonc++-doc  netsurf-gtk netsurf-fb toxic xcalib ant ant-doc  mpd qtcreator qtcreator-doc shim-signed refind fwupd-amd64-signed boxer blueprint-tools backupninja uefitool uefitool-cli codelite cmake-extras pdf-redact-tools pdfcrack ppdfilt sisu solvespace swish-e texworks writer2latex writer2latex-manual vde2 u-boot-qemu xmount seabios simple-cdd qemu-user proot audtty  gmerlin-encoders-* deepin-movie anacrolix-dms tea minidlna tor latex-make dpic psad xprobe doscan fierce p0f pnscan ponyprog ostinato packetsender tcpick sniffit xmaxima  \
	 mescc-tools jpnevulator hexec hashrat grabc gnuit chntpw fastd fastd-doc jailkit eurephia anytun sslh wireguard wireguard-tools \
	yasat  python-pip-whl openvpn-* \
	  rsyslog-gnutls rsyslog-doc rsyslog  \
	 spectrwm conspy  \
	 spiped pipsi latexdiff iputils-clockdiff diffmon confget checksecurity blkreplay blkreplay-examples fssync faucc flashrom inadyn systray-mdstat backupninja growlight \
	 agedu apache2-utils ardour zram-tools zulu* sleuthkit forensics-* forensics-all atm-tools clang hplip-doc hplip-gui \
	 original-awk sloccount simple-revision-control \
	 nautilus-extension-burner \
	 gitso gnome-remote-desktop guacd \
	 autocutsel avahi-ui-utils krdc krfb novnc pagekite  \
	 lnav  \
	 websocketd backupninja brasero-cdrkit burner-cdrkit cpufreqd \
	 forensics-extra qconf epix php-imagick python3-pythonmagick python3-wand facedetect rubber \
	 wand-doc ahcpd kbuild ftp-proxy  radvd emscripten ftjam jam makepp  \
	 fbi monit xserver-xorg-core netdiag htop vlock pwgen screen tmux mc gparted calc brasero xorriso \
	 k3b k3b-i18n geany gedit mousepad pluma basez \
	 djvubind pdf2djvu pct-scanner-scripts minidjvu gscan2pdf  \
	 atril evince vim aqemu qemu-system-gui qemu-utils qemu-system-x86 qemu-system-common qemu-system-data qemu-kvm \
	 fdupes perforate jdupes rdfind duff \
	 catfish kfind recoll pdfgrep lookup \
	 diskscan \
	 scalpel forensics-all testdisk forensics-extra  \
	 hexcurse bless  \
	 mkvtoolnix-gui mkvtoolnix \
	 cpufrequtils ovmf bridge-utils  \
	 tree zerofree \
	 kdiff3 kdiff3-doc kdiff3-qt iputils-clockdiff tkcvs imediff \
	 indent indent-doc \
	 timeshift time sed rfkill mugshot germinate console-setup catfish archivemount \
	 mate-calc galculator bc dc octave qalc   \
	 bash bash-completion bash-doc command-not-found  \
	 zstd p7zip-full rsync openssh-client sshfs  \
	 mercurial git git-man git-doc vim-doc vim nano libreoffice-writer libreoffice-draw libreoffice-calc \
	 libreoffice-impress libreoffice libreoffice-l10n-ru libreoffice-help-ru tweak  \
	 subversion diffutils-doc diffutils autopoint binutils \
	 autoconf automake libtool bison gdb gdb-doc gdbserver valgrind \
	 virt-manager virtinst   \
	 rhythmbox rhythmbox-doc \
	 isc-dhcp-server \
	 quota reiser4progs reiserfsprogs  msr-tools lvm2 jfsutils iotop hdparm e2fsprogs efibootmgr dmsetup  dmraid dkms btrfs-progs \
	 bubblewrap apt-utils f2fs-tools hwinfo gufw aptitude menulibre ifupdown exfat-fuse  ntfs-3g dosfstools  \
	 sane-utils blender dcraw dia djview4 djview3 dov4l dv4l  eom exif exiv2 gocr  goxel gpicview \
	 graphviz  gtkmorph gwenview handbrake-cli  icoutils inkscape  kolourpaint kruler ocrad \
	 xfig xfig-doc fig2dev fig2ps kig  \
	 latex2html latex2rtf latex2rtf-doc latexdiff latexdraw latexila latexmk \
	  latex-make latex-mk latexml \
	 texlive-base texlive-extra-utils texlive-font-utils texlive-fonts-extra texlive-fonts-recommended \
	  texlive-latex-base texlive-latex-base-doc texlive-latex-extra texlive-latex-recommended \
	 texlive-latex-recommended-doc texlive-pstricks \
	 texlive-lang-cyrillic texlive-lang-european texlive-lang-other texlive-latex-base texlive-latex-extra \
	 texlive-latex-recommended  \
	 ocrmypdf okular openscad pdf2svg pdfarranger pencil2d   photocollage photoflare \
	 phototonic pixelize pixmap png23d png2html pngmeta pqiv pstoedit qiv qosmic qpdfview rawtherapee renrot rgbpaint \
	 sane xsane scribus showfoto solvespace scantv streamer sxiv tesseract-ocr tesseract-ocr-eng \
	 tesseract-ocr-rus tgif tintii tpp ttv tupi tuxpaint unpaper uvccapture v4l-conf vamps vgrabbj viewnior \
	 wings3d x264 x265 xaos xfig  xine-console xine-ui xli xloadimage xmorph xpaint xzgv yagf yasw zbar-tools \
	 pdf2djvu pdf2svg img2pdf k2pdfopt pod2pdf rst2pdf wkhtmltopdf   \
	 iputils-arping iptables iproute2 iputils-ping iputils-tracepath isc-dhcp-client iw lftp net-tools mtr-tiny \
	 network-manager openvpn tcpdump telnet whois transmission-gtk wireless-regdb wireless-tools wpasupplicant \
	 nmap nmapsi4 hexchat ktorrent deluge qbittorrent nftables mktorrent ntp ntpdate putty-tools rtorrent traceroute \
	 wireshark wireshark-gtk wireshark-qt wireguard wireguard-tools tinyirc tcpstat tcptrace tcptraceroute  \
	 gimp gimp-help-ru geeqie xsane hplip-gui g++ gcc gcc-doc build-essential grub-efi-amd64 \
	 imagemagick imagemagick-doc kdenlive  shotcut flowblade simplescreenrecorder recordmydesktop kazam \
	 vokoscreen obs-studio peek vlc mplayer kmplayer kmplot smplayer  qmmp dragonplayer kaffeine pidgin gajim \
	 randomplay mpv \
	 kde-telepathy evolution thunderbird  qbittorrent transmission-gtk aptitude rtorrent mktorrent deluge kget \
	 ktorrent kgpg smbclient nmap nmapsi4 memtest86+   autoconf automake libtool ninja-build \
	 libtool-doc remmina \
	 remmina-plugin-xdmcp remmina-plugin-spice remmina-plugin-rdp remmina-plugin-vnc remmina-plugin-secret \
	 keepass2 \
	 keepass2-doc keepassx keepassxc gdisk fdisk gparted parted powertop nethogs genisoimage audacity flac \
	 xtightvncviewer x11vnc ssvnc \
	 tigervnc-viewer kwave lame lame-doc  ffmpeg ffmpeg-doc gdb hwinfo gddrescue x2vnc whois traceroute  tilda  \
	 adb scrcpy fastboot grub-efi-amd64 encfs ecryptfs-utils   \
	 parole ristretto pix apt-file git cmake cmake-doc cmake-qt-gui keyutils tomb seahorse \
	 cryptsetup cryptsetup-bin cryptsetup-initramfs  \
	 libpcre3-dev \
	 guvcview cutecom minicom simple-scan links links2 lynx xarchiver p7zip-full rsync file-roller \
	 gdebi lftp wget curl curlftpfs qtcreator catfish grep util-linux findutils binutils net-tools wireless-tools \
	 wpasupplicant hasciicam pdfarranger pdfchain pdfsam  pdftk gimagereader  \
	 tesseract-ocr-rus gscan2pdf quodlibet    ogmrip ogmrip-doc ogmrip-plugins \
	 winff handbrake gopchop dvdbackup mencoder  wodim devede videotrans dvdauthor \
	 \
	 dvd+rw-tools growisofs openvpn openssl squashfs-tools squashfs-tools-ng smartmontools sweeper xfce4-xkb-plugin \
	 procinfo syslinux-utils xscreensaver   \
	 nftables ftp openssh-client aria2 atftp filezilla ftp-ssl ftpcopy gftp gftp-gtk gftp-text inetutils-ftp jftp  \
	 wput  putty-tools ncftp tftp tnftp \
	 libvirt-clients libvirt-daemon-driver-qemu libvirt-daemon-driver-vbox libvirt-daemon-system \
	 libvirt-daemon-system-systemd libvirt-daemon libvirt-dbus libvirt-doc \
	 spice-client-gtk gir1.2-spiceclientglib-2.0 gir1.2-spiceclientgtk-3.0 \
	 debootstrap cdebootstrap debootstick multistrap grml-debootstrap mmdebstrap \
	 pbuilder vmdb2   \
	 rinse \
	 qemu-system-arm  \
	 sudo \
	 grub-efi-amd64-signed grub-efi-amd64 grub-efi-amd64-bin grub-efi-amd64-signed-template \
	 di-netboot-assistant \
	 $mint_packages"
	 
	 ##### not these:
	 ### texlive-lang-cjk latex-cjk-all
	 ###
	 
	 # rinse is for creation of RPM-based linux installations
	 
	 apt_pkglist_01_for_mint20_3="\
	  exfat-utils remmina-plugin-nx hugin enfuse xplayer openshot zftp \
	  gnuift hugin-tools xcftools florence pdfshuffler simpleburn acidrip \
	  xchat xorp \
      vnc-java enchant apt-dpkg-ref sks-ecc asterisk-opus \
	  ansible-doc"
	 
	 apt_pkglist_01_for_mint21="xcvt"
	 apt_pkglist_01_for_mint_20_3_and_21="qalculate-gtk kino pfsglview pfstmo pfstools pfsview sagcad sagcad-doc kopete virtualbox-qt \
	   virtualbox-guest-additions-iso h264enc xvidenc ogmrip-video-copy divxenc ripoff linuxvnc"
	 
	 if user-zvC9-isMint ; then
	  if zvC9-isMint-21 ; then
	   apt_pkglist_01="${apt_pkglist_01} ${apt_pkglist_01_for_mint21} ${apt_pkglist_01_for_mint_20_3_and_21}" # 21
	  else
	   apt_pkglist_01="${apt_pkglist_01} ${apt_pkglist_01_for_mint20_3} ${apt_pkglist_01_for_mint_20_3_and_21}"
	  fi
	 fi
	 
	 ### kodi is media player and home theatre 
   
  ### aide=static 
  #tigervnc-xorg-extension
	 
	 ### packages seeming to not be available on Mint 21:
	 ## exfat-utils remmina-plugin-nx hugin enfuse xplayer openshot zftp
	 ## gnuift hugin-tools xcftools florence pdfshuffler simpleburn acidrip 
	 ## xchat xorp
	 ## ansible-doc
     ### more:
     ## vnc-java enchant apt-dpkg-ref sks-ecc
     ## asterisk-opus
	 

	# this is for qemu 7.0.0, also need glib and pixman
	apt_pkglist_02="libpcre3-dev libsdl2-dev libsdl2-image-dev libgtk3.0-cil-dev python3-sphinx  libgnutls28-dev \
		       libusb-1.0-0-dev  \
		libvde-dev libvncserver-dev libvdeplug-dev libgtkmm-3.0-dev libusb-1.0-0-dev libcap-ng-dev \
		libattr1-dev python3-sphinx-rtd-theme libpcre3-dev gettext"

	apt_pkglist_03="samba"
 
 # 04 is download-only
 	apt_pkglist_04_only_mint="lxc-utils mz apt-venv"
 	  ## also, may be, these packages break something:
 	  #  systemctl systemd-container progress-linux-container progress-linux-container-server \
 	  #  podman openshift-imagebuilder \
	   #  lxctl lxc-tests lxc-templates lxc lxcfs anbox cadvisor buildah bubblewrap conmon containerd cppcheck cppcheck-gui \
	   #  docker.io docker-doc docker-clean
	   # bedtools bcron autokey-gtk autokey-qt autokey-common apper  \
    # bfs dwm dynare dynare-doc etm etm-qt gtimer cgroup-tools  cgroupfs-mount \
    # mom oomd systemd-oomd lxcfs collectd-core ghc ghc-doc kubernetes-client gosu  umoci \
	apt_pkglist_04="gamin  openssh-server remmina-plugin-vnc remmina-plugin-nx remmina-plugin-rdp remmina-plugin-secret \
          apache2 apache2-doc libapache2-mod-php php \
	  imvirt img2pdf \
	  php-xml php-mysql mariadb-server mariadb-client mysql-common \
	  gxmessage kdocker magnus menulibre mousepad network-manager-gnome package-update-indicator parole \
	  ristretto shared-mime-info task-xfce-desktop thunar-data thunar vala-sntray-plugin \
	  wbar xfburn xfce4 xfce4-*-plugin xfce4-panel xfce4-power-manager xfce4-screenshooter \
	  xfce4-session xfce4-settings xfce4-terminal xfce4-* xfconf xfdesktop4 xfdesktop4-data \
	  xfe xfwm4  \
	  caja caja-* mate-* \
	  task-xfce-desktop task-cyrillic-kde-desktop task-cinnamon-desktop task-gnome-flashback-desktop \
	  task-kde-desktop task-lxqt-desktop task-web-server tasksh task-cyrillic task-cyrillic-desktop \
	  task-desktop task-english task-gnome-desktop task-laptop task-lxde-desktop task-mate-desktop \
	  task-russian task-russian-desktop task-russian-kde-desktop task-ssh-server \
	  task-xfce-desktop tasksel tasksel-data taskwarrior mintsystem alttab ant ant-doc android-libbase \
	  ytnef-tools tini subuser steghide steghide-doc runc rheolef rheolef-doc \
	  pskc-utils pskctool \
	  memo \
	  libapache2-mod-php nginx nginx-full libnginx-mod-* \
	  apache2 apache2-doc apache2-utils \
	   samba sympathy isc-dhcp-server postgresql postgresql-client \
	  bind9 bind9-dnsutils bind9-utils bind9-host bind9-doc bsd-mailx postfix \
	  tftpd lxc  uget dovecot-imapd dovecot-pop3d dovecot-mysql dovecot-pgsql \
	  gocryptfs sirikali zulumount-gui zulumount-gui zulucrypt-cli zulucrypt-gui zulupolkit \
	  zulusafe-cli vtun sshpass seccure scrypt quicktun patator john openssh-sftp-server \
	  pssh ssh-tools sshesame gesftpserver lxc photopc autossh bing zssh zsync zurl xrdp \
	  xprobe  xorgxrdp  vtun vpnc vnstat vde2 tcpspy \
	  libvirt-daemon-driver-lxc libvirt-daemon-driver-storage-gluster libvirt-daemon-driver-storage-rbd \
	  libvirt-daemon-driver-storage-zfs libvirt-daemon-driver-xen libvirt-daemon-system-sysv \
	  spice-vdagent ansible  ansible-lint at novnc \
	  wireguard wireguard-dkms wireguard-tools tigervnc-xorg-extension hydra patator ncrack \
	  autocutsel gocryptfs sirikali zulumount-gui zulupolkit zulusafe-cli zulumount-cli \
	  zulucrypt-gui zulucrypt-cli cowpatty bruteforce-salted-openssl fcrackzip asterisk \
	  asterisk-doc asterisk-mp3 asterisk-mysql asterisk-ooh323 asterisk-modules \
	  asterisk-mobile  speex speex-doc sip-tester mumble-server mangler hashcat pidgin-sipe \
	  toxic obs-build hxtools epm tiger virt-manager virt-viewer vinagre tightvncserver ssvnc xtightvncviewer xrdp x2vnc aspell-en aspell aspell-doc aspell-ru git-gui xfce4-dict aide-common aide-dynamic  krfb krdc gvncviewer directvnc conspy chaosreader avahi-ui-utils remmina-plugin-secret remmina vino xpra  tightvnc-java websockify vtgrab vncsnapshot remmina-plugin-nx remmina-plugin-vnc remmina-plugin-secret remmina-plugin-rdp novnc jailkit gitso gem-plugin-vnc    acheck dictionaries-common hunspell-en-us hunspell-en-gb hunspell-ru hunspell myspell-ru aephea wordnet-gui wamerican-insane wbritish-insane irussian ibritish-insane iamerican-insane dictconv wbritish wamerican ispell irussian ibritish-insane iamerican-insane vifm vim-doc vim-common vim-addon-manager vim-gtk vim-gtk3 vim-gui-common vim-nox vim-scripts vim tmux tmux-themepack-jimeh tmuxp tmuxinator tmux-plugin-manager tmate tcvt iselect screenie byobu mate-utils clonezilla  fsarchiver normaliz normaliz-doc normaliz-bin partclone partimage par2 parchive apt-utils apt-build apt-cacher aptitude aptitude-doc-ru aptitude-doc-en aptfs apt-forktracer apt-file  apt-doc apt-dater apt-dater-host aptdaemon aptdaemon-data apt-cacher-ng  apt-listchanges apt-listdifferences aptly-api aptly-publisher aptly apt-mirror apt-move apt-offline-gui apt-offline apt-rdepends apt-show-source apt-show-versions apt-src apt-transport-https apt-transport-s3 apt-transport-tor apturl apturl-kde apturl-common apt-utils  apt-xapian-index apt apulse alsamixergui alsa-tools-gui alsa-utils amsynth ardour gmerlin gom hydrogen mate-media moc nama osspd osspd-pulseaudio pnmixer qasconfig qashctl qasmixer qastools-common quisk volumeicon-alsa ukui-media twinkle twinkle-console twinkle-common mumble krusader mmc-utils pkgdiff patool \
	  pinot extract xfe \
	  dc3dd dcfldd pass tigervnc-viewer tigervnc-standalone-server tigervnc-scraping-server tigervnc-common hashdeep gtkhash caja-gtkhash kodi tiemu \
	  ghex hexer beav hexedit hexcurse ht jeex  ncurses-hexedit nasm gnuit dhex  chntpw  okteta  ostinato shed wxhexeditor tweak  vfu \
	  num-utils stda kde-full boot-repair"
	# aide conflicts with aide-dynamic
	
	if user-zvC9-isMint ; then
	 apt_pkglist_04="${apt_pkglist_04} ${apt_pkglist_04_only_mint}"
	fi
	
	if user-zvC9-isMint || user-zvC9-isLMDE ; then
	 apt_pkglist_04="${apt_pkglist_04} mintbackup mint-common mintdesktop mintinstall mintlocale mintmenu mint-meta-cinnamon mint-meta-codecs mint-meta-core mint-mirrors mintsources mintstick mintsystem mint-translations mintupdate mint-upgrade-info mintupgrade mintupload mintwelcome"
	fi
	
	apt_pkglist_05="git"
	apt_pkglist_05_for_mint20_3="\
	  exfat-utils remmina-plugin-nx hugin enfuse xplayer openshot zftp \
	  gnuift hugin-tools xcftools florence pdfshuffler simpleburn acidrip \
	  xchat xorp \
      vnc-java enchant apt-dpkg-ref sks-ecc asterisk-opus \
	  ansible-doc virtualbox-ext-pack"
	 
	 if user-zvC9-isMint ; then
	  if zvC9-isMint-21 ; then
	   apt_pkglist_05="${apt_pkglist_05} virtualbox-ext-pack xcvt"
	  else
	   apt_pkglist_05="${apt_pkglist_05} $apt_pkglist_05_for_mint20_3"
	  fi
	 fi
	
	
	#apt_pkglist_07="exfatprogs pkgconf rdnssd bison++ atftpd squid-openssl ftpd ftpd-ssl proftpd-core proftpd-doc proftpd-mod-* pure-ftpd twoftpd-run vsftpd"
	#apt_pkglist_08="ftpd-ssl"
	
	# ftpd ftpd-ssl proftpd-core proftpd-doc proftpd-mod-* pure-ftpd twoftpd-run vsftpd ftpd-ssl
	apt_pkglist_07="exfatprogs pkgconf rdnssd bison++ atftpd"
	apt_pkglist_08="squid-openssl gnome-photos ui-auto dracut dracut-* mtr miniupnpd-iptables "
	
	## 06 is packages for lmde 5 live system (liveDVD/liveUSB)
	#apt_pkglist_06="boot-repair* boot-sav* boot-sav-extra* circle-flags-svg* glade2script* glade2script-python3* gparted* gparted-common* imagemagick* imagemagick-6-common* \
 #   imagemagick-6.q16* insserv* isoquery* libde265-0* libheif1* libilmbase25* libjxr-tools* libjxr0* liblqr-1-0* libmagickcore-6.q16-6* libmagickcore-6.q16-6-extra* \
 #   libmagickwand-6.q16-6* libnetpbm10* libopenexr25* libqt5designer5* libqt5help5* libqt5printsupport5* libqt5sql5* libqt5sql5-sqlite* libqt5test5* libqt5xml5* \
 #   libwmf0.2-7* live-boot* live-boot-doc* live-boot-initramfs-tools* live-config* live-config-doc* live-config-systemd* live-installer* live-tools* menu* \
 #   mint-live-session* netpbm* pastebinit* python3-pyqt5* python3-pyqt5.sip* startpar* syslinux-utils* sysv-rc*"

	#apt_pkglist_all="${apt_pkglist_01} ${apt_pkglist_02} ${apt_pkglist_03} ${apt_pkglist_04} ${apt_pkglist_05}"
	#apt-get --download-only --yes --install-suggests reinstall $apt_pkglist_all  || user-zvC9-error 6 "apt-get download all pkgs"
	
	## on LMDE:
	#E: Невозможно найти пакет qalculate-gtk
	#E: Для пакета «kino» не найден кандидат на установку
	#E: Для пакета «pfsglview» не найден кандидат на установку
	#E: Для пакета «pfstmo» не найден кандидат на установку
	#E: Для пакета «pfstools» не найден кандидат на установку
	#E: Для пакета «pfsview» не найден кандидат на установку
	#E: Невозможно найти пакет sagcad
	#E: Невозможно найти пакет sagcad-doc
	#E: Невозможно найти пакет kopete
	#E: Для пакета «virtualbox-qt» не найден кандидат на установку
	#E: Для пакета «h264enc» не найден кандидат на установку
	#E: Невозможно найти пакет xvidenc
	#E: Для пакета «ogmrip-video-copy» не найден кандидат на установку
	#E: Невозможно найти пакет divxenc
	#E: Невозможно найти пакет ripoff
	#E: Невозможно найти пакет linuxvnc
	#E: Невозможно найти пакет mint-meta-xfce
	
	
	## remmina plugins to include into main list:
	# remmina-plugin-xdmcp remmina-plugin-spice remmina-plugin-rdp remmina-plugin-vnc remmina-plugin-secret
	
	## next:
	#Чтение списков пакетов… Готово
	#Построение дерева зависимостей… Готово
	#Чтение информации о состоянии… Готово         
	#Заметьте, выбирается «remmina-plugin-xdmcp» для шаблона «remmina-plugin-*»
	#Заметьте, выбирается «remmina-plugin-spice» для шаблона «remmina-plugin-*»
	#Заметьте, выбирается «remmina-plugin-rdp» для шаблона «remmina-plugin-*»
	#Заметьте, выбирается «remmina-plugin-vnc» для шаблона «remmina-plugin-*»
	#Заметьте, выбирается «remmina-plugin-www» для шаблона «remmina-plugin-*»
	#Заметьте, выбирается «remmina-plugin-gnome» для шаблона «remmina-plugin-*»
	#Заметьте, выбирается «remmina-plugin-secret» для шаблона «remmina-plugin-*»
	#Заметьте, выбирается «remmina-plugin-kiosk» для шаблона «remmina-plugin-*»
	#Заметьте, выбирается «remmina-plugin-nx» для шаблона «remmina-plugin-*»
	#Заметьте, выбирается «remmina-plugin-exec» для шаблона «remmina-plugin-*»
	#Заметьте, выбирается «remmina-plugin-kwallet» для шаблона «remmina-plugin-*»
	#Пакет apt-venv недоступен, но упомянут в списке зависимостей другого
	#пакета. Это может означать, что пакет отсутствует, устарел или
	#доступен из источников, не упомянутых в sources.list
	#
	#E: Невозможно найти пакет lxc-utils
	#E: Невозможно найти пакет lxc-utils
	#E: Невозможно найти пакет mz
	#E: Для пакета «apt-venv» не найден кандидат на установку
	#Error (aborting): apt-get download pkgs
}

##deleted: zvC9-apt-postinstall-and-postupgrade
##deleted: user-zvC9-sync

function zvC9-linux-postinstall() {
 echo "    " WARNING! if you have problems with installing packages \(they are reported to not be possible to install by apt\), try editing or removing this file:
 echo "    -->" /etc/apt/preferences.d/zvC9.pref "<--    "
 echo "Press Enter (nazhmite Enter) (HA*MuTE Enter)"
 read

 zvC9-add_info_about_CtrlAltF7_to_etc_issue

 ##deleted: visudo
 ##deleted: user-zvC9-sync
 #zvC9-user-confirms-continue-or-exit

 dpkg-reconfigure keyboard-configuration
 user-zvC9-sync
 dpkg-reconfigure console-setup
 user-zvC9-sync
 update-alternatives --config iptables
 user-zvC9-sync
 #zvC9-user-confirms-continue-or-exit

 ##deleted: zvC9-adjust-etc-default-grub
 ##deleted: nano /etc/default/grub
 ##deleted: user-zvC9-sync
 ##deleted: zvC9-user-confirms-continue-or-exit

 ##deleted: update-grub || user-zvC9-error 6 "seems like grub config (/etc/default/grub) is wrong, you must edit it (and then you can run this script again)"
 ##deleted: user-zvC9-sync
 ##deleted: zvC9-user-confirms-continue-or-exit

 ##deleted: if user-zvC9-isMint || user-zvC9-isLMDE ; then
 ##deleted: 	mintsources
 ##deleted: 	user-zvC9-sync
 ##deleted: 	zvC9-adjust-etc-apt-sources.list.d
 ##deleted: 	user-zvC9-sync
 ##deleted: 	#zvC9-user-confirms-continue-or-exit
 ##deleted: fi

 ##deleted: apt update || user-zvC9-error 1 update
 ##deleted: user-zvC9-sync
 ##deleted: #zvC9-user-confirms-continue-or-exit



 ##deleted: zvC9-dist-upgrade-with-apt-or-mintupdate-cli
 ##deleted: zvC9-apt-postinstall-and-postupgrade
 ##deleted: user-zvC9-sync


 ##deleted: zvC9-define-package-lists ## !
 ##deleted: apt_pkglist="${apt_pkglist_05}"
 ##deleted: apt-get install $apt_pkglist 
 ##deleted: exitcode="$?"
 ##deleted: zvC9-apt-postinstall-and-postupgrade
 ##deleted: user-zvC9-sync
 ##deleted: if test "$exitcode" != "0" ; then
 ##deleted:  user-zvC9-error 2 "install 05"
 ##deleted: fi
 ##deleted: user-zvC9-sync
 ##deleted: zvC9-download-sources # sync done in this function
 ##deleted: zvC9-download-deb-packages-with-apt # sync done in this function

 ##deleted: zvC9-user-confirms-continue-or-exit


 apt install --no-install-recommends git
 exitcode="$?"
 ##zvC9-apt-postinstall-and-postupgrade
 user-zvC9-sync
 if test "$exitcode" != "0" ; then
  echo -n "failed to install git..."
  slee 5
  echo
 fi
 #user-zvC9-sync

 zvC9-define-package-lists
 zvC9-download-sources # sync done in this function
 zvC9-download-deb-packages-with-apt # sync done in this function


 #hp-plugin
 user-zvC9-sync


 mkdir -p ~root/zvC9
 fileName=~root/zvC9/zvC9_recommended_suggested_tweaks.bash
 if test ! -e $fileName ; then
  echo "creating $fileName (read and modify it, also it contains suggested manual modifications)"
  echo "#!/bin/bash" > $fileName
  
  echo -e \\n## READ \(AND EDIT\?\) WHOLE THIS SCRIPT BEFORE RUNNING IT >> $fileName
  
  echo -e \\n## recommended tweak \(disable ssh server and postfix and others\): >> $fileName
  echo  -en echo -en \"Package: \"  >> $fileName
  for i in "epiphany-browser*" "kodi*" zutils mariadb-server apache2-bin apache2 "durep" "openssh-server*"  "postfix*"  gnome-photos  \
      ui-auto "exim4*"  bsd-mailx  tracker-extract postgresql-13 ; do
   echo -en "\"$i\" \"$i\":i386  " >> $fileName
  done
  echo \> /etc/apt/preferences.d/zvC9.pref >> $fileName
  echo -en  echo -en \"\\\\\\\\nPin: release a=*\\\\\\\\nPin-Priority: -10\" \>\> /etc/apt/preferences.d/zvC9.pref \\n\\n >> $fileName
  #echo  \# echo -e \"Package: openssh-server\* openssh-server\*:i386 postfix\* postfix\*:i386\\\\nPin: release a=\*\\\\nPin-Priority: -10\" \> /etc/apt/preferences.d/nosshsrv_nopostfix.pref >> $fileName
  echo -e \\nsync \; sync >> $fileName
  
  echo -e \\n## recommended tweak \(purge\): >> $fileName
  echo -n apt purge "\"epiphany-browser*\"" "\"kodi*\"" zutils durep php-common php-christianriesen-base32 tracker-extract bsd-mailx ui-auto gnome-photos "\"postfix*\""  >> $fileName
  
  echo -e \\nsync \; sync >> $fileName

#  echo -e \\n## NOT recommended tweak: >> $fileName
#  echo \# if test "!" -e \~root/zvC9-su-pkexec-original-modes.txt \; then ls -la /bin/su /usr/bin/pkexec /usr/libexec/polkit-agent-helper-1 \> \~root/zvC9-su-pkexec-original-modes.txt \; groupadd --system wheel \;  chgrp -c wheel /bin/su /usr/bin/pkexec /usr/libexec/polkit-agent-helper-1 \; chmod -c 4110 /bin/su /usr/bin/pkexec /usr/libexec/polkit-agent-helper-1 \; fi >> $fileName
#  
#  echo -e \\nsync \; sync >> $fileName

  echo -e "\\n## recommended tweak: manually do this (code is not tested):" >> $fileName
  echo -e "#groupadd --system wheel ; gpasswd --add mint wheel ; chgrp -c wheel /bin/{su,sudo,pkexec} ; chmod -c 4110 /bin/{su,sudo,pkexec}" >> $fileName
  echo -e \#sync \; sync  >> $fileName
  
#  echo -e \\n## recommended tweak: >> $fileName
#  echo -e "groupadd --system wheel ; gpasswd --add mint wheel ; chgrp -c wheel /bin/{su,sudo,pkexec} ; chmod -c 4110 /bin/{su,sudo,pkexec}" >> $fileName
#  echo -e sync \; sync  >> $fileName

# code not complete
#  sed --in-place=.bak -E -e "s/\s*#\s*auth\s+required\s+pam_wheel.so\s*$//g" # finish this code
  
  #echo ""  >> $fileName
  echo -e "\\n## recommended tweak: manually do this (code is not tested):" >> $fileName
  echo "#if grep -E -e \"^\\\\s*auth\\\\s+required\\\\s+pam_wheel\\\\.so\\\\s*\\\$\" /etc/pam.d/su  ; then"  >> $fileName
  echo "# : # NOP, true"  >> $fileName
  echo "#else"  >> $fileName
  echo "# echo -e \"\\\\nauth       required   pam_wheel.so\\\\n\" >> /etc/pam.d/su"  >> $fileName
  echo "#fi"  >> $fileName
  echo -e \#sync \; sync  >> $fileName

  echo -e \\n## recommended tweak: >> $fileName
  echo \# \( manually comment out all lines in /etc/sudoers.d/mintupdate \) >> $fileName

  echo -e \\n## recommended tweak: >> $fileName
  echo \# \(uncomment in file /etc/pam.d/su this line: "\"auth       required   pam_wheel.so\"" \(should be done by this script\) \) >> $fileName
  
  echo -e \\n## recommended tweak: >> $fileName
  echo \# \(manually install virtualbox with ext-pack and hp-plugin from downloaded files\) >> $fileName
  
  echo -e \\n## recommended install: >> $fileName
  echo apt --no-install-recommends install $apt_recommended_install_pkg_list >> $fileName
  # echo \$\?=$?
  echo -e echo \\\\\$\\\\\?=\$\? >> $fileName
  echo sync \; sync >> $fileName
  # echo Press Enter \(nazhmite Enter\) \(HA\*MuTe Enter\)
  # echo Press Enter \\(nazhmite Enter\\) \\(HA\\*MuTe Enter\\)
  # echo Press Enter \\\\\(nazhmite Enter\\\\\) \\\\\(HA\\\\\*MuTe Enter\\\\\)
  echo -e echo Press Enter \\\\\(nazhmite Enter\\\\\) \\\\\(HA\\\\\*MuTe Enter\\\\\) >> $fileName
  echo -e read >> $fileName

  echo -e \\n## suggested install: >> $fileName
  echo -n \#apt --no-install-recommends install $apt_suggested_install_pkg_list >> $fileName
  echo -e \\n#sync \; sync >> $fileName
  
  echo -e \\n## suggested install \(icon themes\): >> $fileName
  echo -n \#apt --no-install-recommends install $apt_suggested_icon_themes >> $fileName
  echo -e \\n#sync \; sync >> $fileName
  
  
  echo -e \\n## recommended check/tweak \(note: editor, vncviewer\) >> $fileName
  echo -n update-alternatives --all >> $fileName
  echo -e \\nsync \; sync >> $fileName
 else
  echo "skipping creation of $fileName (it exists) (read and modify it, also it contains suggested manual modifications)"
 fi

 exit 0
}

## call main function:
zvC9-linux-postinstall

function zvC9-not-called-func() {
#deleted: apt_pkglist="${apt_pkglist_01}"
#deleted:  #apt-get --download-only --yes --no-install-recommends install $apt_pkglist  || user-zvC9-error 2 "install 1 --download-only"
#deleted:  #user-zvC9-sync
#deleted:  #zvC9-user-confirms-continue-or-exit
#deleted: 
#deleted:  apt --no-install-recommends install $apt_pkglist 
#deleted:  exitcode="$?"
#deleted:  zvC9-apt-postinstall-and-postupgrade
#deleted:  user-zvC9-sync
#deleted:  if test "$exitcode" != "0" ; then
#deleted:   user-zvC9-error 2 "install 1"
#deleted:  fi
#deleted:  #user-zvC9-sync
#deleted:  zvC9-apt-postinstall-and-postupgrade
#deleted:  user-zvC9-sync
#deleted:  #systemctl  disable NetworkManager-wait-online.service
#deleted:  #systemctl  disable network-online.target
#deleted:  #user-zvC9-sync
#deleted:  zvC9-user-confirms-continue-or-exit
#deleted: 
#deleted:  # for apt-file:
#deleted:  apt update || user-zvC9-error 2 "apt update for apt-file"
#deleted:  user-zvC9-sync
#deleted:  zvC9-user-confirms-continue-or-exit
#deleted: 
#deleted: 
#deleted:  #apt purge bsd-mailx postfix (recommended packages, they are now ignored (--no-install-recommends))
#deleted:  #user-zvC9-sync
#deleted: 
#deleted:  # this is for qemu 7.0.0, also need glib and pixman
#deleted: 
#deleted:  apt_pkglist="${apt_pkglist_02}"
#deleted:  #apt-get --download-only --yes install $apt_pkglist  || user-zvC9-error 3 "install 2 --download-only"
#deleted:  #user-zvC9-sync
#deleted:  #zvC9-user-confirms-continue-or-exit
#deleted: 
#deleted:  apt  install $apt_pkglist 
#deleted:  exitcode="$?"
#deleted:  zvC9-apt-postinstall-and-postupgrade
#deleted:  user-zvC9-sync
#deleted:  if test "$exitcode" != "0" ; then
#deleted:   user-zvC9-error 3 "install 2"
#deleted:  fi
#deleted:  #user-zvC9-sync
#deleted:  #zvC9-user-confirms-continue-or-exit
#deleted: 
#deleted:  update-alternatives --config iptables
#deleted:  user-zvC9-sync
#deleted:  zvC9-user-confirms-continue-or-exit
#deleted: 
#deleted: 
#deleted: 
#deleted: 
#deleted:  apt_pkglist="${apt_pkglist_03}"
#deleted:  #apt-get --download-only --yes install $apt_pkglist  || user-zvC9-error 3 "install 3 --download-only"
#deleted:  #user-zvC9-sync
#deleted:  #zvC9-user-confirms-continue-or-exit
#deleted:  apt install $apt_pkglist
#deleted:  exitcode="$?"
#deleted:  zvC9-apt-postinstall-and-postupgrade
#deleted:  user-zvC9-sync
#deleted:  if test "$exitcode" != "0" ; then
#deleted:   user-zvC9-error 4 "install 3"
#deleted:  fi
#deleted: 
#deleted:   #zvC9-user-confirms-continue-or-exit
#deleted: 
#deleted: 
#deleted: 
#deleted: 
#deleted:   
#deleted:  # apt install ansible libopenusb-dev python3-sphinx-bootstrap-theme
#deleted: 
#deleted:  # download sources
#deleted: 
#deleted: 
#deleted: 
#deleted:  #apt_pkglist="${apt_pkglist_04}"
#deleted:  #apt-get --download-only --yes install $apt_pkglist  || user-zvC9-error 5 "apt-get --download-only"
#deleted:  #user-zvC9-sync
#deleted:  zvC9-user-confirms-continue-or-exit
#deleted: 
#deleted: 
#deleted:  hp-plugin || user-zvC9-error 8 "hp-plugin"
#deleted:  user-zvC9-sync
#deleted: 
#deleted:  zvC9-download-deb-packages-with-apt || user-zvC9-error 20 "2nd apt download"
#deleted: 
#deleted: 
#deleted:  echo -e "\\n\\ndone, success"
#deleted:
}

exit 0

