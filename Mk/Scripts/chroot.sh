#!/bin/sh

# chroot.sh: configure and use filesystem namespace for building of ports

if [ -z "$PORTBLDROOT" ]; then
	printf %s\\n "$0 must be used with PORTBLDROOT set" > /dev/stderr
	exit 1
fi

if [ ! -e "$PORTBLDROOT" ]; then
	printf %s\\n "PORTBLDROOT $PORTBLDROOT must exist" > /dev/stderr
	exit 1
fi

if [ -z "$prtcrt_UID" ]; then
# Switch to specified UID/GID if given
export prtcrt_UID=$PORTBLD_UID
export prtcrt_GID=$PORTBLD_GID
fi
if [ -z "$prtcrt_UID" ]; then
# Save id to switch back to unpriviliged user after chroot
export prtcrt_UID=`id -u`
export prtcrt_GID=`id -g`
fi

args=''
for arg in "$@"; do
	# sed: workaround in case arg contains ' quotes
	arg=`printf %s "$arg" | sed "s/'/'"'"'"'"'"'"'/g"`
	args="$args '$arg'"
done

action="$1"
shift
cmdargs=''
for arg in "$@"; do
	# sed: workaround in case arg contains ' quotes
	arg=`printf %s "$arg" | sed "s/'/'"'"'"'"'"'"'/g"`
	cmdargs="$cmdargs '$arg'"
done

[ -n "$CHROOT_CHDIR" ] || CHROOT_CHDIR="$PWD"
[ -n "$PATH_CHROOTED" ] || PATH_CHROOTED="$PATH"

PORTBLDCHROOT=/tmp/portbld
mkdir -p "$PORTBLDCHROOT"

basemounts="/bin /sbin /lib /libexec /usr/bin /usr/sbin /usr/lib /usr/libdata /usr/libexec /usr/share /usr/include $PORTSDIR"
bldmounts="$LOCALBASE /var/db/pkg"

WRKDIRPREFIX=/tmp/work

case "$action" in
	mount)
		if [ `id -u` != 0 ]; then
			echo "Require su to configure chroot in $PORTBLDCHROOT"
			exec su -m root -c "$0 $args"
		fi
		"$0" unmount 2>/dev/null
		mkdir -p "$PORTBLDCHROOT/etc"
		cp /etc/group /etc/passwd /etc/pwd.db "$PORTBLDCHROOT/etc/"
		mkdir -p "$PORTBLDCHROOT/dev"
		mount -t devfs devfs "$PORTBLDCHROOT/dev"
		mkdir -p "$PORTBLDCHROOT/tmp"
		chmod 777 "$PORTBLDCHROOT/tmp"
		mount -t tmpfs tmpfs "$PORTBLDCHROOT/tmp"
		for mount in $basemounts; do
			mkdir -p "$PORTBLDCHROOT$mount"
			mount -t nullfs -o ro -o nosuid "$mount" "$PORTBLDCHROOT$mount"
		done
		for mount in $bldmounts; do
			mkdir -p "$PORTBLDCHROOT$mount"
			mount -t nullfs -o ro -o nosuid "$PORTBLDROOT$mount" "$PORTBLDCHROOT$mount"
		done
		mkdir -p "$PORTBLDCHROOT$WRKDIRPREFIX"
		mount -t nullfs -o rw -o nosuid "$WRKDIRPREFIX" "$PORTBLDCHROOT$WRKDIRPREFIX"

		# Let user manipulate ldconfig:
		#   Root must absolutely never enter the chroot (since user has full control over libraries)
		#   Chroot must not contain any setuid binaries
		# This likely creates a security hole; another solution must be found.
		chown "$prtcrt_UID:0" "$PORTBLDCHROOT"/var/run
		chroot -u "$prtcrt_UID" -g "$prtcrt_GID" "$PORTBLDCHROOT" /sbin/ldconfig
	;;
	unmount)
		if [ `id -u` != 0 ]; then
			echo "Require su to dismantle chroot in $PORTBLDCHROOT"
			exec su -m root -c "$0 $args"
		fi
		rm -f "$PORTBLDCHROOT"/var/run/ld-elf.so.hints
		umount -f "$PORTBLDCHROOT$WRKDIRPREFIX"
		for mount in $basemounts $bldmounts; do
			umount -f "$PORTBLDCHROOT$mount"
		done
		umount -f "$PORTBLDCHROOT/dev"
		umount -f "$PORTBLDCHROOT/tmp"
		rm -f "$PORTBLDCHROOT/etc/"*
	;;
	cmd)
		if [ `id -u` != 0 ]; then
			echo "Require su to enter chroot (cd $CHROOT_CHDIR && exec"`printf '%s' "$cmdargs"`")" > /dev/stderr
			exec su -m root -c "$0 $args"
		fi
		echo ">>>>>>>> Entering chroot" > /dev/stderr
		env WRKDIRPREFIX="$WRKDIRPREFIX" chroot -u "$prtcrt_UID" -g "$prtcrt_GID" "$PORTBLDCHROOT" /bin/sh -c "cd $CHROOT_CHDIR && PATH=$PATH_CHROOTED $cmdargs"
		retval=$?
		echo "<<<<<<<< Exiting chroot" > /dev/stderr
		exit $retval
	;;
	*)
		exit 1
	;;
esac
