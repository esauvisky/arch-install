#!/bin/sh
# Copyright (C) Sept 13, 2001 Shane Mueller <smueller@umich.edu>
# http://g-scripts.sourceforge.net
#
# pprint: This script designed for use with the Nautilus File Manager
# This script requires the unix utility enscript, and may require
# modification based upon your local printing command.
# It will either print directly to the default printer or
# will generate a pretty file from the selected text files, and either
# print to printer or generate files from selected files.
# 
# This does file-type sensitive selection.


# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Library General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.


#First, process each of the selected file

for arg
do
 filetype=$(file  "$arg")

   #Do file-type sensitive processing 
   case "$filetype" in 
        *text*)                    #Any type of Text file
         #This allows you to select how the file is processed  
         choice=`gdialog --menu "How should I process this file?" 200 200 4 '1' "Print" '2' "Make .ps" '3' "Make .html" '4' "Make .rtf" 2>&1`

        case $choice in
               1)   ##print using enscript
                 enscript -2 -G2rE -U1 --borders --word-wrap  "$arg"
               ;;

               2)   ##print to a .ps file of your choice 
                  NEWNAME=`gdialog --title "Generate Postscript File" --inputbox "Enter Filename (include extension)" 200 100 "$arg".ps 2>&1`
                  enscript -2 -G2rE -U1 --borders --word-wrap -p "$NEWNAME"  "$arg"
               ;;

               3)   ##Generate an .html
                  NEWNAME=`gdialog --title "Generate .html" --inputbox "Enter Filename (include extension)" 200 100 "$arg".html 2>&1`
                  enscript -E --color -W html -p "$NEWNAME"  "$arg"
               ;;

               4)   ##Generate an .rtf
                   NEWNAME=`gdialog --title "Generate .rtf" --inputbox "Enter Filename (include extension)" 200 100 "$arg".rtf 2>&1`     
                   enscript -E  -W rtf -p "$NEWNAME" "$arg"
               ;;

              *)   ##Don't do nothing-cancel key
               ;;
              esac

    
       ;;
          *postscript*)    ##send to printer directly
          lpr "$arg"
       ;;

       ##Other file types can go here if you know how to process them.

       *)
       gdialog --msgbox "Uncertain how to process file $arg: \n File type $filetype" 200 200

  esac

done