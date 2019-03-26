#!/bin/sh
#
# Nautilus script -> Launch gnome-terminal as root using Xsu
#
# Author: Dan Whitfield
#         danrw.geo@yahoo.com
#         http://www.geocities.com/danrw.geo/
# 
# License: free (public domain)
#
# Date: 20.02.2002
#
# Xsu: http://freshmeat.net/projects/xsu/ or http://xsu.freax.eu.org/
#
#
# This script uses Xsu (http://xsu.freax.eu.org/)to allow
# you to su to a specific username and password and then,
# open a gnome-terminal in the directory you select.
# The default user is root.
# Install this script in your ~/.gnome/nautilus-scripts or
# ~/.gnome/nautilus-scripts/Execute directory.

cd $NAUTILUS_SCRIPT_CURRENT_URI
xsu -c "gnome-terminal" -u "root" -m "To run the gnome-terminal with root access,^Enter the root password below." -i "/usr/share/pixmaps/gnome-terminal.png"
