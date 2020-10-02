#!/bin/bash
#
# Nautilus script -> make one tar.gz with the selected files
#
# Owner : Largey Patrick Switzerland
# 	  naze.man@bluewin.ch
#
# Licence : GNU GPL 
#
# Copyright (C) Nazeman
#
# Ver: 0.9.5-1
# Some correction in gdialog with ver 0.9.4
# thank's all for your job (sorry for my english)
#
# Ver: 0.9.4
# Date: 11.05.2001
# Support for swedish
# Don't create files with names like archive.tar.gz.tar.gz or archive.tgz.tar.gz
# If the input is just one file, the archive will be called <filename>.tar.gz as default
# Added by David Westlund
# 
# Ver: 0.9.3
# Date: 10.09.2001
# nazeman added file mit space !!!
#
# Ver: 0.9.2
# Date: Sept 9, 2001
# nazeman added confirm windows + German Support
#
#
# Ver: 0.9.1
# Date: Sept 5, 2001
# Shane Mueller added patch from Manuel Clos to add Spanish support
#
# Ver : 0.9
# Date : 11.08.2001
#
# Dependence : Nautilus (of course)
#	       Gnome-utils (gdialog)
#
case $LANG in
	fr* )
		filename="Nom du Fichier ?"
		fileexist="Fichier existant, écraser ?"
		title="Archiveur "
		archive="archive"
		rec="est enregistré" ;;
 	es* )
		filename="¿Nombre del archivo?"
		fileexist="El archivo ya existe, ¿sobreescribir?"
		title="Archivar en tar.gz" 
		archive="?????"
		rec="????" ;;
	de* )
		filename="Dateiname ?"
		fileexist="Datei existiert bereits, überschreiben ?"
		title="Archiv erstellen"
		archive="archiv"
		rec="ist gespeichert" ;;
	sv* )
		filename="Filnamn?"
		fileexist="Filen existerar, vill du skriva över?"
		title="tar.gz-arkiverare"
		archive="arkiv"
		rec="är sparad" ;;
	* )
		filename="File name ?"
		fileexist="File exist, owerwrite ?"
		title="tar.gz maker"
		archive="archive"
		rec="is saved" ;;
esac
if [ $# = 1 ]; then
	archive=`echo $1 | sed 's/.tar.gz//'`
fi
if
	nom=`gdialog --title "$title" --inputbox "$filename" 200 100 "$archive" 2>&1`
then
	nom=`echo $nom | sed 's/.tar.gz//'`
	while [ -f ./$nom.tar.gz ]
	do
		if
			gdialog --title "$title" --defaultno --yesno "$fileexist" 200 100 ;
		then
			while [ $# -gt 0 ]
				do
					files=`echo "$1" | sed 's/ /\\ /g'`
					if [ -f ./$nom.tar ]
					then 
                                                tar -rf ./$nom.tar "$files" ;
					else
						tar -cf ./$nom.tar "$files";
					fi
					shift
				done
			gzip -9f ./$nom.tar ;
			gdialog --msgbox "$PWD/$nom.tar.gz $rec" 200 100 ;
			exit 0 ;
		else
			if
				nom=`gdialog --title "$title" --inputbox "$filename" 200 100 "$archive" 2>&1`
			then
				continue ;
			else
				exit 0 ;
			fi
		fi
	done
	while [ $# -gt 0 ]
		do
			files=`echo "$1" | sed 's/ /\\ /g'`
			if [ -f ./$nom.tar ]
			then 
                                tar -rf ./$nom.tar "$files" ;
			else
				tar -cf ./$nom.tar "$files";
			fi
			shift
		done
	gzip -9 ./$nom.tar ;
	gdialog --msgbox "$PWD/$nom.tar.gz $rec" 200 100 ;
fi
