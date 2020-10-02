#!/bin/sh
#
#  GUNZIP and BUNZIP2 wrapper for Nautilus Scripts menu.
#
# AUTHOR:  Roberto Piscitello <robepisc@freemail.it>
# DATE:    21 May 2001
# LICENSE: GPL
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
	if [ `echo $F|awk '{ print substr($0,length($0)-2) }'` = "bz2" -o `echo $F|awk '{ print substr($0,length($0)-1) }'` = "bz" ]; then
		UZIP="bunzip2"
	else
		UZIP="gunzip"
	fi
	if ! $UZIP `basename $F` 2> $TMP_FILE; then
		# Some error happened: beep and show an error message
		echo -e "\007"
		if [ -x $GDIALOG ]; then
			gdialog --title $UZIP --msgbox "`cat $TMP_FILE`." 20 100
		elif [ -x $XMESSAGE ]; then
			xmessage -buttons OK -file $TMP_FILE
		fi
	fi
done


