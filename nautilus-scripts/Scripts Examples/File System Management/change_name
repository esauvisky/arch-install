#!/bin/bash

search=`gdialog --title "Rename files" --inputbox "Search for" 200 450 2>&1` || exit
replace=`gdialog --title "Rename files" --inputbox "Replace with" 200 450 2>&1` || exit

path=`echo -n "$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS" | head -n 1 |  sed 's/[^\/]*$//'`

while [ $# -gt 0 ]; do
        newname=`echo "$1" | sed -e "s/$search/$replace/g"`
        mv "$path$1" "$path$newname"
	shift
done
