#!/bin/bash

run_hook()
{

	cp_this vpm*
	cp_this /etc/vpm
	cp_this /usr/share/vpm
	cp_this /usr/{share,bin}/mkramfs
	cp_this /lib/init/net-fuctions
	cp_this netrc

	echo "file:///" > ${AND_TMPDIR}/etc/vpm/mirrors
	vpm --dbase --root ${AND_TMPDIR}
}
