#!/bin/bash
#
# Version: 0.1
#
# This script is build to extract, install and get info about Debian packages (.deb:s)
#
# Distributed under the terms of GNU GPL version 2 or later
#
# Copyright (C) Pontus Ullgren <pontus-a-ullgren.com>
#
# Install in your Nautilus scripts directory.
#
# Credits goes to Keith Conger for his super-extractor Nautilus script which I used as 
# a template.
#

FILE_TYPE=$(file -b $NAUTILUS_SCRIPT_SELECTED_FILE_PATHS|awk '{ print $1}')
MIME_TYPE=$(file -b $NAUTILUS_SCRIPT_SELECTED_FILE_PATHS)

DEFAULT_DIR="./"`basename $1 .deb`
DPKG_PATH=/usr/bin
TEMP_FILE=`tempfile`
XTERMPRG=/usr/bin/X11/xterm

if [ "$FILE_TYPE" != "Debian" ]; then
	 zenity  --error --title "File error" --text "$1 is not a Debian package.\nIt is reported as: $MIME_TYPE ($FILE_TYPE)" 2>&1
         exit -1;
fi

TODO=$(zenity --list --radiolist  --column "" --column "Action" TRUE "Extract package" FALSE "Install package" FALSE "Get info" 2>&1)

if [ "$TODO" = "Extract package" ]; then
	DIR=$(zenity --title "Extract compressed file to..." --entry --text "Directory to extract to:" --entry-text "$DEFAULT_DIR" --width=500 2>&1)
        if [ $DIR ]; then 
            mkdir $DIR
            $DPKG_PATH/dpkg-deb --vextract $NAUTILUS_SCRIPT_SELECTED_FILE_PATHS $DIR/ > $TEMP_FILE
            zenity --text-info --title "Extraction Log" --filename $TEMP_FILE --width=500 --height=500 2>&1
            rm $TEMP_FILE
        else
            zenity --error --title "Action canceled" --text "Action canceled by the user." 2>&1
        fi
elif [  "$TODO" = "Install package" ]; then
        echo "#!/bin/sh" > $TEMP_FILE
	echo "/bin/su -c \"$DPKG_PATH/dpkg --install  $NAUTILUS_SCRIPT_SELECTED_FILE_PATHS\"" >> $TEMP_FILE
	echo "echo Press enter to exit ..." >> $TEMP_FILE
        echo "read" >> $TEMP_FILE
	$XTERMPRG -T "Installing $1" -e /bin/sh $TEMP_FILE
        rm $TEMP_FILE
elif [  "$TODO" = "Get info" ]; then
	$DPKG_PATH/dpkg-deb -I $NAUTILUS_SCRIPT_SELECTED_FILE_PATHS > $TEMP_FILE
	zenity --text-info --title "Info about $1" --filename $TEMP_FILE --width=500 --height=500 2>&1
	rm $TEMP_FILE
fi
