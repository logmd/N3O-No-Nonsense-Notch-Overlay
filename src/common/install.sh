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
	[ $API = 31 ] && ACODE=12
	[ $API = 32 ] && ACODE=12
	[ $API = 33 ] && ACODE=13
}

add_spacing() {
	local iterations=$1

	[ test -z "$iterations"] && iterations=1

	ui_print ""
	local i=0
	for i in $(seq 1 $iterations); do
		ui_print "-----------------------------------------------------"
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
	ui_print "...	[APK] Generating overlay..."

	aapt p -f -M ${OVDIR}/AndroidManifest.xml \
		-I /system/framework/framework-res.apk -S ${OVDIR}/res/ \
		-F ${OVDIR}/unsigned.apk

	if [ -s ${OVDIR}/unsigned.apk ]; then
		${ZIPPATH}/zipsigner ${OVDIR}/unsigned.apk ${OVDIR}/signed.apk
		cp -rf ${OVDIR}/signed.apk ${MODDIR}/${FAPK}.apk

		[ ! -s ${OVDIR}/signed.apk ] && cp -rf ${OVDIR}/unsigned.apk ${MODDIR}/${FAPK}.apk

		# log_build_directories

		rm -rf ${OVDIR}/signed.apk ${OVDIR}/unsigned.apk
	else
		ui_print "!!!	Overlay not created!"
		abort "!!!	This is generally a rom incompatibility,"
	fi

	cp_ch -r ${MODDIR}/${FAPK}.apk ${STEPDIR}/${DAPK}

	if [ -s ${STEPDIR}/${DAPK}/${FAPK}.apk ]; then
		:
	else
		abort "!!!	The overlay was not copied, please send logs to the developer."
	fi

	ui_print "✓		[APK] Generated!"
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
	ui_print "...	post install cleanup"
	rm -rf $MODPATH/mods
	ui_print "✓		Done!"
	unmount_rw_stepdir
}

set_dir() {
	OVDIR=${MODDIR}/${1}
	VALDIR=${OVDIR}/res/values
	DRWDIR=${OVDIR}/res/drawable
}

run_checks() {

	incompatibility_check
	pre_install
	set_api
	api_runcheck
}

mk_overlay() {
	MODDIR=${MODPATH}/mods/N3
	PREFIX="DisplayCutoutEmulation"

	ui_print "...	[APK] Preparing install $3"

	MODNAME="$1"
	# ui_print "modname ${MODNAME} ${1}, modstring ${3}, cutout '${4}'"

	# ui_print "copying '${MODDIR}/overlay' to '${MODDIR}/${MODNAME}/'"
	cp -rf ${MODDIR}/overlay ${MODDIR}/${MODNAME}/

	set_dir ${MODNAME}

	INFIX = "$MODNAME"
	DAPK=${PREFIX}${1}
	FAPK="${PREFIX}${1}Overlay"

	# ui_print "overlay apk = $FAPK"

	sed -i "s|<vapi>|$API|" ${OVDIR}/AndroidManifest.xml
	sed -i "s|<vcde>|$ACODE|" ${OVDIR}/AndroidManifest.xml
	sed -i "s|<modname>|${2}|" ${OVDIR}/AndroidManifest.xml
	sed -i "s|_modname_|${3}|" ${OVDIR}/res/values/strings.xml
	sed -i "s|_cutout_|${4}|" ${OVDIR}/res/values/config.xml

	# ui_print "overlay apk = $FAPK replaced variables"

	# ls -R ${OVDIR}/

	build_apk "$MODNAME" "$3"
}

install_n3o_custom() {
	local iteration="$1"
	local defaultValue="$2"
	local cutoutPosition="$3"
	local custom_location='/sdcard/com.logmd.n3o/'
	local custom_file="${custom_location}${iteration}${cutoutPosition}.txt"

	add_spacing 1

	if [ ! -s "${custom_file}" ]; then
		ui_print "...	[Custom] Overlay ${iteration}${cutoutPosition} txt not found"
		ui_print "...	[Custom] Creating ${custom_file} "
		ui_print "...	[Custom] with value ${cutoutPosition} ${defaultValue}px"

		mkdir $custom_location
		echo $defaultValue >$custom_file
	fi

	local overlayValue=$(cat $custom_file)

	ui_print "...	[Custom] Found ${iteration} config with ${cutoutPosition} ${overlayValue}px"

	local custom="M 0 0 h ${overlayValue} v 1 h -${overlayValue} Z @left"

	case $cutoutPosition in
	"right")
		custom="M 0 0 h -${overlayValue} v 1 h ${overlayValue} Z @right"
		;;
	"center")
		custom="M -${overlayValue} 0 h $(($overlayValue * 2)) v 1 h -$(($overlayValue * 2)) Z"
		;;
	esac

	ui_print "... [Custom] Generated Cutout: "
	ui_print "... [Custom] ${custom}"

	ui_print ""
	mk_overlay "overlay_${iteration}${cutoutPosition}" "n3o.a.cst.${iteration}${cutoutPosition}" "CST ${cutoutPosition} ${iteration} (${overlayValue}px)" "${custom}"
}

install_n3o_preset() {
	local name="${1}"
	local cutoutWidth="${3}"
	local title="${2}"
	local cutoutPosition="${4}"

	local cutout="M 0 0 h ${cutoutWidth} v 1 h -${cutoutWidth} Z @${cutoutPosition}"
	local titleWithPx="${title} (${cutoutWidth}px)"

	add_spacing 1
	ui_print "?		Install ${titleWithPx}?"
	ui_print "?		"
	ui_print "?		Yes (vol+)  |  NO (vol-)"
	ui_print ""

	if chooseport 30; then
		mk_overlay "overlay_${name}" "${name}" "${titleWithPx}" "${cutout}"
	fi
}

install_n3o() {
	print_branding

	run_checks

	ui_print "...	Overlays will be copied to"
	ui_print "...	${STEPDIR}"
	ui_print "...	INSTALLING overlays..."

	install_n3o_preset "n3o.google.pixel5" "[Google] Pixel 5" 135 "left"
	install_n3o_preset "n3o.oneplus.op8" "[1+] 8, 8T, 8Pro FHD+" 130 "left"
	install_n3o_preset "n3o.oneplus.op8pqhd" "[1+] 8 Pro QHD+" 170 "left"

	add_spacing 1
	ui_print "?		Install Custom Cutouts (Left & Right)?"
	ui_print "?		"
	ui_print "?		Yes (vol+)  |  NO (vol-)"
	ui_print ""

	add_spacing 1

	if chooseport 30; then

		install_n3o_custom "custom1" "100" "left"
		install_n3o_custom "custom2" "150" "left"

		install_n3o_custom "custom1" "100" "right"
		install_n3o_custom "custom2" "150" "right"

		install_n3o_custom "custom1" "30" "center"

		add_spacing 3

		ui_print "================= USING CUSTOM CUTOUTS ================="
		ui_print ""
		ui_print "...	- Update /sdcard/com.logmd.n3o/custom1left.txt"
		ui_print "...	  (or custom2/3) to adjust cutout width"
		ui_print "..."
		ui_print "...	- Use custom1right for right side cutout"
		ui_print "..."
		ui_print "...	- Re-install & reboot to tweak cutout"
		ui_print ""
		ui_print "========================================================"
	fi

	add_spacing 5
}

install_n3o
post_install_cleanup
