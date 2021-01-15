###############################################
# Check overlay dir (Thanks to @skittles9823) #
###############################################

incompatibility_check() {
	OOS=$(grep_prop "ro.oxygen.version*")
	ui_print "Oxygen OS = ${OOS}"
	if [ -d "/product/overlay" ]; then
		MAGISK_VER_CODE=$(grep "MAGISK_VER_CODE=" /data/adb/magisk/util_functions.sh | awk -F = '{ print $2 }')
		PRODUCT=true
		if [ $MAGISK_VER_CODE -ge "20000" ]; then
			STEPDIR=${MODPATH}/system/product/overlay
		else
			ui_print "  Magisk v20 is required for users on Android 10"
			abort "  Please update Magisk and try again."
		fi
	elif [ -d /oem/OP ]; then
		OEM=true
		is_mounted " /oem" || mount /oem
		is_mounted_rw " /oem" || mount_rw /oem
		is_mounted " /oem/OP" || mount /oem/OP
		is_mounted_rw " /oem/OP" || mount_rw /oem/OP
		STEPDIR=/oem/OP/OPEN_US/overlay/framework
	else
		STEPDIR=${MODPATH}/system/vendor/overlay
	fi
}