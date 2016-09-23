#!/bin/sh

run_initd()
{
cat >> ${INITFILE} <<EOF
if [[ -f /etc/mdadm.conf && -x /sbin/mdadm ]]
then
	msg 'Running raid arrays activation ... '
	mdadm --assemble --scan
fi

if [ -x /sbin/btrfs ]
then
	msg 'Running btrfs volumes activation ... '
	btrfs device scan
fi

if [ -x /sbin/lvm ]
then
	msg 'Running lvm volumes activation ... '
	/sbin/lvm vgchange -a y &>/dev/null
fi

EOF

	return 0
}

run_hook()
{
	cp_this -i /sbin/mdadm
	cp_this -i /etc/mdadm.conf
	cp_this -i /sbin/btrfs
	cp_this -i /sbin/lvm
	
	return 0
}
