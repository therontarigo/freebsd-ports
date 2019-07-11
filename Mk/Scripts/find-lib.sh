#!/bin/sh
# MAINTAINER: portmgr@FreeBSD.org
# $FreeBSD$

[ -n "${DEBUG_MK_SCRIPTS}" -o -n "${DEBUG_MK_SCRIPTS_FIND_LIB}" ] && set -x

if [ -z "${LIB_DIRS}" -o -z "${LOCALBASE}" ]; then
	echo "LIB_DIRS, LOCALBASE required in environment." >&2
	exit 1
fi

# Don't need to check in $PORTBLDROOT for a file which has been obsolete before PORTBLDROOT existed
if [ -f /usr/share/misc/magic.mime -o -f /usr/share/misc/magic.mime.mgc ]; then
	echo >&2
	echo "Either /usr/share/misc/magic.mime or /usr/share/misc/magic.mime.mgc exist and must be removed." >&2
	echo "These are legacy files from an older release and may safely be deleted." >&2
	echo "Please see UPDATING 20150213 for more details." >&2
	exit 1
fi

if [ $# -ne 1 ]; then
	echo "$0: no argument provided." >&2
fi

lib=$1
dirs="${LIB_DIRS} $(cat ${PORTBLDROOT}${LOCALBASE}/libdata/ldconfig/* 2>/dev/null || :)"

for libdir in ${dirs} ; do
	test -f ${PORTBLDROOT}${libdir}/${lib} || continue
	libfile=${libdir}/${lib}
	libfile_realpath=${PORTBLDROOT}${libfile}
	[ "$(/usr/bin/file -b -L --mime-type ${libfile_realpath})" = "application/x-sharedlib" ] || continue
	printf %s\\n $libfile
	break
done
