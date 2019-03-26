#!/bin/sh
#
# This script prints the selected files with openoffice.org
# especially useful for openoffice files ;-) 
#
# the "quoted..." line handles multiple files with spaces 
# (like shown on the g-scripts site)
#
quoted=$(echo -e "$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS" | awk 'BEGIN {FS = "\n" } { printf "\"%s\" ", $1 }' | sed -e s#\"\"##)
eval "ooffice -p $quoted"
