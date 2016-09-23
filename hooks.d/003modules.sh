#!/bin/bash

run_hook()
{
	cp_this /lib/modules/${AND_KERNEL}
	cp_this /lib/firmware

	chroot ${AND_TMPDIR} depmod ${AND_KERNEL}
}

