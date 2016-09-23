#!/bin/bash

run_initd()
{
cat >> ${INITFILE} << EOF
#
# Hotplug detection
#
echo "" > /proc/sys/kernel/hotplug

msg "Runing hotplug detection"

udevd --daemon
udevadm control --property=STARTUP=1
udevadm trigger --action="add"
udevadm settle --timeout=60
udevadm control --property=STARTUP=

EOF
}

run_hook()
{
	cp_this /etc/udev
	cp_this /sbin/{udevadm,blkid,udevd}
	cp_this /lib/udev/{ata,scsi}_id
}

