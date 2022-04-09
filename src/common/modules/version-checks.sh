msg_give_it_a_shot() {
	ui_print "well ..."
	sleep 1
	ui_print "... lets give it a shot then ;)"
	sleep 2
}

android_10_check() {
	ui_print " "
	ui_print " Android 10 (or lower) untested... continue?"
	ui_print " "
	ui_print " YES: vol + "
	ui_print " NO : vol - "
	ui_print " "

	if chooseport 30; then
		ui_print "YES!"
		sleep 1
		msg_give_it_a_shot
	else
		ui_print "NO!??"
		sleep 1
		ui_print "... Why you here then? :p"
		sleep 1
		abort "... well i guess we should quit then!"
	fi
}

api_runcheck() {

	add_spacing
	ui_print " You are Using Android $ACODE (API VER $API)"

	case $(($API >= 31 ? 2 : $API == 30 ? 1 : 0)) in
	2)
		ui_print "... EXPERIMENTAL SUPPORT"
		sleep 1
		ui_print "... Be careful with your new toy!"
		msg_give_it_a_shot
		;;
	1)
		ui_print "... STABLE SUPPORT"
		;;
	*)
		ui_print "... EXPERIMENTAL LEGACY SUPPORT"
		android_10_check
		;;
	esac

	add_spacing
}
