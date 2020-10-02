#!/bin/sh
#
#  GZIP wrapper for Nautilus Scripts menu.
#
# AUTHOR:   Roberto Piscitello <robepisc@freemail.it>
# DATE:     21 May 2001
# LINCENSE: GPL
#

# We need gdialog or xmessage to output error messages
GDIALOG="/usr/bin/gdialog"
XMESSAGE="/usr/bin/X11/xmessage"

TMP_FILE=`tempfile`
IFS="
"

trap "rm -f $TMP_FILE" EXIT

for F in $NAUTILUS_SCRIPT_SELECTED_FILE_PATHS; do
	cd `dirname $F`
	if ! gzip `basename $F` 2> $TMP_FILE; then
		# Some error happened: beep and show an error message
		echo -e "\007"
		if [ -x $GDIALOG ]; then
			gdialog --title gzip --msgbox "`cat $TMP_FILE`." 20 100
		elif [ -x $XMESSAGE ]; then
			xmessage -buttons OK -file $TMP_FILE
		fi
	fi
done

