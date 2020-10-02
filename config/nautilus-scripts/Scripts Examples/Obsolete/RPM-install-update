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
case $LANG in
	fr* )
	title="Rpm installation ou mise à jour"
	rpminstaller="Que voulez-vous faire ?"
	install="installation"
	update="mise à jour"
	info="information";;
esac	
		
filesall=""
while [ $# -gt 0 ]
	do
		files=`echo "$1" | sed 's/ /\?/g'`
		filesall="$files $filesall"
		shift
	done
admin=`whoami`
if 
	rpmchoise=`gdialog --title "$title" --radiolist "$rpminstaller" 260 100 5 "-i" "$install" off "-U" "$update" on "-qp" "$info" off 2>&1`
then
	case $rpmchoise in
		-i ) 
			if [ $admin = root ]
			then 
				gnorpm -i $fileall&
			else	
				gnorpm-auth -i $filesall&
			fi;;	
		-U )
			if [ $admin = root ]
			then 
				gnorpm -U $fileall&
			else	
				gnorpm-auth -U $filesall&
			fi;;	
		-qp )
			if [ $admin = root ]
			then 
				gnorpm -qp $fileall&
			else	
				gnorpm-auth -qp $filesall&
			fi;;
	esac
else
	exit 0
fi