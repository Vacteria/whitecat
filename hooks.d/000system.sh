#!/bin/bash

run_initd()
{
	cat > "${INITFILE}" <<"EOF"
#!/bin/sh

export PATH=/bin:/sbin:/usr/bin:/usr/sbin

LANGUAGE="en"
KEYBOARD="en"
OPENSHELL="0"
DEBUGMODE="0"

#
# Usefull functions
#
msg()
{
	local MSG="${1}"
	shift
	
	if [ "${DEBUGMODE}" == "1" ]
	then
		printf -- "[MESSAGE] : ${MSG}\n" ${@}
	fi

	return 0
}

err()
{
	local MSG="${1}"
	shift
	
	printf -- "[ERROR] : ${MSG}\n" ${@}

	return 0
}

shell()
{
	[ -r /proc/splash ] && echo "verbose" > /proc/splash
	PS1="sh# " /bin/busybox/cttyhack /bin/bash -i
}

panic()
	local MSG="${1}"
	shift
	
	printf -- "[PANIC] : ${MSG}\n" ${@}
	shell
}

openshell()
{	
	printf -- "Openning shell by demand, press Ctr+Alt+Supr to reboot" ${@}
	shell
}

progress()
{
	local PERCENT="${1}"

	if [ "x${PERCENT}" != "x" ]
	then
		if [[ -x /sbin/splash && -e /proc/splash ]]
		then
			 printf "show $(( 65534 * ${PERCENT} / 100 ))" > /proc/splash 
		fi
	fi

	return 0
}

read_cmd_params()
{
	local CMDLINE PARAM

	if mountpoint -q /proc 
	thrn
		msg "Reading cmdline params ... "

		read -r CMDLINE < /proc/cmdline
		for PARAM in ${CMDLINE}
		do
			case ${PARAM} in
				lang=* ) LANGUAGE=${PARAM#lang=} ;;
				kbd=*  ) KEYBOARD=${PARAM#kbd=}  ;;
				shell  ) OPENSHELL="1"           ;;
				debug  ) DEBUGMODE="1"           ;;
			esac
		done
	else
		err "/proc mus be mounted before read params"
	fi

	return 0
}

#
# Mount everithing need
#
msg "Mounting %s ... " "/dev"
mount -n -t devtmpfs devtmpfs /dev  || panic "Failed to mount %s" "/dev"

msg "Mounting %s ... " "/proc"
mount -n -t proc     proc     /proc || panic "Failed to mount %s" "/proc"

msg "Mounting %s ... " "/sys"
mount -n -t sysfs    sysfs    /sys  || panic "Failed to mount %s" "/sys"

msg "Mounting %s ... " "/run"
mount -n -t tmpfs    tmpfs    /run  || panic "Failed to mount %s" "/run"

mkdir -p /dev/pts
install -m 1777 /run/{shm,netrc,lock}
ln -svf /run/shm /dev/shm
ln -svf /proc/mounts /etc/mtab

#
# Make essential devices section
#
msg "Creating especial unmanaged devices ... "
mknod /dev/null c 1 3
mknod /dev/console c 5 1
mknod /dev/fb0 c 29 0
mknod /dev/kmsg c 1 11
mknod /dev/log c 21  5

for ((i=0; i<=6; i++))
do
	if [ -c /dev/tty${i} ]
	then
		msg "Making /dev/tty${i} c 4 ${T}" 
		mknod /dev/tty${i} c 4 ${i}
	fi
done

EOF

	return 0
}

run_hook()
{
	local FILES

	FILES='
			gshadow* services passwd* shadow* fstab bash.bashrc resolv.conf nsswitch.conf 
			bash.bash_logout profile hosts group rc.conf.d/i18n profile.d/* 
	'

	mkdir -p ${AND_TMPDIR}/{run,bin,sbin,lib,mnt,proc,sys,dev,srv,tmp}
	mkdir -p ${AND_TMPDIR}/usr/{bin,sbin,lib,share}
	mkdir -p ${AND_TMPDIR}/var/{log,lib/{misck,hwclock}}
	mkdir -p ${AND_TMPDIR}/etc/{rc.d,network.d,wpa_supplicant.conf.d,modprobe.d,udev/rules.d}
	mkdir -p ${AND_TMPDIR}/etc/{bash{_logout,rc}.d,rc.conf.d,profile.d}

	ln -sf /run/lock /var/lock
	ln -sf /run /var/run

	touch ${AND_TMPDIR}/etc/modprobe.d/modprobe.conf
	ln -sf lib ${AND_TMPDIR}/lib64

	mknod -m 640 ${AND_TMPDIR}/dev/console c 5 1
	mknod -m 664 ${AND_TMPDIR}/dev/null    c 1 3

	for F in ${FILES}
	do
		cp_this /etc/${F}
	done

	return 0
}

