
#!/bin/bash
# "Shredder" secure file delete for Nautilus
# Distributed under the terms of GNU GPL version 2 or later
# Copyright (C) James Jones <jcjones@ufl.edu>
#
# Dependency : gdialog (gnome-utils) 
#          � : shred (Colin Plumb's)
#
# From shred's info file, wise words:
#
# Please note* that `shred' relies on a very important assumption:
# that the filesystem overwrites data in place.  This is the traditional
# way to do things, but many modern filesystem designs do not satisfy
# this assumption.
#
# Exceptions exist, and are noted in shred's info manual. 
# Type 'info shred' from a prompt to see the list. 

SHRED_PATH=/usr/bin                        #Path to shred binary.

if dialog=`gdialog --title "$1" --yesno "Are you sure you want to shred
$1" 100 200 --defaultno`
then
  $SHRED_PATH/shred -zu "$1"
fi

