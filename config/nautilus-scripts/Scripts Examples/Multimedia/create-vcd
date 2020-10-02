#!/bin/sh
#
# You can select multiple mpegs in Nautilus and and create a VCD CD image in bin/cue format.
#
# Distributed under the terms of GNU GPL version 2 or later
#
# Copyright (C) Keith Conger <acid@twcny.rr.com>
#
# This script is for use with Nautilus 1.0.3 + and GNU VCDImager 0.7.x +.

VCDIMGR_PATH=/usr/local/bin	#Path to vcdimager binary

LABEL=$(gdialog --title "VCD Volume Label?" --inputbox "Volume Label.." 200 450 VCD 2>&1)
DIR=$(gdialog --title "VCD Image Directory?" --inputbox "Directory Location..." 200 450 ~/tmp/$1 2>&1)

mkdir $DIR

vcdimager --iso-volume-label=$LABEL --bin-file=$DIR/$1.bin --cue-file=$DIR/$1.cue $NAUTILUS_SCRIPT_SELECTED_FILE_PATHS >> $DIR/$1.log

gdialog --separate-output --title "VCD Imager log" --textbox $DIR/$1.log 50 70 2>&1
rm $DIR/$1.log

