#!/bin/bash
qemu-system-x86_64 \
 -monitor stdio  \
 -m 2048 \
 -drive file=Snapshots/current_state.qcow2,if=ide,media=disk,format=qcow2,cache=writethrough \
 -boot order=c,menu=on \
 -name testVM \
 -smp 2 \
 -nodefaults \
 -vga virtio \
 -chardev vc,id=vc0 -mon chardev=vc0 \
 -usb -device usb-tablet \
 -device usb-ehci,id=ehci0 \
 -device usb-ehci,id=ehci1 \
 -device usb-ehci,id=ehci2 \
 -device usb-ehci,id=ehci3 \
 -drive file=zvC9-swap.qcow2,format=qcow2,if=ide,media=disk,cache=writethrough \
 -display gtk,window-close=off \
 -device virtio-balloon-pci \
  -machine accel=tcg \
  -netdev user,id=usernet0,ipv6=off -device e1000,netdev=usernet0 \
  -drive file=cdrom.iso,if=ide,media=cdrom,readonly=on,format=raw \
  -rtc base=utc \
 -cpu qemu64-v1 \



echo
