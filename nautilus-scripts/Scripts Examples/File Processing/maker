#!/bin/sh

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
			mkdir tmp
			mv "$1" tmp
			cd tmp
			tar -xzf "$1" || error=1
			dir=`ls | cut -f 2 -d 'z'`
#
# tgz format
#
		elif 
			ext=`echo "$1" | grep [.]tgz$ 2>&1`
			[ "$ext" != "" ]
		then
			mkdir tmp
			mv "$1" tmp
			cd tmp
			tar -xzf "$1" || error=1
			dir=`ls | cut -f 2 -d 'z'`		
#
# tar format
#
		elif 
			ext=`echo "$1" | grep [.]tar$ 2>&1`
			[ "$ext" != "" ]
		then
			mkdir tmp
			mv "$1" tmp
			cd tmp
			tar -xf "$1" || error=1
			dir=`ls | cut -f 2 -d 'r'`	
#
# gz format
#
		elif 
			ext=`echo "$1" | grep [.]gz$ 2>&1`
			[ "$ext" != "" ]
		then
			mkdir tmp
			mv "$1" tmp
			cd tmp
			gunzip -N "$1" || error=1
			dir=`ls | cut -f 2 -d 'z'`	
#
# tar.bz2 format
#
		elif
			ext=`echo "$1" | grep [.]tar.bz2$ 2>&1`
			[ "$ext" != "" ]
		then
			mkdir tmp
			mv "$1" tmp
			cd tmp
			tar -jxf "$1" || error=1
			dir=`ls | cut -f 2 -d 'z'`	
#
# bz2 format
#
		elif 
			ext=`echo "$1" | grep [.]bz2$ 2>&1`
			[ "$ext" != "" ]
		then
			mkdir tmp
			mv "$1" tmp
			cd tmp
			bunzip2 -k "$1" || error=1
			dir=`ls | cut -f 2 -d 'z'`	
#
# zip format
#
		elif 
			ext=`echo "$1" | grep [.]zip$ 2>&1`
			[ "$ext" != "" ]
		then
			unzip "$1" || error=1
			dir=`ls | cut -f 2 -d 'z'`	
#
# rar format
#
		elif 
			ext=`echo "$1" | grep [.]rar$ 2>&1` 
			[ "$ext" != "" ]
		then
			mkdir tmp
			mv "$1" tmp
			cd tmp
			unrar x -kb -o+ "$1" || error=1
			dir=`ls | cut -f 2 -d 'r'`	
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

cd $NAUTILUS_SCRIPT_CURRENT_URI
cd $dir
./configure --prefix=/usr
make
gdialog --title "Maker" --msgbox "Compiled and made" 200 100

