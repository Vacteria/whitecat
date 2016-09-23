 #!/bin/sh

run_initd()
{
cat >> ${INITFILE} <<EOF
msg "Starting system and kernel logguer"
/sbin/syslogd 2> /dev/null
/sbin/klogd -c 3 1> /dev/null

EOF
}

