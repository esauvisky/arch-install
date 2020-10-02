#!/bin/sh
# create-zip
# From: Manuel Clos   
# Nautilus script -> make one zip with the selected file
# 
# Dependence : Nautilus (of course)
#	       Gnome-utils (gdialog)
#
case $LANG in
	es* )
		filename="¿Nombre del archivo?"
		fileexist="El archivo ya existe, ¿sobreescribir?"
		title="Archivar en zip" ;;
	fr* )
		filename="Nom du Fichier ?" 
		fileexist="Fichier existant, écraser ?" 
		title="Archiveur zip" ;;
	* )
		filename="File name ?" 
		fileexist="File exist, owerwrite ?" 
		title="zip maker" ;;
esac
if
	nom=`gdialog --title "$title" --inputbox "$filename " 200 100 2>&1`
then 
	while [ -f ./$nom.zip ] 
		do
			if
				gdialog --title "$title" --defaultno --yesno "$fileexist" 200 100
			then
				zip -r ./$nom.zip $@ ;
				exit 0 ;
			else
				if
					nom=`gdialog --title "$title" --inputbox "$filename" 200 100 2>&1` 
				then
					next ;
				else 
					exit 0 ;

				fi
			fi
		done
	zip -r ./$nom.zip $@ ;
fi

