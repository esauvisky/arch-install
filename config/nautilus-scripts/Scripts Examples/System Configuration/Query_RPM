#!/bin/sh
quoted=$(echo -e "$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS" | awk 'BEGIN {
FS = "\n" } { printf "\"%s\" ", $1 }' | sed -e s#\"\"##)
eval "gnorpm -q -p $quoted"