#!/bin/sh
# Name: (Un)Mount Loopback
# Description: Allows for mounting and unmounting of loopback filesystems
# Author: Caleb Shay <caleb@webninja.com>
# License: GPL
# This script makes several assumptions:
# 1.  You have gdialog installed in your path
# 2.  You have xsu installed in your path
# 3.  You have loopback device support in your kernel
# 4.  You have the mountpints /mnt/loop0 - /mnt/loop7
# 5.  You have your kernel compiled with the default number (8) of loopback devices
# 6.  Your loopback files will either be iso9660 cdroms or efs filesystems
#     (but adding more filesystems is trivial)
for arg
do
    skipFile=0;
    ftype=$(file "${arg}");
    if [ "`df | grep \"${arg}\"`" ]; then
        xsu -u root -t "Unmount Loopback Filesystem" -d -e -- umount \"${arg}\";
        continue;
    fi;
    case "$ftype" in
        *ISO\ 9660\ CD-ROM\ filesystem*)
            mtype="iso9660";
        ;;
        *SGI\ disk\ label*)
            mtype="efs";
        ;;
        *)
            gdialog --msgbox "Don't know how to mount\n${ftype}" 300 400;
            skipFile=1;
        ;;
    esac;
    if [ ${skipFile} -lt 1 ]; then
        mounted=0;
        for loop in loop0 loop1 loop2 loop3 loop4 loop5 loop6 loop7; do
            if [ "`df | grep /mnt/${loop}`" ]; then
                echo "Something already mounted on ${loop}";
            else
                mounted=1;
                xsu -u root -t "Mount Loopback Filesystem" -d -e -- mount -o loop -t ${mtype} \"${arg}\" /mnt/${loop};
                nautilus /mnt/${loop}
                break;
            fi;
        done;
        if [ ${mounted} -lt 1 ]; then
            gdialog --msgbox "No available mount points for ${arg}" 300 200;
        fi
    fi;
done
