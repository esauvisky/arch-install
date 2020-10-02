
#!/bin/bash
################################################################################
## Script: junksorter
## Author: Unknown
## Date: Unknown
## Category: File Utilities
################################################################################
## Description: This script will automatically sort files for you, into whatever
##              directories you want, under a root-level 'junk'directory.  For
##              seamless integration, make this ~/.junk and symlink directories
##              in there.  Includes detection of mp3s (requires mp3info), images,
##              movies, text and pdf documents, and various other stuff.
################################################################################
## Changes
## Author: Brian Pepple <bdpepple@ameritech.net>
## 09.06.2003 Modified mp3 section, and various clean-up.
## 
## Author: Vittorio Colao <vittorio(at)noldor.zapto.org>
## 26.12.2003 Added mp3 detection.
## 04.02.2004 Made it working under nautilus-2.x
################################################################################
## The home directory may need to be changed to a hard-coded path.
junk= ~/junk

msg="already exists in"
overwrite="Overwrite?"
file="File: "

for arg in $(echo $NAUTILUS_SCRIPT_SELECTED_URIS|sed 's/file:\/\///');
do
  artist="misc"
  album="." 
  new_artist=""
  new_album=""	

  filename="$arg"
  filetype=`file -b "$filename"`

  if [ -n "`echo $filetype | grep -i 'image' `" ]; then
      dest="$junk/images/"

  elif [ -n "`echo $filetype | grep -i 'rpm' `" ]; then
      dest="$junk/rpms/"

  elif [ -n "`echo $filename | grep -i 'svg' `" ]; then 
      dest="$junk/images/"

  elif [ -n "`echo $filetype | grep -i 'audio' `" ]; then 
      dest="$junk/audio/"

  elif [ -n "`echo $filename | grep -i 'MPG' `" ]; then 
      dest="$junk/video/"
	
  elif [ -n "`echo $filetype  |  grep -i 'MPEG' `" ]; then 
      dest="$junk/video/"
  
  elif [ -n "`echo $filetype | grep -i 'AVI' `" ]; then 
      dest="$junk/video/"

  elif [ -n "`echo $filetype | grep -i 'pdf' `" ]; then
      dest="$junk/documents/"

  elif [ -n "`echo $filetype | grep -i 'PostScript' `" ]; then
      dest="$junk/documents/"

  elif [ -n "`echo $filetype | grep -i 'Microsoft Office Document' `" ];
then
      dest="$junk/documents/"
	
  elif [ -n "`echo $filetype | grep -i 'Rich Text Format' `" ]; then
      dest="$junk/documents/"

  elif [ -n "`echo $filetype | grep 'TeX' `" ]; then
      dest="$junk/documents/"

  elif [ -n "`echo $filename | grep 'TeX' `" ]; then
      dest="$junk/documents/"

  elif [ -n "`echo $filetype | grep -i 'zip' `" ]; then
      dest="$junk/archives/"

  elif [ -n "`echo $filetype | grep -i 'script'`" ]; then
      dest="$junk/text/scripts/"

  elif [ -n "`echo $filetype | grep -i 'text' `" ]; then
      dest="$junk/text/"

  elif [ -n "`echo $filetype | grep -i 'MP3' `" ]; then
      new_artist="`mp3info -p "%a" "$filename"`"
      new_album="`mp3info -p "%l" "$filename"`"

      if [ ! -d "$junk/mp3" ]; then
	  mkdir -p "$junk/mp3"
      fi
      if [ -n "$new_artist" ]; then
	  artist="$new_artist"
	  if [ ! -d "$junk/mp3/$artist" ]; then
	      mkdir -p "$junk/mp3/$artist"
	  fi
      fi
      if [ -n "$new_album" ]; then
	  album="$new_album"
	  if [ ! -d "$junk/mp3/$artist/$album" ]; then
	      mkdir -p "$junk/mp3/$artist/$album"
	  fi
      fi 
      dest="$junk/mp3/$artist/$album/"
  else
      dest="$junk/misc/"
  fi
	
#Now, create the destination directory if it doesn't exist
  if [ ! -d $dest ]; then
      mkdir -p "$dest"
  fi

#Finally, move the file to the destination (if it doesn't exist there)
  if [ -f "$dest$filename" ]; then
      if gdialog --title "Overwrite?" --defaultno --yesno "$file
$filename $msg $dest $overwrite" 4 100; then
	  mv "$filename" "$dest"
      fi
  else
      mv "$filename" "$dest"
  fi
done
