#!/bin/bash

run_initd()
{
cat >> ${INITFILE} << "EOF"
stty -echoctl
printf "\033[9;%ld]" 0

if [ "${OPENSHELL}" == "1" ]
then
	openshell
fi

EOF

	return 0
}

