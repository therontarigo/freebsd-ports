#!/bin/sh
ldpaths="${LOCALBASE}/lib"
ldpaths="${ldpaths} $(cat ${PORTBLDROOT}${LOCALBASE}/libdata/ldconfig/* 2>/dev/null)"
ldpaths=$(printf %s\\n ${ldpaths} | awk '$0="'"${PORTBLDROOT}"'"$0' | uniq -u | tr '\n' ' ')
echo "ldconfig path: ${ldpaths}"
/sbin/ldconfig -elf -f ${PORTBLDROOT}/var/run/ld-elf.so.hints -i ${ldpaths}
