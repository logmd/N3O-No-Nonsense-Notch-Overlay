
api_runcheck() {

	add_spacing
	ui_print " You are Using Android $ACODE		  "

	if [$ACODE != 11]; then

		ui_print " "
		ui_print " Android 10 or below is untested,  "
		ui_print " Are you sure you want to continue?"
		ui_print " "
		ui_print " YES: vol + "
		ui_print " NO : vol - "
		ui_print " "

		if chooseport 30; then
			ui_print "YES!"
			sleep 1

			ui_print "well ..."
			sleep 1
			ui_print "... lets give it a shot then ;)"
			sleep 2

		else
			ui_print "NO!??"
			sleep 1
			ui_print "... Why you here then? :p"
			sleep 1
			abort "... well i guess we should quit then!"
		fi

	fi
	add_spacing
}