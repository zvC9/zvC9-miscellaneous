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
  -machine accel=kvm \
  -net none \
  -rtc base=localtime \
 -cpu base \



echo
