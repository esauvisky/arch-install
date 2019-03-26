#!/bin/sh

for i in $*; do
        attachments=${attachments},${i}
done

# Get rid of the leading comma.
attachments=`echo $attachments | sed 's/^,//g'`

balsa -a "$attachments"

