#!/bin/bash
# Description: Nautilus script that enqueues files in XMMS by the order selected
#
# Author: Celso Pinto <cpinto@yimports.com>
#
# Copyright (C) 2003 Celso Pinto
# Licence: GNU GPL
#
# Dependency: wc,bash,head,tail,xmms
#


#$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS - new line separated file paths; passed on by Nautilus on Gnome 2.2

echo "$NAUTILUS_SCRIPT_SELECTED_FILE_PATHS" > /tmp/xmmsselected
numlines=`wc -l /tmp/cpinto.xmmsselected | awk '{print $1}'`

for ((i=$numlines; i>0; i--))
do
        mediafile=`head -n$i /tmp/xmmsselected | tail -n1`        
        xmms -e $mediafile
done