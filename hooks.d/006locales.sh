#!/bin/sh

run_hook()
{
	local M F

	mkdir -p ${AND_TMPDIR}/usr/{share/{i18n/charmaps,locale/es/LC_MESSAGES},lib/locale}

	for M in nano.mo util-linux.mo dialog.mo ld.mo libc.mo
	do
		cp_this /usr/share/locale/es/LC_MESSAGES/${M}
	done

	for F in es_ES i18n iso14651_t1_common iso14651_t1 translit_neutral \
		translit_combining translit_circle translit_cjk_compat \
		translit_compat translit_font translit_fraction translit_narrow \
		translit_small translit_wide
	do
		cp_this /usr/share/i18n/locales/${F}
	done

	for F in UTF-7.so UTF-16.so UTF-32.so UNICODE.so ISO8859-1.so gconv-modules 
	do
		cp_this /usr/lib/gconv/${F}
	done

	cp_this /usr/share/{i18n/charmaps/{UTF-8.gz,ISO-8859-1.gz},locale/locale.alias}
	cp_this locale localedef
	cp_this /usr/share/terminfo/{a/ansi,l/linux,v/vt102}

	chroot ${AND_TMPDIR} localedef -i es_ES -c -f UTF-8 -A /usr/share/locale/locale.alias es_ES.UTF-8

	return 0
}
