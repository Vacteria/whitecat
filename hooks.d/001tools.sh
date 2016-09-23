 #!/bin/sh

run_hook()
{
	local BUSYBIN BIN TOOLS LIBS LIB

	TOOLS="modprobe modinfo depmod mount umount cfdisk parted gettext dialog bash sqlite3 nano tar"
	NETWORK="wpa_supplicant wpa_cli dhclient ip"
	FSTOOLS="lvm mdadm btrfs mke2fs mkntfs mkdosfs"
	LIBS='libm.so.6 libcrypt.so.1 libnss_files.so.2 libnss_dns.so.2 libresolv.so.2 ld-linux*'
	
	if [ -x "/usr/share/mkramfs/busybox" ]
	then
		BUSYBIN="/usr/share/mkramfs/busybox"
	elif [ -x "/bin/busybox" ]
	then
		BUSYBIN="/bin/busybox"
	fi
			
	[ -z "${BUSYBIN}" ] && die "$(gettext 'Unable to find any usable busybox binary')"
			
	cp_this -d /bin/busybox ${BUSYBIN}
	chroot ${AND_TMPDIR} /bin/busybox --install -s
	
	for BIN in ${TOOLS} ${FSTOOLS} ${NETWORK} ${LIBS}
	do
		cp_this ${BIN}
	done

	[ -L "${AND_TMPDIR}/linuxrc" ] && rm -f ${AND_TMPDIR}/linuxrc
	ln -sf /bin/busybox ${AND_TMPDIR}/init

	return 0
}
