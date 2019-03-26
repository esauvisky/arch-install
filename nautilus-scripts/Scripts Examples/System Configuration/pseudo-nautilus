#/bin/bash
## This is a "PSEUDO-NAUTILUS" general script.
## To run a "Nautilus" script without Nautilus, change COMMAND 
## to the script of your choice. This will set all important 
## environment variables that a script is likely to use, as
## well as assuring the script executes in the proper directory 
##
## To use: Create a launcher in the panel, or a .desktop file that executes
## this script.  By dragging selected files to this launcher, the script 
## will run on the selected files in the directory of the files.
##
##
## Placed in the public domain April, 2002 by Shane T. Mueller
## 
##
## Version 1.1       Apr 5, 2002    Additional fixes for files with spaces in their names, with 
                                     thanks to Patrick Largey.
## Version 1.0       April 1, 2002  Initial Release.
SCRIPTNAME=~/.gnome/nautilus-scripts/scriptname

shortnames=""
longnames=""
urls=""

for arg in "$@"
do
  #Make sure that the url starts with the proper type: if the url starts with
  ## '/', change it to 'file:///'
  url=`echo "$arg"| sed  's/^\//file:\/\/\//'`

  ##find the long name of the file (absolute path)
  longname=`echo "$url" |  sed -e 's/file:\/\///g'`

  ## This crazy line translates all of the %20-like url characters into their escaped
  ##  \ actual characters.  I wish I could find a cleaner way to do this.
  longname=`echo "$longname" | sed  -e 's/\%23/\#/g' -e 's/\%20/\ /g' -e 's/\%24/\$/g' -e 's/\%25/\%/g' -e 's/\%35/\?/g'  -e 's/\%3B/\;/g' -e 's/\%3C/\</g'  -e 's/\%3E/\>/g' -e 's/\%40/\@/g' -e 's/\%5B/\[/g' -e 's/\%26/\&/g' -e 's/\%2C/\,/g' -e 's/\%5E/\^/g' -e 's/\%5D/\]/g' -e 's/\%60/\`/g'  -e 's/\%7B/\{/g'  -e 's/\%7C/\|/g'  -e 's/\%7D/\}/g' -e 's/\ /\?/g'`
  # This translation doesn't work.  
  #  -e 's/\%5C/\\/g'`
  
  ##find the short name of the file (filename only)
  shortname=`basename "$longname"`
 
  ##Mush the individual entries into a single strings
  urls="$url $urls"
  shortnames="$shortname $shortnames" 
  longnames="$longname $longnames"
done

## extract the base URI
URI=`echo "$1" | sed -e 's/\/[^\/]*$//' -e 's/^\//file:\/\/\//'`

## Find the directory of the first item and go there
DIR=`echo "$1" | sed -e 's/^file:\/\///g'`
DIR=`dirname "$DIR"`
cd $DIR

#Export the environment variables that nautilus sets
export NAUTILUS_SCRIPT_SELECTED_FILE_PATHS=$longnames
export NAUTILUS_SCRIPT_SELECTED_URIS=$urls
export NAUTILUS_SCRIPT_CURRENT_URI=$URI
export NAUTILUS_SCRIPT_WINDOW_GEOMETRY="800x500+10+10"


#Execute the proper script if anything was actually passed to this script
if [ -n "$1" ]
then
  "$SCRIPTNAME" $shortnames
fi