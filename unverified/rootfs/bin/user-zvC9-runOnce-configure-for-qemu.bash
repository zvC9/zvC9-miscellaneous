#!/bin/bash


# configuration
prefix="zvC9-"
VMName="testVM"
RAM_MB="2048"
VM_UUID="88888888-4444-4444-4444-cccccccccccc"
virtio_vga_max_hostmem="67108864" # 64 MiB
VM_VGA="virtio"
cpu_count="2"
main_hdd_size_GiB="24"
swap_hdd_size_GiB="5"
## VGAs:
##none                 no graphic card
##std                  standard VGA (default)
##cirrus               Cirrus VGA
##vmware               VMWare SVGA
##xenfb                Xen paravirtualized framebuffer
##qxl                  QXL VGA
##virtio               Virtio VGA

# can skip next lines (don't read next, vars are set before this)




#echo "converting vmdk to qcow2..."
#qemu-img convert -p -f vmdk -O qcow2 1.vmdk  ${prefix}base.qcow2
#chmod   -c 0440 ${prefix}base.qcow2
#sync ; sync
#echo "created image base (converted from vmdk to qcow2)"

rm -fv ${prefix}base.qcow2
rm -fv ${prefix}swap.qcow2

qemu-img create -f qcow2 ${prefix}base.qcow2 ${main_hdd_size_GiB}g
qemu-img create -f qcow2 ${prefix}swap.qcow2 ${swap_hdd_size_GiB}g

echo "created base, swap qcow2 files"

mkdir -p Snapshots
pushd Snapshots || exit 1

echo -n "creating script ${prefix}mk_current_state.bash…"
cat > ${prefix}mk_current_state.bash <<EOF
#!/bin/bash

i="\$(ls ??????-*.qcow2 | grep -P "\\\\d{6}-.*\\\\.qcow2" | sort | tail -n 1)"
rm -fv current_state.qcow2
if [ "x\$i" = "x" ] ; then
        echo not found snapshot, creating 000000 backed to base. And current_state backed to 000000
        qemu-img create -f qcow2 -b ../${prefix}base.qcow2 -F qcow2 000000-base.qcow2
        qemu-img create -f qcow2 -b 000000-base.qcow2 -F qcow2 current_state.qcow2
else
        echo found "\"\$i\""
        qemu-img create -f qcow2 -b "\$i" -F qcow2 current_state.qcow2
fi
EOF

chmod -c 0555 ${prefix}mk_current_state.bash
# for the case we are on a filesystem mounted with noexec option (execute script as program will not work, use bash explicitly)
bash ./${prefix}mk_current_state.bash

echo created and run script


popd || exit 2

qemu_launchers_dir="qemu-launchers"
mkdir -p "$qemu_launchers_dir"
pushd "$qemu_launchers_dir" || exit 3

function zvC9-build_launcher_name () { # used (here) VARs must be already set
 script_name="${prefix}run-qemu-"
 
 if test "$kvm" = yes ; then
  script_name="${script_name}KVM_on-"
 else
  script_name="${script_name}KVM_off-"
 fi
 if test "$network" = yes ; then
  script_name="${script_name}network_on-"
 else
  script_name="${script_name}network_off-"
 fi
 if test "$cdrom" = yes ; then
  script_name="${script_name}cdrom_on-"
 else
  script_name="${script_name}cdrom_off-"
 fi
 if test "$uefi" = yes ; then
  script_name="${script_name}UEFI_on-"
 else
  script_name="${script_name}UEFI_off-"
 fi
 
 if test "$libgl_always_software" = "yes" ; then
  script_name="${script_name}LIBGL_ALWAYS_SOFTWARE_on-"
 else
  script_name="${script_name}LIBGL_ALWAYS_SOFTWARE_off-"
 fi
 
 if test "$enable_virgl_and_display_gl" = "yes" ; then
  script_name="${script_name}virtual_VGA_3d_acceleration_on-"
 else
  script_name="${script_name}virtual_VGA_3d_acceleration_off-"
 fi
 
 script_name="${script_name}cpu_${virtual_cpu}-"
 
 if test "$local_time" = yes ; then
  script_name="${script_name}UTC_off.bash"
 else
  script_name="${script_name}UTC_on.bash"
 fi
}

