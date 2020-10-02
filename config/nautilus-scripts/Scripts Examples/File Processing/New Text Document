#!/bin/sh
# 
# Add a new text file in the current directory.
#
# Distributed under the terms of GNU GPL version 2 or later
#
# Copyright (C) 2003 Dexter Ang [thepoch@mydestiny.net
# based on work by Jeffrey Philips and Johnathan Bailes
# and a script I found on themedepot.org

# KNOWN BUGS:
#	- Never tested with an invalid directory. Don't know how.
#	- When you enter a blank filename, it generates a .txt hidden file.
#	- There's probably more.
#
# 2003-12-08 Dexter Ang [thepoch@mydestiny.net]
# Modified for Nautilus 2.4
# -- now detects if executed on desktop "x-nautilus-desktop:///"
#    so that it creates the file in /home/{user}/Desktop

# Remove comment to set Debug Mode. Displays crucial variable values
#DEBUG_MODE=1

# Remove comment to automatically generate filename. Set to 1 to ask for filename
#ASK_MODE=1

# Set the default extension of your preference here
EXTENSION="txt"

# Function for displaying variable values and anything else I want
debug() {
	[ -n "$DEBUG_MODE" ] && gdialog --title "Debug Mode" --msgbox "$*" 200 100
}

# This gets the current directory. It is "space-space" as it replaces %20 with spaces
Current_Dir="`echo "$NAUTILUS_SCRIPT_CURRENT_URI" | sed -e 's/^file:\/\///' -e 's/%20/\ /g'`"

# Added 2003-12-08 Dexter Ang
if [ $Current_Dir == "x-nautilus-desktop:///" ]; then
	Current_Dir=$HOME"/Desktop"
fi

debug "Current_Dir = $Current_Dir"

if [ $ASK_MODE == "1" ]; then
	debug "In Ask Mode"
	New_Document="`gdialog --title "New Filename" --inputbox "Enter a new filename" 200 100 2>&1`"
	if [ $? -ne "0" ]; then
		debug "Canceled"
		exit 1
	fi
else
	debug "In Non-Ask Mode"
	New_Document="New Text Document"
fi
debug "New_Document = $New_Document"

COUNT=1

# If file doens't exist, touch it
if ! [ -a "$Current_Dir/$New_Document.txt" ] ; then
  touch "$Current_Dir/$New_Document.txt"
# else, go loop until you get a number that works!
else
  while ! [ "$retry" ] ; do
    let $((COUNT++))
    if ! [ -a "$Current_Dir/$New_Document($COUNT).txt" ] ; then
        touch "$Current_Dir/$New_Document($COUNT).txt"
	retry=1
    fi
  done
fi
