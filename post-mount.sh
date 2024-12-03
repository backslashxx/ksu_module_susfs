#!/system/bin/sh
MODDIR=/data/adb/modules/susfs4ksu
SUSFS_BIN=/data/adb/ksu/bin/ksu_susfs
source ${MODDIR}/utils.sh
PERSISTENT_DIR=/data/adb/susfs4ksu
tmpfolder=/debug_ramdisk/susfs4ksu
logfile="$tmpfolder/logs/susfs.log"

sus_mount_old=0
[ -f $PERSISTENT_DIR/config.sh ] && source $PERSISTENT_DIR/config.sh

# echo "sus_mount_old=1" >> /data/adb/susfs4ksu/config.sh
if [ $sus_mount_old = 1 ] ; then
	${SUSFS_BIN} add_sus_mount /system 
	${SUSFS_BIN} add_sus_mount /system_ext
	${SUSFS_BIN} add_sus_mount /system/etc
	${SUSFS_BIN} add_sus_mount /product
	${SUSFS_BIN} add_sus_mount /vendor
	echo "susfs4ksu/post-mount: [sus_mount_old] done!" >> $logfile
else
	for i in $(grep -v "#" $PERSISTENT_DIR/sus_mount.txt); do
		${SUSFS_BIN} add_sus_mount $i && echo "susfs4ksu/post-mount: [add_sus_mount] $i" >> $logfile
	done
fi

# EOF
