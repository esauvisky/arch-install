#!/bin/bash
#
# Nautilus script -> Install or Update Rpm with gnorpm
#
# Owner : Largey Patrick from Switzerland
#   	  patrick.largey@nazeman.org
#		 www.nazeman.org
#
# Licence : GNU GPL 
#
# Copyright (C) Nazeman
#
# Ver: 1.04 
# Remove nodeps option don't work with gnorpm
#
# Ver: 1.03
# Add check if one Rpm is selected or not
#
# Ver: 1.02
# Add spanish translation by Manuel Clos <llanero@jazzfree.com>
#
# Ver: 1.01
# Bug fix with user root + add possibilty to install or update with nodeps
# 
# Ver: 1.0  Date: 31.03.2002
# Initial release
#
# Dependence : Nautilus (of course)
#			  Gdialog (Gnome-utils)
#			  Gnome-Rpms (gnorpms)
#
	title="Rpm Installer-Updater"
	rpminstaller="What do you want to make ?"
	install="install"
	update="update"
	info="information"
	dontrpm="That's not a RPM package !"
case $LANG in
	fr* )
		title="Rpm installation ou mise à jour"
		rpminstaller="Que voulez-vous faire ?"
		install="installation"
		update="mise à jour"
		info="information"
		dontrpm="Ce n'est pas un paquet RPM !";;
	es* )
		title="Instalador-Actualizador de Rpm"
		rpminstaller="¿ Qué desea hacer ?"
		install="instalar"
		update="actualizar"
		info="información";;
esac	
		
filesall=""
testrpm=`file -b "$1" | grep 'RPM'`
while [ $# -gt 0 ]
	do
		files=`echo "$1" | sed 's/ /\?/g'`
		filesall="$files $filesall"
		shift
	done
admin=`whoami`
if [ "$testrpm" != "" ]
then
	if 
		rpmchoise=`gdialog --title "$title" --radiolist "$rpminstaller" 200 150 9 "-i" "$install" off "-U" "$update" on "-qp" "$info" off 2>&1`
	then
		case $rpmchoise in
			-i ) 
				if [ $admin = root ]
				then 
					gnorpm -i $filesall&
				else	
					gnorpm-auth -i $filesall&
				fi;;	
			-U )
				if [ $admin = root ]
				then 
					gnorpm -U $filesall&
				else	
					gnorpm-auth -U $filesall&
				fi;;	
			-qp )
				if [ $admin = root ]
				then 
					gnorpm -qp $filesall&
				else	
					gnorpm-auth -qp $filesall&
				fi;;
		esac
	else
		exit 0
	fi
else
	gdialog --title "$title" --msgbox "$dontrpm" 250 100
fi	