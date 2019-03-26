#!/bin/bash

#   FILE: mail_file -- 
# AUTHOR: W. Michael Petullo <mike@flyn.org>
#   DATE: 31 May 2001
#
# Copyright (C) 2001 W. Michael Petullo <mike@flyn.org>
# All rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

# ============================= shrink_image () =============================== 
shrink_image()
{
	cp $1 $tmpdir
	tmpfile=${tmpdir}/`basename $1`
	mogrify -geometry '640x480>' $tmpfile
	echo ${tmpfile}
}

# ============================= main () ======================================= 
tmpdir=`mktemp -d /tmp/mail-image-XXXXXX`

trap 'rm -rf $tmpdir' SIGHUP SIGINT SIGTERM EXIT

if [ -z $MAILER ]; then
	MAILER=balsa
	MAILER_NEEDS_GNOME_TERMINAL=false
fi

for i in $*; do
	MAGIC=`file $i`
	echo $MAGIC
	case `echo $MAGIC | tr 'A-Z' 'a-z'` in
		*jpeg* )
			attachments="${attachments} -a `shrink_image $i`" ;;
		*gif* )
			attachments="${attachments} -a `shrink_image $i`" ;;
		*png* )
			attachments="${attachments} -a `shrink_image $i`" ;;
		*tiff* )
			attachments="${attachments} -a `shrink_image $i`" ;;
		* )
			attachments="${attachments} -a $i"
	esac
done

if [ x$MAILER_NEEDS_GNOME_TERMINAL = xtrue ]; then
	gnome-terminal -x $MAILER $attachments
else
	$MAILER $attachments
fi
