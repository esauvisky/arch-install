#!/bin/bash

###############################################################################
# secure copy (scp) Files to a given location
###############################################################################
#
# AUTHOR:       Brian Connelly <pub@bconnelly.net>
#
# DESCRIPTION:  This script does what its name implies-- it copies the files
#               which have been selected in Nautilus to a remote or local
#               location using the scp command.
#
# REQUIREMENTS: Nautilus file manager
#               scp (see OpenSSH)
#               gdialog, which is usually included in the gnome-utils package
#
# INSTALLATION: GNOME 1.4.x: copy this script to the ~/Nautilus/scripts
#                       directory
#               GNOME 2.x: copy to the ~/.gnome2/nautilus-scripts directory
#
# USAGE:        Select the files that you would like to copy in Nautilus,
#               right click, go to Scripts, and then select this script.
#               You will then be asked to select a target destination.
#               This can be one of the following:
#
#               Ex. 1. /tmp - copy the selected files to /tmp ON THIS MACHINE
#               Ex. 2. something.com:/home/somegyy - copy the selected files
#                       to /home/someguy directory on the machine something.com.
#                       NOTE: Your username on that machine must either be the
#                             same as your username on the local machine as on
#                             something.com, or the proper username must be
#                             specified in the .ssh_hosts file
#               Ex. 3. someguy@something.com:/home/someguy - copy the selected
#                       files to /home/someguy on something.com.  Your username
#                       on something.com is someguy.
#
# VERSION INFO:
#               0.1 (20020923) - Initial public release
#
# COPYRIGHT:    Copyright (C) 2002 Brian Connelly <connelly@purdue.edu>
#
# LICENSE:      GNU GPL
#
###############################################################################


SCRIPT_TITLE=$(basename "$0")
SCP_BIN=$(which scp) || (gdialog --title "$SCRIPT_TITLE Error" --msgbox "scp
cannot be found.  It is either not in your PATH or not installed on this
system" 400 400 2>&1 && exit)
TARGET=""

if [ -z $NAUTILUS_SCRIPT_SELECTED_FILE_PATHS ]; then
gdialog --title "$SCRIPT_TITLE Error" --msgbox "No files have been selected"
400 400 2>&1
exit
fi

while [ -z $TARGET ]
do
TARGET=$(gdialog --title "$SCRIPT_TITLE" --inputbox "Enter Target
Destination:" 400 400 "" 2>&1) || exit

if [ -z $TARGET]; then
gdialog --title "$SCRIPT_TITLE Error" --msgbox "You must choose a target
destination" 400 400 2>&1
fi
done

($SCP_BIN -r $NAUTILUS_SCRIPT_SELECTED_FILE_PATHS $TARGET >&
/tmp/scripterror && rm /tmp/scripterror) || (gdialog --title "$SCRIPT_TITLE
Error" --msgbox "Could not execute scp: `cat /tmp/scripterror`" 400 400 2>&1
&& rm /tmp/scripterror)
