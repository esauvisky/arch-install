#!/bin/bash
#
#
# Nautilus script -> Install Galeon Theme (Uses Archiver-Unarchiver)
#
# Install Galeon Theme Owner: Matthew Hall
#				nyquist@ntlworld.com
#				http://people.ecsc.co.uk/~matt/
#		
# Archiver-Unarchiver Owner 	: Largey Patrick Switzerland
# 	    	naze.man@bluewin.ch
#			 www.homepage.swissonline.ch/nazeman
# Archiver-Unarchiver Co-Owner  : David Westlund
#			 daw@wlug.westbo.se
# 
# Licence : GNU GPL 
# 
# Default language
#
		filename="File name?"
		fileexist="File exists. Overwrite?"
		title="Archiver-Unarchiver"
		archive="archive"
		compressor="extension:  archive: "
		decompressor="Do you want to uncompress: "
		valid="available"
		notvalid="not available"
		pleasewait="Please wait...."
		warning="Warning!"
		beuh="Unknown format."
		ncompr="could not be uncompressed."
		compr="has been uncompressed."		
		rec="was created successfully."
		overwrite="The following files will be overwritten: "
		proceed=". Do you want to proceed?" 
		theme="Theme"
		installer="Installer"
		installed="Installed"
		
		
case $LANG in
	fr* )
		filename="Nom du Fichier ?"
		fileexist="Fichier existant, écraser ?"
		title="Archiveur-Desarchiveur"
		archive="archive"
		decompressor="Voulez vous désarchiver : "
		compressor="Extension de l'archive : "
		valid="disponible"
		notvalid="non disponible"
		pleasewait="Veuillez patientez ....."
		warning="! Attention !"
		beuh="format inconnu"
		ncompr="ne peut être décompressé"
		compr="est décompressé"		
		rec="est enregistré" 
		overwrite="les fichiers suivant seront écrasé: "
		theme="Thème"
		installer="Installateur"
		installed="Installé"
		proceed=". Voulez-vous poursuirvre ?" ;;
 	es* )
		filename="¿Nombre del archivo?"
		fileexist="El archivo ya existe, ¿sobreescribir?"
		title="Archivar" 
		archive="archivo"
		compressor="¿extensión del archivo?"
		decompressor="¿ Quiere descomprimir "
		valid="disponible"
		notvalid="no disponible"
		pleasewait="Por favor, espere..."
		warning="¡ Cuidado !"
		beuh="Formato desconocido"
		ncompr="no se puede descomprimir"
		compr="se descomprimió correctamente."	
		rec="se creó correctamente" 
		overwrite="los archivos suiguientes serán sobreescritos: "
		theme="Tema"
		installer="Instalador"
		installed="Instalado"
		proceed=". ¿ Quiere continuar ?" ;;
	de* )
		filename="Dateiname ?"
		fileexist="Datei existiert bereits, überschreiben ?"
		title="Archiver-Desarchiver"
		archive="archiv"
		compressor="Extension von Archiv : "
		decompressor="wollen Sie dekomprimieren : "
		valid="Gültig"
		notvalid="Nicht gültig"
		pleasewait="Bitte warten ...."
		warning="! Warnung !"
		beuh="unbekanntes Format"
		ncompr="kann nicht dekomprimieren"
		compr="ist komprimiert"		
		rec="ist gespeichert" 
		overwrite="soll(en) diese Datei(en) überschriebenerden: "
		theme="Thema"
		installer="Installateur"
		installed="Installiert"
		proceed="Wollen Sie weitermachen ?" ;;
	eo* )
		filename="Dosiera nomo?"
		fileexist="Dosiero ekzistas.  Æu superskribu?"
		title="Ar¶igilo-Malar¶ivigilo"
		archive="ar¶ivo"
		compressor="Fina¼o de la ar¶ivo?"
		decompressor="Æu vi volas malar¶ivigi: "
		valid="havebla"
		notvalid="nehavebla"
		pleasewait="Bonvolu atendi..."
		warning="Avertu!"
		beuh="Nekonata formato"
		ncompr="Ne povis kompresigi"
		compr="estas kompresigita"
		rec="øuste kreita"
		overwrite="La sekvantaj dosieroj superskribiøos: "
		theme=""
		installer=""
		installed=""
		proceed=".  Æu vi volas procedi?";;
	pt* )	
		filename="Nome do arquivo?"
		fileexist="O arquivo já existe. Sobrescrever?"
		title="Compactador-Descompactador"
		archive="arquivo"
		compressor="extensão:  arquivo: "
		decompressor="Você quer descompactar: "
		valid="disponível"
		notvalid="não disponível"
		pleasewait="Aguarde...."
		warning="Aviso!"
		beuh="Formato desconhecido."
		ncompr="não pôde ser descompactado."
		compr="foi descompactado."              
		rec="foi criado com sucesso."
		overwrite="Os seguintes arquivos serão sobrescritos: "
		theme=""
		installer=""
		installed=""
		proceed=". Deseja continuar?" ;;
	sv* )
		filename="Filnamn?"
		fileexist="Filen existerar, vill du skriva över?"
		title="tar.gz-arkiverare"
		compressor="Filändelse arkiv :"
		decompressor="Vill du packa upp : "
		archive="arkiv"
		#valid="????"
		#notvalid="????"
		pleasewait="Var god vänta..."
		warning="! Varning !"
		beuh="Okänt format"
		ncompr="kunde inte packas upp korrekt"
		compr="är uppackad"             
		rec="är sparad" 
		overwrite="Följande filer kommer skrivas över: "
		theme=""
		installer=""
		installed=""
		proceed=". Vill du fortsätta?" ;;
	et* )
		filename="Faili nimi?"
		fileexist="Fail on juba olemas. Kas kirjutada üle?"
		title="Arhivaator"
		archive="arhiiv"
		compressor="laiend:    arhiiv: "
		decompressor="Kas sa tahad lahti pakkida: "
		valid="võimalik"
		notvalid="ei ole võimalik"
		pleasewait="Palun oota...."
		warning="Hoiatus!"
		beuh="Tundmatu vorming."
		ncompr=": ei saa lahti pakkida."
		compr="lahti pakitud."
		rec="edukalt loodud."
		overwrite="Järgnevad failid kirjutatakse üle: "
		theme=""
		installer=""
		installed=""
		proceed=". Kas tahad jätkata?" ;;
