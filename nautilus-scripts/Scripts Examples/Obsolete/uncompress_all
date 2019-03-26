#!/bin/bash
#
# Nautilus script -> Un Compress all format
#
# tar.gz ; tgz ; tar ; gz ; tar.bz2 ; bz2 ; zip ; rar are know
#
# Owner : Largey Patrick from Switzerland
# 	  naze.man@bluewin.ch
#
# Licence : GNU GPL 
#
# Copyright (C) Nazeman
# 
# Ver: 0.9.2
# Add rar format + error dialog
#
# Ver: 0.9.1
# Date: 11.05.2001
# Support for swedish
# Added by David Westlund
# 
# Ver: 0.9
# Date: 27.10.2001
#
# Dependence : Nautilus (of course)
#	       Gnome-utils (gdialog)
#
case $LANG in
	fr* )
		title="Decompacteur"
		beuh="format inconnu"
		ncompr="ne peut être décompressé"
		compr="est décompressé" ;;
	sv* )
		title="Packa upp"
		beuh="Okänt format"
		ncompr="kunde inte packas upp korrekt"
		compr="är uppackad" ;;
	* )
		title="Uncompress"
		beuh="Unknown format"
		ncompr="could not be decompressed"
		compr="is decompressed" ;;
esac
decompressed=""
errors=""
while [ $# -gt 0 ]
	do
		error=0
#		
# tar.gz format
#
		if 
			ext=`echo "$1" | grep [.]tar.gz$ 2>&1`
			[ "$ext" != "" ]
		then
			tar -xzf "$1" || error=1
#
# tgz format
#
		elif 
			ext=`echo "$1" | grep [.]tgz$ 2>&1`
			[ "$ext" != "" ]
		then
			tar -xzf "$1" || error=1
#
# tar format
#
		elif 
			ext=`echo "$1" | grep [.]tar$ 2>&1`
			[ "$ext" != "" ]
		then
			tar -xf "$1" || error=1
#
# gz format
#
		elif 
			ext=`echo "$1" | grep [.]gz$ 2>&1`
			[ "$ext" != "" ]
		then
			gunzip -N "$1" || error=1
#
# tar.bz2 format
#
		elif
			ext=`echo "$1" | grep [.]tar.bz2$ 2>&1`
			[ "$ext" != "" ]
		then
			tar -jxf "$1" || error=1
#
# bz2 format
#
		elif 
			ext=`echo "$1" | grep [.]bz2$ 2>&1`
			[ "$ext" != "" ]
		then
			bunzip2 -k "$1" || error=1
#
# zip format
#
		elif 
			ext=`echo "$1" | grep [.]zip$ 2>&1`
			[ "$ext" != "" ]
		then
			unzip "$1" || error=1
#
# rar format
#
		elif 
			ext=`echo "$1" | grep [.]rar$ 2>&1` 
			[ "$ext" != "" ]
		then
			unrar x -kb -o+ "$1" || error=1
#
# ??? format
#		
		else
			gdialog --title "$title" --msgbox "$1 $beuh" 200 100
			error=-1;
		fi	

		if [ $error != -1 ]; then
			if [ $error = 0 ]; then
				decompressed="$decompressed $1"
			else
				errors="$errors $1"
			fi
		fi

		shift
	done

if [ "$decompressed" != "" ]; then
	gdialog --title "$title" --msgbox "$decompressed $compr" 200 100
fi
	
if [ "$errors" != "" ]; then
	gdialog --title "$title" --msgbox "$errors $ncompr" 200 100
fi
