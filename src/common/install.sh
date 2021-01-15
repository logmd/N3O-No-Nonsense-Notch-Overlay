#!/system/bin/sh
. $MODPATH/common/modules/mount-checks.sh
. $MODPATH/common/modules/overlay-checks.sh
. $MODPATH/common/modules/branding.sh
. $MODPATH/common/modules/version-checks.sh

##################
# Main functions #
##################
set_api() {
	[ $API = 29 ] && ACODE=10
	[ $API = 30 ] && ACODE=11
}

add_spacing() {
	local iterations=$1

	[ test -z "$iterations"] && iterations=1

	ui_print ""
	local i=0
	for i in $(seq 1 $iterations); do
		ui_print "------------------------------------------------"
	done
	ui_print ""
}

log_build_directories() {
	add_spacing 2
	if [ ! -s ${OVDIR}/signed.apk ]; then
		ui_print "signed file not generated"
	fi
	ls ${OVDIR}/
	add_spacing 2
}

build_apk() {
	ui_print "  Creating ${1} overlay..."

	aapt p -f -M ${OVDIR}/AndroidManifest.xml \
		-I /system/framework/framework-res.apk -S ${OVDIR}/res/ \
		-F ${OVDIR}/unsigned.apk

	if [ -s ${OVDIR}/unsigned.apk ]; then
		${ZIPPATH}/zipsigner ${OVDIR}/unsigned.apk ${OVDIR}/signed.apk
		cp -rf ${OVDIR}/signed.apk ${MODDIR}/${FAPK}.apk

		[ ! -s ${OVDIR}/signed.apk ] && cp -rf ${OVDIR}/unsigned.apk ${MODDIR}/${FAPK}.apk

		log_build_directories

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
	ui_print "  ${2} overlay created!"
}

pre_install() {
	rm -rf /data/resource-cache/overlays.list
	find /data/resource-cache/ -type f \( -name "*Gestural*" -o -name "*Gesture*" -o -name "*GUI*" -o -name "*GPill*" -o -name "*GStatus*" \) \
		-exec rm -rf {} \;
	ZIPPATH=${MODPATH}/common/addon
	set_perm ${ZIPPATH}/zipsigner 0 0 0755
	set_perm ${ZIPPATH}/zipsigner-3.0-dexed.jar 0 0 0644
}

post_install_cleanup() {
	ui_print "...post install cleanup"
	rm -rf $MODPATH/mods
	ui_print "...Done!"
	unmount_rw_stepdir
}

set_dir() {
	OVDIR=${MODDIR}/${1}
	VALDIR=${OVDIR}/res/values
	DRWDIR=${OVDIR}/res/drawable
}

############
# Main NCK #
############

mk_overlay() {
	add_spacing 10
	ui_print "	making overlay apk for $3"
	add_spacing

	MODNAME="$1"
	ui_print "modname ${MODNAME} ${1}"

	ui_print "modnamelower ${2}"

	ui_print "modstring ${3}"

	set_dir ${MODNAME}
	INFIX = "$MODNAME"
	DAPK=${PREFIX}${1}
	FAPK="${PREFIX}${1}Overlay"

	ui_print "overlay apk = $FAPK"

	sed -i "s|<vapi>|$API|" ${OVDIR}/AndroidManifest.xml
	sed -i "s|<vcde>|$ACODE|" ${OVDIR}/AndroidManifest.xml
	sed -i "s|<modname>|${2}|" ${OVDIR}/AndroidManifest.xml
	sed -i "s|_modname_|${3}|" ${OVDIR}/res/values/strings.xml

	ui_print "overlay apk = $FAPK replaced variables"

	ls -R ${OVDIR}/

	build_apk "$MODNAME" "$3"
}

install_n3o() {
	print_branding

	incompatibility_check
	pre_install
	set_api

	api_runcheck

	ui_print "  Overlays will be copied to ${STEPDIR}"

	MODDIR=${MODPATH}/mods/N3
	PREFIX="DisplayCutoutEmulation"

	ui_print "INSTALLING overlays ..........."

	mk_overlay "nnn8pfhd" "nnn8pfhd" "N3O 8Pro FHD"
	mk_overlay "nnn8pqhd" "nnn8pqhd" "N3O 8Pro QHD"
	mk_overlay "nnn8t" "nnn8t" "N3O 8 8T 8ProFHD"

	add_spacing 10
}

install_n3o
post_install_cleanup
