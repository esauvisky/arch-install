#!/bin/sh
# moveup:  moves the selected file(s) to parent directory
# (if able)
for arg 
do
  if [ -f ../"$arg" ]
  then
      MSG="Filename: '$arg' already exists in parent directory."
       if    
         gdialog --title "Overwrite?" --defaultno --yesno "$MSG" 200 100     
       then
         mv "$arg" ../"$arg"
       fi
  else
   mv "$arg" ../"$arg"
  fi
done

