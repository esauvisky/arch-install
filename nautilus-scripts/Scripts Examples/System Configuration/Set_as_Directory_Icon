#!/usr/bin/perl
#
# Nautilus Script:
#   Set selected image as the current directory's icon
#
# Owner: 
#   Barak Korren
#   ifireball@yahoo.com
#
# Licence: GNU GPL
# Copyright (C) Barak Korren
#
# Change log:
#   Mon, Apr 05, 2004 - Created.
#
# Known Issues:
#   Nautilus needs to be restarted for changes to take effect.
#   The file set is the icon is arbitarily the last one passed by Nautilus.
#   No filetype checking is performed.
#

use XML::LibXML;

sub urify($) {
	my $str = shift;
	$str =~ s/([\/% ])/sprintf("%%%X", ord($1))/eg;
	return $str;
}

sub errorquit($) {
	exec "zenity --error --text='${_[0]}'";
	exit;
}

$su = $ENV{'NAUTILUS_SCRIPT_SELECTED_URIS'}
	or die('This script must be run from Nautilus!');
$cu = $ENV{'NAUTILUS_SCRIPT_CURRENT_URI'}
	or die('This script must be run from Nautilus!');

($icon) = ($su =~ m/([^\n]*$)/);
($metafile,$dir) = ($cu =~ m/(.*)\/([^\/]+)/);
$metafile = $ENV{'HOME'} . "/.nautilus/metafiles/" . urify($metafile) . ".xml";

if (-e $metafile) {
find mu		# If metafile exists, verify we can 
	# read and write it, then parse it
	if( -r $metafile && -w $metafile) {
		$mf = XML::LibXML->new()->parse_file($metafile);
		$de = $mf->documentElement();
	}
	else {
		errorquit("Can't edit metafile:\n$metafile");
	}
}
else {
	# If Metafile doesn't exist, make one
	$mf = XML::LibXML::Document->new();
	$de = $mf->createElement('directory');
	$mf->setDocumentElement($mf);
}

# See if we got a <file> element for the directory
if(@nodes = $de->findnodes("file[\@name=\"$dir\"]")) {		
	$fe = @nodes[0];
}
else {
	# If there isn't an element make it
	$fe = $mf->createElement("file");
	$fe->setAttribute("name", $dir);
	$de->appendChild($fe);
}

# Finally, set the custom_icon attribute
$fe->setAttribute("custom_icon", $icon);

# Now save our work
$mf->toFile($metafile, 0);
