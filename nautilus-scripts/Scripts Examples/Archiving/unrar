#!/bin/sh
#
# This script unrars to a directory specified in gdialog and 
# redirects stdout to a log file.
#
# Distributed under the terms of GNU GPL version 2 or later
#
# Copyright (C) Keith Conger <acid@twcny.rr.com>
#
# Install in your ~/Nautilus/scripts directory.
# You need to be running Nautilus 1.0.3 +

UNRAR_PATH=/usr/local/bin	#Path to unrar binary.

DIR=$(gdialog --title "unrar to..." --inputbox "unrar to..." 200 350 ~/tmp/"$1" 2>&1)

mkdir $DIR

$UNRAR_PATH/unrar x -kb "$1" $DIR/ >> $DIR/"$1".log

gdialog --separate-output --title "unrar log" --textbox $DIR/"$1".log 50 70 2>&1
rm $DIR/"$1".log

