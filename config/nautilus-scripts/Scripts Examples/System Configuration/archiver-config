#!/bin/bash
#
#
# Nautilus script -> Config for Archive Tool for Nautilus
#		     Make default config for archiver-unarchiver
#
# Owner 	: Largey Patrick Switzerland
#   		  patrick.largey@nazeman.org
#		  www.nazeman.org
#
# Licence : GNU GPL 
# 
# Copyright (C) Nazeman
#
# Dependency : gdialog (gnome-utils)  or Zenity
#	       archiver-unarchiver ;-)
#
# Encoding UTF-8
#
# Ver 0.9.3 Date 13.12.2003
# Add zenity ;-)
#
# Ver 0.9.2 Date 03,05,2003
# Update for Gnome 2.x
#
# Ver 0.9-1 Date 20.03.2002
# Some update and Brazilian portuguese from Rafael Rigues <rigues@terra.com.br>
#
# Ver 0.9 Date : 11.03.2002
# First release .... Configurator for archiver-unarchiver
#
		title="Config for Archiver-Unarchiver"
		compressormulti="Default archiver format for multiple files : "
		compressorsingle="Default archiver format for single file : "
		valid="available"
		notvalid="not available"
		format="format"
		choix="choice"
		noconfig="no config"
		info="information"
		rec="was created successfully."
case $LANG in
	fr* )
		title="Config de l'Archiveur-Desarchiveur"
		compressormulti="Format d'archive par défaut pour de multiples fichiers : "
		compressorsingle="Format d'archive par défaut pour fichier unique : "
		valid="disponible"
		notvalid="non disponible"
		format="extension"
		choix="choix"
		noconfig="ne pas configurer"
		info="information"
		rec="est enregistré";;
	de* )
		title="Konfigurator von Archiver-Desarchiver"
		compressormulti="Default Archiver Format für mehrere Dateien : "
		compressorsingle"Default archiver Format für ein Datei : "
		valid="Gültig"
		notvalid="Nicht gültig"
		format="Format"
		choix="Choice"
		noconfig="nicht konfigurieren"
		rec="ist gespeichert";;
	pt* )
		title="Configurador para o Compactador-Descompactador"
		compressormulti="Formato padrão para múltiplos arquivos : "
		compressorsingle="Formato padrão para um único arquivo : "
		valid="disponível"
		notvalid="não disponível"
		noconfig="não configurar"
		rec="foi criado com sucesso.";;
	es* )
		title="Configuración de Archivador-Desarchivador"
		compressormulti="Formato por defecto para varios ficheros : "
		compressorsingle="Formato por defecto para un solo fichero : "
		valid="disponible"
		notvalid="no disponible"
		noconfig="sin configuración"
		rec="se guardó correctamente";;
esac
#
# Test binary programm
#
if which tar 2> /dev/null
then 
	atar="$valid"
else
	atar="$notvalid"
fi
if which zip 2> /dev/null
then 
	azip="$valid"
else
	azip="$notvalid"
fi
if which gzip 2> /dev/null
then 
	agzip="$valid"
else
	agzip="$notvalid"
fi
if which bzip2 2> /dev/null
then 
	abzip2="$valid"
else
	abzip2="$notvalid"
fi
if which compress 2> /dev/null
then 
	acompress="$valid"
else
	acompress="$notvalid"
fi
if which rar 2> /dev/null
then 
	arar="$valid"
else
	arar="$notvalid"
fi
#
# Configure default extension for archiver-unarchiver
#
if which zenity 2>/dev/null
then 
#
# script with zenity
#
	if
		compres=`zenity --title "$compressorsingle" --width 400 --list --radiolist --column "$choix" --column "$format" --column "$info" FALSE ".zip" "$azip" FALSE ".gz" "$agzip" FALSE ".bz2" "$abzip2" FALSE ".Z" "$acompress" FALSE ".rar" "$arar" FALSE "X" "$noconfig"  2>&1`
	then
		compres=`echo $compres | sed 's/\"//g'`
		if [ "$compres" = "X" ]
		then 
			echo "" > ~/.archiver.conf
		else
			echo "single $compres" > ~/.archiver.conf
		fi		
	else
		exit 0
	fi
	if
		compres=`zenity --title "$compressormulti" --width 400 --list --radiolist --column "$choix" --column "$format" --column "$info" FALSE ".tar.gz" "$agzip" FALSE ".tar.bz2" "$abzip2" FALSE ".zip" "$azip" FALSE ".tar" "$atar" FALSE ".rar" "$arar" FALSE "X" "$noconfig" 2>&1`
	then
		compres=`echo $compres | sed 's/\"//g'`
		if [ "$compres" = "X" ]
		then
			echo "" >> ~/.archiver.conf
		else 
			echo "multi $compres" >> ~/.archiver.conf
		fi	
	else 
		exit 0
	fi
	zenity --title "$title" --info --text "~/.archiver.conf $rec"
else		
#
# script with gdialog
#
	if 
		compres=`gdialog --title "$title" --radiolist "$compressorsingle" 260 100 100 ".zip" "$azip" off ".gz" "$agzip" on ".bz2" "$abzip2" off ".Z" "$acompress" "off" ".rar" "$arar" "off" "X" "$noconfig" "off" 2>&1`
	then
		compres=`echo $compres | sed 's/\"//g'`
		if [ "$compres" = "X" ]
		then 
			echo "" > ~/.archiver.conf
		else
			echo "single $compres" > ~/.archiver.conf
		fi		
	else
		exit 0
	fi
	if
		compres=`gdialog --title "$title" --radiolist "$compressormulti" 260 200 100 ".tar.gz" "$agzip" on ".tar.bz2" "$abzip2" off ".zip" "$azip" off ".tar" "$atar" off ".rar" "$arar" "off" "X" "$noconfig" "off" 2>&1`
	then
		compres=`echo $compres | sed 's/\"//g'`
		if [ "$compres" = "X" ]
		then
			echo "" >> ~/.archiver.conf
		else 
			echo "multi $compres" >> ~/.archiver.conf
		fi	
	else 
		exit 0
	fi
	gdialog --title "$title" --msgbox "~/.archiver.conf $rec" 100 100 
fi
		
