#!/bin/bash
#
# Nautilus script -> Laucher media file with Xine
#
# Owner 	: Largey Patrick Switzerland
#   		  patrick.largey@nazeman.org
#			 www.nazeman.org
# 
# Licence : GNU GPL 
# 
# Copyright (C) Nazeman
#
# Ver :1.01 Date 09.07.2002 
# start xine without file://
#
# Ver :1.0 Date 04.02.2002
#
# Xine : http://xine.sourceforge.net/ 
#
video_file=""$PWD""/$1""
if [ -d "$1" ]
then 
	exit 0
else
	xine "$video_file"&
fi