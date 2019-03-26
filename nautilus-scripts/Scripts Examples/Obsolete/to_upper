#!/bin/sh

echo $@
# Lower-case a filename
#Note that 'This' will overwrite 'this'!
mv -iv "$@" "`echo \"$@\" | tr A-Z a-z`"
