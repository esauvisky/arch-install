#!/bin/sh
# make_nautilus_script: copies the selected file(s) to ~/Nautilus/scripts
# and makes it executable.  It will overwrite without warning.
for arg 
do

 cp "$arg" ~/.gnome/nautilus-scripts/
 chmod u+x ~/.gnome/nautilus-scripts/"$arg"
 
done