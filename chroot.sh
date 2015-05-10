#!/bin/bash

IMAGE=zebts.img
[ $# == 0 ] || IMAGE=$1

mount -o loop $IMAGE mnt
cp -p /etc/resolv.conf mnt/etc/

mount --bind /dev  mnt/dev
mount --bind /sys  mnt/sys
mount --bind /proc mnt/proc
mount --bind /dev/pts mnt/dev/pts

chroot mnt

umount mnt/{dev/pts,dev,sys,proc}
umount mnt