for enable_virgl_and_display_gl in yes no ; do
 for libgl_always_software in yes no ; do
  for virtual_cpu in max host base qemu64-v1 ; do
   for cdrom in yes no ; do
    for kvm in yes no ; do
     for network in yes no ; do
      for uefi in yes no ; do
       for local_time in yes no ; do
        if test "$kvm" = yes ; then
         if test "$virtual_cpu" != host ; then
          continue
         fi
        fi
        zvC9-build_launcher_name
        
        echo "creating script: $script_name"
        rm -fv $script_name
        if test "$libgl_always_software" = "yes" ; then
         echo -e "#!/bin/bash\\n\\n" >> $script_name
         echo -e "LIBGL_ALWAYS_SOFTWARE=1 \\\\" >> $script_name
        else
         echo -e "#!/bin/bash\\n\\n" >> $script_name
         echo -e "LIBGL_ALWAYS_SOFTWARE=0 \\\\" >> $script_name
        fi
        echo -e "qemu-system-x86_64 \\\\" >> $script_name
        echo -e " -monitor stdio  \\\\" >> $script_name
        echo -e " -m $RAM_MB \\\\" >> $script_name
        echo -e " -drive file=Snapshots/current_state.qcow2,if=ide,media=disk,format=qcow2,cache=writethrough \\\\" >> $script_name
        echo -e " -boot order=c,menu=on \\\\" >> $script_name
        echo -e " -name \"$VMName\" \\\\" >> $script_name
        echo -e " -uuid ${VM_UUID} \\\\" >> $script_name
        
        echo -e " -smp ${cpu_count} \\\\" >> $script_name
        echo -e " -nodefaults \\\\" >> $script_name
        
        if test "$enable_virgl_and_display_gl" = yes ; then
         echo -e " -vga none \\\\" >> $script_name
         echo -e " -device virtio-vga,virgl=true,max_hostmem=$virtio_vga_max_hostmem \\\\" >> $script_name
        else
         echo -e " -vga $VM_VGA \\\\" >> $script_name
        fi
        
        #if test "$VM_VGA" = "virtio" ; then
        # if test "$enable_virgl_and_display_gl" = yes ; then
        #  echo -e " -vga none \\\\" >> $script_name
        #  echo -e " -device virtio-vga,virgl=true,max_hostmem=$virtio_vga_max_hostmem \\\\" >> $script_name
        # else
        #  echo -e " -vga virtio \\\\" >> $script_name
        # fi
        #else
        # echo -e " -vga $VM_VGA \\\\" >> $script_name
        #fi
        # $enable_virgl_and_display_gl
        echo -e " -chardev vc,id=vc0 -mon chardev=vc0 \\\\" >> $script_name
        echo -e " -usb -device usb-tablet \\\\" >> $script_name
        echo -e " -device usb-ehci,id=ehci0 \\\\" >> $script_name
        echo -e " -device usb-ehci,id=ehci1 \\\\" >> $script_name
        echo -e " -device usb-ehci,id=ehci2 \\\\" >> $script_name
        echo -e " -device usb-ehci,id=ehci3 \\\\" >> $script_name
        echo -e " -drive \"file=${prefix}swap.qcow2,format=qcow2,if=ide,media=disk,cache=writethrough\" \\\\" >> $script_name
        
        if test "$enable_virgl_and_display_gl" = yes ; then
        #if test "$VM_VGA" = "virtio" ; then
         echo -e " -display gtk,window-close=off,gl=on \\\\" >> $script_name
        else
         echo -e " -display gtk,window-close=off,gl=off \\\\" >> $script_name
        fi
        
        echo -e " -device virtio-balloon-pci \\\\" >> $script_name
        
        if test "$kvm" = yes ; then
         echo -e " -machine accel=kvm \\\\" >> $script_name
        else
         echo -e " -machine accel=tcg \\\\" >> $script_name
        fi
        if test "$network" = yes ; then
         echo -e  " -netdev user,id=usernet0,ipv6=off -device e1000,netdev=usernet0" \\\\ >> $script_name
        else
         echo -e " -net none \\\\" >> $script_name
        fi
        if test "$cdrom" = yes ; then
         echo -e " -drive file=cdrom.iso,if=ide,media=cdrom,readonly=on,format=raw \\\\" >> $script_name
        else
         echo -en # NOP
        fi
        if test "$uefi" = yes ; then
         echo -e  " -bios /usr/share/qemu/OVMF.fd" \\\\ >> $script_name
        else
         : # NOP ("pass" in python3)
        fi
        if test "$local_time" = yes ; then
         echo -e " -rtc base=localtime \\\\" >> $script_name
        else
         echo -e " -rtc base=utc \\\\" >> $script_name
        fi
        
        #if test "$virtual_cpu_is_host" = yes ; then
        # echo -e " -cpu host \\\\" >> $script_name
        #else
        # echo -e " -cpu qemu64-v1 \\\\" >> $script_name
        #fi # max host base qemu64-v1
        echo -e " -cpu \"${virtual_cpu}\" \\\\" >> $script_name
        
        echo >> $script_name
        echo "## to share local folder with VM, add either this to qemu cmdline:" >> $script_name
        echo "#   -virtfs local,path=/home/myname/folder1,mount_tag=shared0,security_model=mapped-file" >> $script_name
        echo "## or this" >> $script_name
        echo "#   -virtfs local,path=/home/myname/folder1,mount_tag=shared0,security_model=mapped-file,readonly" >> $script_name
        echo "## and mount from VM with either this command:" >> $script_name
        echo "#   mkdir --mode 0000 /home/myname/shared0" >> $script_name
        echo "#   mount -t 9p -o msize=32768 shared0 /home/myname/shared0" >> $script_name
        echo "## or this command:" >> $script_name
        echo "#   mkdir --mode 0000 /home/myname/shared0" >> $script_name
        echo "#   mount -t 9p -o msize=32768,ro shared0 /home/myname/shared0" >> $script_name
        echo -e \\n\\n"echo" >> $script_name # echo after running qemu for newline before next bash prompt
        chmod -c 0555 $script_name
       done
      done
     done
    done
   done
  done
 done
done

popd || exit 4

libgl_always_software=yes
virtual_cpu=qemu64-v1
cdrom=yes
kvm=no
network=yes
uefi=no
local_time=no
enable_virgl_and_display_gl=yes

zvC9-build_launcher_name

ln -s "$qemu_launchers_dir/${script_name}" ./launch_qemu_from_this_directory.bash
ln -s /dev/sr0 ./cdrom.iso

echo DONE

