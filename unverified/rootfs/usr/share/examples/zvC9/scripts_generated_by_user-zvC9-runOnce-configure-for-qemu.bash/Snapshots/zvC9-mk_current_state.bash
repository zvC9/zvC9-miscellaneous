#!/bin/bash

i="$(ls ??????-*.qcow2 | grep -P "\\d{6}-.*\\.qcow2" | sort | tail -n 1)"
rm -fv current_state.qcow2
if [ "x$i" = "x" ] ; then
        echo not found snapshot, using base
        qemu-img create -f qcow2 -b ../zvC9-base.qcow2 -F qcow2 current_state.qcow2
else
        echo found \""$i"\"
        qemu-img create -f qcow2 -b "$i" -F qcow2 current_state.qcow2
fi
