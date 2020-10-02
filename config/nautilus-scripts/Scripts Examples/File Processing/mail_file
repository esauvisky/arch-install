#!/bin/bash
#
# TODO: Fix the problem with space in the name in a better way
#       (which may be any other possible way at all...)
#
case $LANG in
	sv* )
		EMAILADDR='Epost-addresser'
		WRITEMESSAGE='Skriv meddelande'
		SUBMES='Skriv meddelande (Ämne:Meddelande)'
		SEND='Skicka';;
	* )
		EMAILADDR='Email addresses'
		WRITEMESSAGE='Write message'
		SUBMES='Write message (subject:message)'
		SEND='Send';;
esac

EMAILS="`gdialog --title "$EMAILADDR" --inputbox "$EMAILADDR" 200 100 2>&1`"
echo $EMAILS
MESSAGE="`gdialog --title "$SUBMES" --inputbox "$WRITEMESSAGE" 200 100 2>&1`"
echo $SUBMES

FILES=""
while [ $# -gt 0 ]; do
	FILE=$PWD/$1
	FILE=`echo $FILE | sed 's/ /\?/g'`
	FILES="$FILES $FILE"
	shift
done


SUBJECT=`echo $MESSAGE | sed 's/:.*//'`
MESSAGE=`echo $MESSAGE | sed 's/.*://'`

echo "$MESSAGE" | uuenview -a $FILES -s "$SUBJECT" -b -m "$EMAILS"
