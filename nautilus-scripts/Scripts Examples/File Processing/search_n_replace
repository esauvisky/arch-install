#!/bin/bash

#   FILE: search_n_replace -- 
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

SEARCH=`gdialog --title "Search For" --inputbox "Regular Expression" 200 450 2>&1`
REPLACE=`gdialog --title "Replace With" --inputbox "String" 200 450 2>&1`
TMP=`mktemp /tmp/search_n_replace.XXXXXX`

trap 'rm -f $TMP' EXIT SIGHUP SIGINT SIGTERM

for file in $*; do
        sed -e "s/$SEARCH/$REPLACE/g" $file > $TMP
        cp $file $file.bak
        mv $TMP $file
done