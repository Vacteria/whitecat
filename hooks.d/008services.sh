#!/bin/bash

run_initd()
{
	cat >> ${INITFILE} << "EOF"
msg "Running services"
for SRV in /etc/rc.d/*.sh
do
	[ -x ${SRV} ] && ${SRV} start
done

EOF

	return 0
}
