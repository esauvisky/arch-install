#!/bin/sh
#
# Nautilus script that links selected files to desktop.
#
# Author: Krzysztof Luks <m00se@iq.pl>
#
# Copyright (C) 2002 Krzysztof Luks
# Licence: GNU GPL
#
# Dependency: nautilus and ln ;)
#

DESKTOP="$HOME/.gnome-desktop"

# We don't want to split NAUTILUS_SCRIPT_SELECTED_FILE_PATHS on spaces.
IFS="
"

for FILE in $NAUTILUS_SCRIPT_SELECTED_FILE_PATHS
do
    if [ ! -e "$DESKTOP/`basename $FILE`" ]
    then
        ln -s "$FILE" $DESKTOP
    fi
done

