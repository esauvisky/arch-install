#!/bin/bash
#
# You can select DV type2 stream and convert it into a vcd compliant
# mpeg.
#
# Distributed under the terms of GNU GPL version 2 or later
#
# Copyright (C) Keith Conger <acid@twcny.rr.com>
#
# This script is for use with Nautilus 1.0.3 + and mjpegtools(CVS).
# Optional: gnome-utils and Xdialog

# Set this to either Xdialog, gdialog or none.
DIALOG=Xdialog

#Directory for temporary files
TMP_DIR=~/tmp

if [ "$DIALOG" = "Xdialog" ]; then
	OUT_FILE=$(Xdialog --fselect ~/tmp 0 0 2>&1)
	(
	echo "0";
	lav2wav $1 |mp2enc -V -o $TMP_DIR/sound.mpg
	echo "35";
	lav2yuv $1|yuvscaler -O VCD|mpeg2enc -f 1 -r 16 -o $TMP_DIR/video.mpg
	echo "90";
	mplex -f 1 $TMP_DIR/sound.mpg $TMP_DIR/video.mpg -o $OUT_FILE
	echo "100";
	rm $TMP_DIR/sound.mpg $TMP_DIR/video.mpg
	)|
	Xdialog --title "Creating MPEG.." --gauge "Percent complete:" 8 30
elif [ "$DIALOG" = "gdialog" ]; then
	DIR=$(gdialog --title "MPEG file directory" --inputbox "Directory Location..." 200 450 ~/tmp/$1 2>&1)
	lav2wav $1 |mp2enc -V -o $TMP_DIR/sound.mpg
	lav2yuv $1|yuvscaler -O VCD|mpeg2enc -f 1 -r 16 -o $TMP_DIR/video.mpg
	mplex -f 1 $TMP_DIR/sound.mpg $TMP_DIR/video.mpg -o $DIR/$1.mpg
	rm $TMP_DIR/sound.mpg $TMP_DIR/video.mpg
else
	lav2wav $1 |mp2enc -V -o $TMP_DIR/sound.mpg
	lav2yuv $1|yuvscaler -O VCD|mpeg2enc -f 1 -r 16 -o $TMP_DIR/video.mpg
	mplex -f 1 $TMP_DIR/sound.mpg $TMP_DIR/video.mpg -o ./$1.mpg
	rm $TMP_DIR/sound.mpg $TMP_DIR/video.mpg
fi