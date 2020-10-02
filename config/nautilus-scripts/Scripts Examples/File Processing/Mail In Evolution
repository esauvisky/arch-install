#!/usr/bin/perl -w
# By John Russell

# This script sends the selected file(s) with evolution.

use strict;

my $MAILTO_URL="mailto:?";
my @files = split("\n", $ENV{NAUTILUS_SCRIPT_SELECTED_FILE_PATHS});
my $count = 0;
foreach my $file (@files)
{
    if ( ! -f $file && ! -l $file )
    {
        my @dialog = ("gdialog","--title","Error","--msgbox", "\nError: Can not send $file.    \n\n    Only regular files can be mailed.    ","200", "300");
        system (@dialog);    
	}
	else    
	{
	   $MAILTO_URL = $MAILTO_URL . "attach=" . $file . "&";
           shift;        
	    $count += 1;    
	}
}


if ($count > 0)
{    
    my @command = ("evolution", $MAILTO_URL);
    system(@command);
}
