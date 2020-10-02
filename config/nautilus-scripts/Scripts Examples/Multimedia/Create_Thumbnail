#!/bin/bash
#
# Nautilus script -> Create big Thumbnails (upto 200x200) for selected files
#
# Owner 	: Hans-Bernhard Trütken
# 	    	hb.truetken@htp-tel.de
# 
# Licence : GNU GPL 
# 
# Ver :1.0 Date 06.03.2002
#
# angelehnt an: http://www-user.tu-chemnitz.de/~kbo/linux/shellskript/conv.htm
#
# Dependency : ImageMagick, GNU shell utilities

for Datei in $*
do
    if [ -f $Datei ]
    then
        echo "Bearbeite Datei $Datei ..."
        DateiName=`basename $Datei`
  	    DirName=`dirname $Datei`/.thumbnails
        convert -geometry 200x200  $Datei $DirName/$DateiName.png
    fi
done

exit 0
