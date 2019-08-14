#!/bin/sh

# Mk/Scripts/ldconfig.sh: Maintain ld-elf.so.hints inside ${PORTBLDROOT}

# Does this script make any sense for non-PORTBLDROOT port installation?

set -e

. ${dp_SCRIPTSDIR}/functions.sh

validate_env dp_LOCALBASE dp_PORTBLDROOT

[ -n "${DEBUG_MK_SCRIPTS}" -o -n "${DEBUG_MK_SCRIPTS_LDCONFIG}" ] && set -x

set -u

LOCALBASE="${dp_LOCALBASE}"
PORTBLDROOT="${dp_PORTBLDROOT}"

ldpaths="${LOCALBASE}/lib"

files=$(find "${PORTBLDROOT}${LOCALBASE}/libdata/ldconfig" -type f 2>&- || true)

if [ -n "${files}" ]; then
ldpaths="${ldpaths} $(cat ${files})"
fi

ldpaths=$(printf %s\\n ${ldpaths} | awk '$0="'"${PORTBLDROOT}"'"$0' | uniq -u | tr '\n' ' ')

ldpaths="/lib /usr/lib /usr/lib/compat ${ldpaths}"

printf %s\\n "portenv ldconfig path: ${ldpaths}" >&2

/bin/mkdir -p ${PORTBLDROOT}/var/run/
/sbin/ldconfig -elf -f ${PORTBLDROOT}/var/run/ld-elf.so.hints -i ${ldpaths}
