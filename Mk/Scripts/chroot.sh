#!/bin/sh

env | grep PATH

if [ -z "$PORTBLDROOT" ]; then
	printf %s\\n "$0 must be used with PORTBLDROOT set"
	exit 1
fi

# if [ -z "$WRKDIR" ]; then
#	printf %s\\n "$0 must be used with WRKDIR set"
#	exit 1
# fi

if [ ! -e "$PORTBLDROOT" ]; then
	printf %s\\n "PORTBLDROOT $PORTBLDROOT must exist"
	exit 1
fi

if [ -z "$prtcrt_UID" ]; then
# Save id to switch back to unpriviliged user after chroot
export prtcrt_UID=`id -u`
export prtcrt_GID=`id -g`
fi

args=''
for arg in "$@"; do
# doesn't work if arg contains ' quotes
	args="$args '$arg'"
done

action="$1"
shift
cmdargs=''
for arg in "$@"; do
	cmdargs="$cmdargs '$arg'"
done

if [ `id -u` != 0 ]; then
	echo "========"
	echo "Require su to enter chroot (exec $cmdargs)"
	exec su -m root -c "$0 $args"
fi

PORTBLDCHROOT=/tmp/portbld
mkdir -p "$PORTBLDCHROOT"

set -x

basemounts="/bin /sbin /lib /libexec /usr/bin /usr/sbin /usr/lib /usr/libdata /usr/libexec /usr/share /usr/include $PORTSDIR"
bldmounts="$LOCALBASE /var/db/pkg"

#WRKDIR_REDIR="/tmp/work$WRKDIR"

WRKDIRPREFIX=/tmp/work

[ -n "$CHROOT_CHDIR" ] || CHROOT_CHDIR="$PWD"
[ -n "$PATH_CHROOTED" ] || PATH_CHROOTED="$PATH"

case "$action" in
	mount)
		"$0" unmount
		mkdir -p "$PORTBLDCHROOT/etc"
		cp /etc/group /etc/passwd /etc/pwd.db "$PORTBLDCHROOT/etc/"
		mkdir -p "$PORTBLDCHROOT/dev"
		mount -t devfs devfs "$PORTBLDCHROOT/dev"
		mkdir -p "$PORTBLDCHROOT/tmp"
		chmod 777 "$PORTBLDCHROOT/tmp"
		mount -t tmpfs tmpfs "$PORTBLDCHROOT/tmp"
		for mount in $basemounts; do
			mkdir -p "$PORTBLDCHROOT$mount"
			mount -t nullfs -o ro "$mount" "$PORTBLDCHROOT$mount"
		done
		for mount in $bldmounts; do
			mkdir -p "$PORTBLDCHROOT$mount"
			mount -t nullfs -o ro "$PORTBLDROOT$mount" "$PORTBLDCHROOT$mount"
		done
		# mkdir -p "$PORTBLDCHROOT$WRKDIR_REDIR"
		# mount -t nullfs -o rw "$WRKDIR" "$PORTBLDCHROOT$WRKDIR_REDIR"
		mkdir -p "$PORTBLDCHROOT$WRKDIRPREFIX"
		# mount -t tmpfs tmpfs "$PORTBLDCHROOT$WRKDIRPREFIX"
		mount -t nullfs -o rw "$WRKDIRPREFIX" "$PORTBLDCHROOT$WRKDIRPREFIX"
	;;
	unmount)
		# umount -f "$PORTBLDCHROOT$WRKDIR_REDIR"
		umount -f "$PORTBLDCHROOT$WRKDIRPREFIX"
		for mount in $basemounts $bldmounts; do
			umount -f "$PORTBLDCHROOT$mount"
		done
		umount -f "$PORTBLDCHROOT/dev"
		umount -f "$PORTBLDCHROOT/tmp"
		rm -f "$PORTBLDCHROOT/etc/"*
	;;
	cmd)
		env | grep PATH
		# env WRKDIR="$WRKDIR_REDIR" chroot -u "$prtcrt_UID" -g "$prtcrt_GID" "$PORTBLDCHROOT" "$@"
		echo ">>>>>>>> Entering chroot"
		env WRKDIRPREFIX="$WRKDIRPREFIX" chroot -u "$prtcrt_UID" -g "$prtcrt_GID" "$PORTBLDCHROOT" /bin/sh -c "cd $CHROOT_CHDIR && PATH=$PATH_CHROOTED $cmdargs"
		retval=$?
		echo "<<<<<<<< Exiting chroot"
		exit $retval
	;;
	*)
		exit 1
	;;
esac