esac
#
# check the config file
#
if [ ! -f ~/.archiver.conf ]
then echo "" > ~/.archiver.conf
fi
#
# test archive or not
#
test_arch1=`file -b "$1" | grep 'archive'`
test_arch2=`file -b "$1" | grep 'compress'`
test_arch="$test_arch1$test_arch2"
if [ "$test_arch" != "" ] 
then
#
# is one archive -> decompress
#
	decompressed=""
	errors=""
	if gdialog --title "$title" --yesno "$decompressor $1 ?" 100 100
	then
		while [ $# -gt 0 ]
			do
			error=0
			if 
				ext=`echo "$1" | grep [.][tT][aA][rR].[gG][zZ]$ 2>&1`
				[ "$ext" != "" ]
			then
						tar -xzf "$1" || error=1
						dir=`ls | cut -f 2 -d 'z'`
				
			elif 
				ext=`echo "$1" | grep [.][tT][gG][zZ]$ 2>&1`
				[ "$ext" != "" ]
			then
						tar -xzf "$1" || error=1
						dir=`ls | cut -f 2 -d 'z'`
			elif 
				ext=`echo "$1" | grep [.][tT][aA][rR]$ 2>&1`
				[ "$ext" != "" ]
			then
						tar -xf "$1" || error=1
						dir=`ls | cut -f 2 -d 'z'`
			elif 
				ext=`echo "$1" | grep [.][gG][zZ]$ 2>&1`
				[ "$ext" != "" ]
			then
						gunzip -fN "$1" || error=1
						dir=`ls | cut -f 2 -d 'z'`
			elif
				ext=`echo "$1" | grep [.][tT][aA][rR][.][bB][zZ]2$ 2>&1`
				[ "$ext" != "" ]
			then
						tar -jxf "$1" || error=1
						dir=`ls | cut -f 2 -d 'z'`
			elif 
				ext=`echo "$1" | grep [.][bB][zZ]2$ 2>&1`
				[ "$ext" != "" ]
			then
						bunzip2 -fk "$1" || error=1
						dir=`ls | cut -f 2 -d 'z'`
			elif	
				ext=`echo "$1" | grep [.][zZ][iI][pP]$ 2>&1`
				[ "$ext" != "" ]
			then
						unzip -o "$1" || error=1
						dir=`ls | cut -f 2 -d 'z'`
			elif 
				ext=`echo "$1" | grep [.][rR][aA][rR]$ 2>&1` 
				[ "$ext" != "" ]
			then	
						unrar x -kb -o+ "$1" || error=1
						dir=`ls | cut -f 2 -d 'z'`
			elif 
				ext=`echo "$1" | grep [.][zZ]$ 2>&1`
				[ "$ext" != "" ]
			then 
						uncompress -f "$1" || error=1
						dir=`ls | cut -f 2 -d 'z'`
			elif
				ext=`echo "$1" | grep [.][aA][cC][eE]$ 2>&1`
				[ "$ext" != "" ]
			then 
				unace -e "$1" || error=1		
			else
				gdialog --title "$title" --msgbox "$1 $beuh" 200 100
				error=-1
			fi	
			if [ $error != -1 ]
			then
				if [ $error = 0 ]
				then
					decompressed="$decompressed $1"
				else
					errors="$errors $1"
				fi
			fi
			shift
		done
	else 
		exit 0
	fi	
else 

#
# test if programm are availlable
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
fi

#Copy unpackaged theme to galeon theme directory

admin=`whoami`
if [ $admin = root ]
then 
	cp -R $dir /usr/share/galeon/themes/
else
	if [ -d ~/.galeon/themes ]
	then
		mv $dir ~/.galeon/themes/$dir
	else 
		mkdir ~/galeon/themes
		mv $dir ~/.galeon/themes/$dir
	fi
fi

#optionally remove directory (off by default)
#rm -rf $dir

#optionally remove package (off by default)
#rm -f $1

	if [ "$decompressed" != "" ]
	then
		gdialog --title "Galeon $theme $installer & $title" --msgbox "$theme $installed" 200 100
	fi
	if [ "$errors" != "" ] 
	then
		gdialog --title "$title" --msgbox "$errors $ncompr" 200 100
	fi

