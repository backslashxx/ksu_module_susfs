#!/system/bin/sh
MODDIR=/data/adb/modules/susfs4ksu
SUSFS_BIN=/data/adb/ksu/bin/ksu_susfs
source ${MODDIR}/utils.sh
PERSISTENT_DIR=/data/adb/susfs4ksu
tmpfolder=/debug_ramdisk/susfs4ksu
mkdir -p $tmpfolder/logs
logfile="$tmpfolder/logs/susfs.log"
logfile1="$tmpfolder/logs/susfs1.log"

dmesg | grep -q "susfs:" > /dev/null && touch $tmpfolder/logs/susfs_active

force_hide_lsposed=0
[ -f $PERSISTENT_DIR/config.sh ] && source $PERSISTENT_DIR/config.sh

echo "susfs4ksu/post-fs-data: [logging_initialized]" > $logfile1

#### Enable sus_su ####
enable_sus_su_mode_1(){
  ## Here we manually create an system overlay an copy the sus_su and sus_su_drv_path to ${MODDIR}/system/bin after sus_su is enabled,
  ## as ksu overlay script is executed after all post-fs-data.sh scripts are finished

  rm -rf ${MODDIR}/system 2>/dev/null
  # Enable sus_su or abort the function if sus_su is not supported #
  if ! ${SUSFS_BIN} sus_su 1; then
    return
  fi
  mkdir -p ${MODDIR}/system/bin 2>/dev/null
  # Copy the new generated sus_su_drv_path and 'sus_su' to /system/bin/ and rename 'sus_su' to 'su' #
  cp -f /data/adb/ksu/bin/sus_su ${MODDIR}/system/bin/su
  cp -f /data/adb/ksu/bin/sus_su_drv_path ${MODDIR}/system/bin/sus_su_drv_path
  echo 1 > ${MODDIR}/sus_su_mode
  return
}
# uncomment it below to enable sus_su with mode 1 #
#enable_sus_su_mode_1

# to add paths
# echo "/system/addon.d" >> /data/adb/susfs4ksu/sus_path.txt
# this'll make it easier for the webui to do stuff
for i in $(grep -v "#" $PERSISTENT_DIR/sus_path.txt); do
	${SUSFS_BIN} add_sus_path $i && echo "[sus_path]: susfs4ksu/post-fs-data $i" >> $logfile1
done

# LSPosed
# but this is probably not needed if auto_sus_bind_mount is enabled
[ $force_hide_lsposed = 1 ] && {
	echo "susfs4ksu/boot-completed: [force_hide_lsposed]" >> $logfile1
	${SUSFS_BIN} add_sus_mount /data/adb/modules/zygisk_lsposed/bin/dex2oat
	${SUSFS_BIN} add_sus_mount /data/adb/modules/zygisk_lsposed/bin/dex2oat32
	${SUSFS_BIN} add_sus_mount /data/adb/modules/zygisk_lsposed/bin/dex2oat64
	${SUSFS_BIN} add_sus_mount /system/apex/com.android.art/bin/dex2oat
	${SUSFS_BIN} add_sus_mount /system/apex/com.android.art/bin/dex2oat32
	${SUSFS_BIN} add_sus_mount /system/apex/com.android.art/bin/dex2oat64
	${SUSFS_BIN} add_sus_mount /apex/com.android.art/bin/dex2oat
	${SUSFS_BIN} add_sus_mount /apex/com.android.art/bin/dex2oat32
	${SUSFS_BIN} add_sus_mount /apex/com.android.art/bin/dex2oat64
	${SUSFS_BIN} add_try_umount /system/apex/com.android.art/bin/dex2oat 1
	${SUSFS_BIN} add_try_umount /system/apex/com.android.art/bin/dex2oat32 1
	${SUSFS_BIN} add_try_umount /system/apex/com.android.art/bin/dex2oat64 1
	${SUSFS_BIN} add_try_umount /apex/com.android.art/bin/dex2oat 1
	${SUSFS_BIN} add_try_umount /apex/com.android.art/bin/dex2oat32 1
	${SUSFS_BIN} add_try_umount /apex/com.android.art/bin/dex2oat64 1
}

