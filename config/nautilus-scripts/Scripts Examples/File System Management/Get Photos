#!/usr/bin/perl -w
# Created: Wed Dec 26 19:46:59 2001
# Last modified: Wed Dec 26 20:35:47 2001
# Time-stamp: <01/12/26 20:35:47 nevin>

## Copyright (C) 2001 by Nevin Kapur

## Author: Nevin Kapur <nevin@jhu.edu>

## This is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.

## This is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.

## Get photos from a digital camera. This script is meant to be run on
## a selected directory. It will silently fail till I get around to
## playing with gdialog.

## How to run gphoto; By default, this script will transfer everything
## on the default camera to the first selected directory. (I haven't
## experimented with what Nautilus thinks is the "first" directory if
## more that one directory is selected.)

my $GPHOTO = q[/usr/bin/gphoto2];
my @GPHOTO_OPTIONS = qw[ -q -P ];

## It is a shame that the scripts menu does not become active unless
## something is selected, otherwise we could have a version where the
## images would be magically appear in the current directory;


## It would be nice if one could assume the existence of these
## modules, but they are not bundled with Perl
## use URI;
## use URI::Escape;

## Silently discard the output if more that one directory is selected
my $uri = (split "\n", $ENV{NAUTILUS_SCRIPT_SELECTED_URIS})[0];

## Hack, hack, hack;
$uri =~ s[^file://][];

## From the URI::Escape man page:
$uri =~ s/%([0-9A-Fa-f]{2})/chr(hex($1))/eg;

## Only execute if what we got was a directory
if (-d $uri) {
  chdir $uri or die;
  system $GPHOTO, @GPHOTO_OPTIONS;
}

__END__

