#!/usr/bin/perl -w

# created on Mon Jul 16 17:21:44 EDT 2001
# Matt Doller <mdoller@wpi.edu>
# Alex Bennee <alex@bennee.com> (some additional hacks)
#
# some code is borrowed from a script i found on tigert's web site
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Library General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.


### Instructions for Use:
# 1. If used on a remote file system (e.g. NFS mount) you need to parse
# the NAUTILUS_URI environment variables to get your files.
#
# 2. Having two scripts do the same thing is wasteful (and cut and and
# paste error prone) so this script decides what its going to do based on
# the name of the script (so you symlink "rotate right" and "rotate left"
# to the same file).
#
# 3. Now need for a system call to remove files. unlink will work
#


use Gtk;
use strict;

(my $me = $0) =~ s|.*/(.*)|$1|;

set_locale Gtk;
init Gtk;

my $false = 0;
my $true = 1;

my $window;
my $box1;
my $box2;
my $label;
my $pbar;
my $button;
my $separator;
my $file;
my $filenum;
my $random_file;


# Create the window
$window = new Gtk::Window( "toplevel" );
$window->signal_connect( "delete_event", sub { Gtk->exit( 0 ); } );
$window->set_title( "Rotating JPEG Images..." );
$window->border_width( 0 );

$box1 = new Gtk::VBox( $false, 0 );
$box1->show();

$box2 = new Gtk::VBox( $false, 10 );
$box2->border_width( 10 );
$box1->pack_start( $box2, $false, $false, 0 );
$box2->show();
$window->add( $box1 );

# Create the label at the top of the window
$label = new Gtk::Label( "Rotating JPEG Images...\n" );
$box2->pack_start( $label, $false, $false, 0);
$label->show();

# Create the progress bar
$pbar = new Gtk::ProgressBar();
$box2->pack_start( $pbar, $true, $true, 0);
$pbar->show();

$separator = new Gtk::HSeparator();
$box1->pack_start( $separator, $false, $false, 0 );
$separator->show();

$box2 = new Gtk::VBox( $false, 10 );
$box2->border_width( 10 );
$box1->pack_start( $box2, $false, $true, 0 );
$box2->show();

# Create the close button
$button = new Gtk::Button( "Cancel" );
$button->signal_connect( "clicked", sub { Gtk->exit( 0 ); } );

$box2->pack_start( $button, $true, $true, 0 );
$button->can_default( $true );
$button->grab_default();
$button->show();


$window->show();

Gtk->main_iteration while ( Gtk->events_pending );

# Decide what command we are executaing based on the calling
# name of the script (so we can symlink version)
my $command = "jpegtran -copy all ";
my $direction;

if ( $me =~ /right/ )
{
    $command = $command." -rotate 90 ";
    $direction = "Right";
} else {
    $command = $command." -rotate 270 ";
    $direction = "Right";
}

# set up loop to go through files passed to script
# rotate each script, increment the file number, and then update the status
# for now, assume that they are all jpegs, and do not put up a warning

$filenum = 0;

$random_file = "/tmp/rotate-image-" . time;
my @filelist;

# test for argv as Nautilus could just use URI's
if (@ARGV) {
    @filelist=@ARGV;
} else {
    #extract files from NAUTILUS_SCRIPT_SELECTED_URIS
    @filelist = split ("\n", $ENV{NAUTILUS_SCRIPT_SELECTED_URIS} );
}

foreach $file (@filelist) {
    $file =~ s|^file://||; # drop any file://
    ++$filenum;
    $label->set_text( "Rotating JPEG Image $direction:\n$file" );
    $pbar->set_value( ( 100 * $filenum ) / ( scalar(@filelist) + 1 ) );
    system( "$command \"$file\" 2>&1 > $random_file" );
    if ( $? == 0 ) 
    {
        system( "mv -f $random_file \"$file\"" );
    }
    else
    {
        # an error occurred in the jpegtran... for now, just leave it
        # alone. we can analyze the error, and put up a dialog
        # as soon as i figure out how to do that with gtk-perl (well)
    }
    print LOG "File:",$file,"\n";
    unlink $random_file;
    Gtk->main_iteration while ( Gtk->events_pending );
}

$pbar->set_value(100);

$button->child->set( "Done" );

main Gtk;
exit( 0 );
