#!/system/bin/sh

##################
# Main functions #
##################

build_apk() {
	ui_print "  Creating ${1} overlay..."
	aapt p -f -M ${OVDIR}/AndroidManifest.xml \
		-I /system/framework/framework-res.apk -S ${OVDIR}/res/ \
		-F ${OVDIR}/unsigned.apk

	if [ -s ${OVDIR}/unsigned.apk ]; then
		${ZIPPATH}/zipsigner ${OVDIR}/unsigned.apk ${OVDIR}/signed.apk
		cp -rf ${OVDIR}/signed.apk ${MODDIR}/${FAPK}.apk
		[ ! -s ${OVDIR}/signed.apk ] && cp -rf ${OVDIR}/unsigned.apk ${MODDIR}/${FAPK}.apk
		rm -rf ${OVDIR}/signed.apk ${OVDIR}/unsigned.apk
	else
		ui_print "  Overlay not created!"
		abort "  This is generally a rom incompatibility,"
	fi

	cp_ch -r ${MODDIR}/${FAPK}.apk ${STEPDIR}/${DAPK}

	if [ -s ${STEPDIR}/${DAPK}/${FAPK}.apk ]; then
		:
	else
		abort "  The overlay was not copied, please send logs to the developer."
	fi
	ui_print "  "
	ui_print "  ${1} overlay created!"
}

pre_install() {
	rm -rf /data/resource-cache/overlays.list
	find /data/resource-cache/ -type f \( -name "*Gestural*" -o -name "*Gesture*" -o -name "*GUI*" -o -name "*GPill*" -o -name "*GStatus*" \) \
		-exec rm -rf {} \;
	ZIPPATH=${MODPATH}/common/addon
	set_perm ${ZIPPATH}/zipsigner 0 0 0755
	set_perm ${ZIPPATH}/zipsigner-3.0-dexed.jar 0 0 0644
}

define_string() {
	SVRLY="Overlay"
}

set_dir() {
	OVDIR=${MODDIR}/${1}
	VALDIR=${OVDIR}/res/values
	DRWDIR=${OVDIR}/res/drawable
}

#########################################
# Mount check (Thanks to @skittles9823) #
#########################################

is_mounted() {
	grep " $(readlink -f "$1") " /proc/mounts 2>/dev/null
	return $?
}

is_mounted_rw() {
	grep " $(readlink -f "$1") " /proc/mounts | grep " rw," 2>/dev/null
	return $?
}

mount_rw() {
	mount -o remount,rw $1
	DID_MOUNT_RW=$1
}

unmount_rw() {
	if [ "x$DID_MOUNT_RW" = "x$1" ]; then
		mount -o remount,ro $1
	fi
}

unmount_rw_stepdir() {
	if [ $OEM ]; then
		is_mounted_rw " /oem" && unmount_rw /oem
		is_mounted_rw " /oem/OP" && unmount_rw /oem/OP
	fi
}

###############################################
# Check overlay dir (Thanks to @skittles9823) #
###############################################

incompatibility_check() {
	OOS=$(grep_prop "ro.oxygen.version*")

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

############
# Main NCK #
############

mk_overlay() {
	MODNAME="$1"
	modnamelower = "$2"
	set_dir ${MODNAME}
	INFIX = "$MODNAME"
	DAPK=${PREFIX}${1}
	FAPK=${PREFIX}${1}${SVRLY}

	ui_print "overlay apk = $FAPK"

	sed -i "s|<vapi>|$API|" ${OVDIR}/AndroidManifest.xml
	sed -i "s|<vcde>|$ACODE|" ${OVDIR}/AndroidManifest.xml
	sed -i "s|<modname>|${2}|" ${OVDIR}/AndroidManifest.xml
	sed -i "s|_modname_|$MODNAME|" ${OVDIR}/res/values/strings.xml
	
	cat ${OVDIR}/AndroidManifest.xml
	cat ${OVDIR}/res/values/strings.xml

	build_apk "$MODNAME"
}

incompatibility_check
pre_install
define_string

##############
# User input #
##############
if [ -z $R ] || [ -z $T ] && [ -z $W ] || [ -z $CLR1 ] || [ -z $CLR2 ] || [ -z $TRP ] || [ -z $IMRS ] || [ -z $FULL ] || [ -z $H ] || [ -z $MIUISM ] || [ -z $NCK ] || [ -z $NCKQHD ]; then
	ui_print "  _    ___   ___ __  __ ___   "
	ui_print " | |  / _ \ / __|  \/  |   \  "
	ui_print " | |_| (_) | (_ | |\/| | |) | "
	ui_print " |____\___/ \___|_|  |_|___/  "

else
	ui_print "INSTALL VIA APP ONLY"
	exit
fi

#####################
# Creating Overlays #
#####################
ui_print "  Overlays will be copied to ${STEPDIR}"

[ $API = 29 ] && ACODE=10
[ $API = 30 ] && ACODE=11

MODDIR=${MODPATH}/mods/N3
PREFIX="DisplayCutoutEmulation"


ui_print "--------------------------------------------"

mk_overlay "nnn8pfhd" "nnn8pfhd"

ui_print "--------------------------------------------"

mk_overlay "nnn8pqhd" "nnn8pqhd"

ui_print "--------------------------------------------"


#############
# Finishing #
#############

rm -rf $MODPATH/mods
ui_print "  Done..."
unmount_rw_stepdir
