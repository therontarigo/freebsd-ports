#!/bin/sh
# MAINTAINER: portmgr@FeeeBSD.org
# $FreeBSD$

[ -n "${DEBUG_MK_SCRIPTS}" -o -n "${DEBUG_MK_SCRIPTS_ACTUAL_PACKAGE_DEPENDS}" ] && set -x

if [ -z "${PKG_BIN}" ]; then
	echo "PKG_BIN required in environment." >&2
	exit 1
fi

if [ -z "${PORTBLDROOT}" ]; then
	echo "PORTBLDROOT required in environment." >&2
	exit 1
fi

# Have pkg always operate on PORTBLDROOT.
# Some other scripts use the assumption that ${PKG_BIN} is a single file
# pathname (as the name suggests).  Here, PKGCMD is defined, instead of
# modifying PKG_BIN, to preserve consistency with that assumption.
PKGCMD="${PKG_BIN} -r ${PORTBLDROOT}"

resolv_symlink() {
	local file tgt
	file=${1}
	if [ ! -L ${file} ] ; then
		echo ${file}
		return
	fi

	tgt=$(readlink ${file})
	case $tgt in
	/*)
		echo $tgt
		return
		;;
	esac

	file=${file%/*}/${tgt}
	absolute_path ${file}
}

absolute_path() {
	local file myifs target
	file=$1

	myifs=${IFS}
	IFS='/'
	set -- ${file}
	IFS=${myifs}
	for el; do
		case $el in
		.) continue ;;
		'') continue ;;
		..) target=${target%/*} ;;
		*) target="${target}/${el}" ;;
		esac
	done
	printf %s\\n ${target}
}

find_dep() {
	pattern=$1
	case ${pattern} in
	*\>*|*\<*|*=*)
		${PKGCMD} info -Eg "${pattern}" 2>/dev/null ||
			echo "actual-package-depends: dependency on ${pattern} not registered" >&2
		return
		;;
	/*)
		searchfile=$pattern
		;;
	*)
		searchfile=$(env PATH="${PORTBLDROOT}${LOCALBASE}/sbin:${PORTBLDROOT}${LOCALBASE}/bin" /usr/bin/which ${pattern} 2>/dev/null | sed "s,^${PORTBLDROOT}/,/,")
		;;
	esac
	if [ -n "${searchfile}" ]; then
		${PKGCMD} which -q ${searchfile} || ${PKGCMD} which -q "$(resolv_symlink ${searchfile} 2>/dev/null)" ||
			echo "actual-package-depends: dependency on ${searchfile} not registered (normal if it belongs to base)" >&2
	fi
}

for lookup; do
	${PKGCMD} query "\"%n\": {origin: \"%o\", version: \"%v\"}" "$(find_dep ${lookup})" || :
done
