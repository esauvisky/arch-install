#!/usr/bin/perl -w

#########################################################################################
# Nautilus script for sorting home directory files.
#########################################################################################
#
# NAME:         junksorter.pl
#
# AUTHOR:	Brian Pepple <bdpepple@ameritech.net>
#
# DESCRIPTION:	This script sorts the selected files based on the Mime 
#               information, and moves the file to the appropriate 
#               folder. It will also sort mp3's based on the information
#               contained within their ID3 tag.
#
# REQUIREMENTS:	Nautilus file manager
#		Zenity, which replaces the venerable gdialog.
#               Shared Mime Info-0.12 : available at
#                      http://freedesktop.org/Software/shared-mime-info
#		Perl >= 5.8
#               Perl Modules: MP3::Tag, File::Copy, File::MimeInfo
#
# INSTALLATION:	GNOME 2.x: copy to the ~/.gnome2/nautilus-scripts directory,
#		
# USAGE:	Select the files that you would like to sort in Nautilus,
#		right click, go to Scripts, and then select this script. 
#		IF the file being moved would overwrite an existing file,
#               a dialog window will appear giving you the option to cancel
#               the action for that file.
#
# VERSION INFO: 0.8 (20031224) - Merged some switch cases, to reduce
#                                number of switches needed, and speed
#                                up script. 
#               0.7 (20031220) - Cleaned up switch statement.
#               0.6 (20031216) - Use enviroments $HOME value, instead of
#                                hard-coding the path.
#         	0.5 (20031212) - Added hack that will allow files on the
#                                users desktop to be handled correctly.
#                                If a directory is accidently selected the
#                                script will not move it.
#               0.4 (20031129) - Changed base location to default home,
#                                this will make it play better with the
#                                spatial version of Nautilus, that is in
#                                Gnome >= 2.5.0.  Also, added some error
#                                checking.
#               0.3 (20031128) - Replaced folder creation loop, and some
#                                minor clean up.
#               0.2 (20031127) - Added quick hack to add base folder.  Will
#                                clean this in later version.
#               0.1 (20031126) - Initial public release
#
# COPYRIGHT:	Copyright (C) 2003 Brian Pepple <bdpepple@ameritech.net>
#
# LICENSE:	GNU GPL
#
#########################################################################################

use MP3::Tag;
use File::Basename qw(basename);
use File::Copy qw(move);
use File::MimeInfo qw(mimetype);
use Switch;

use strict;

$|++; # Turn on autoflush

#########################################################################################
## EDIT THIS to suit your needs.
##
## Directory paths.
my $home = $ENV{'HOME'};
my $rpm = $home . '/rpms/';
my $deb = $home . '/debs/';
my $video = $home . '/video/';
my $iso = $home . '/iso/';
my $image = $home . '/images/';
my $document = $home . '/documents/'; # If you are using Ximian
                                      # change to 'Documents'
my $spreadsheet = $document . 'spreadsheets/';
my $webpage = $document . 'web/';
my $script = $document . 'scripts/';
my $template = $document . 'templates/';
my $font = $home . '/fonts/';
my $music = $home . '/music/';
my $archive = $home . '/archives/';

#########################################################################################
sub makedir {
    my $directory = (shift or "");

    # If directory already exist stop subroutine.
    return if -d $directory;

    mkdir $directory, 0700 
	or die "Problem creating directory $directory: $!\n";
}

sub taginfo {
    my $artist;
    my $album;
    my $temppath;

    # Create path information from ID3 tag.
    my $mp3 = MP3::Tag->new(@_);
    $mp3->get_tags;
    if (exists $mp3->{ID3v1}) {
	my $id3v1 = $mp3->{ID3v1};
	$artist = $id3v1->artist;
	$album = $id3v1->album;
	$temppath = $music . "$artist/$album/";
    } elsif (exists $mp3->{ID3v2}) {
	my $id3v2 = $mp3->{ID3v2};
	$artist = $id3v2->artist;
	$album = $id3v2->album;
	$temppath = $music . "$artist/$album/";
    } else {
	$artist = "misc";
	$temppath = $music . "$artist/";
    }
    $mp3->close();

    # Create folders for music files.
    my @folders = ($music, $music . $artist, $temppath);

    foreach (@folders) {
	unless (-d ($_)) {
	    makedir ($_);
	}
    }
    
    return $temppath;
}

#########################################################################################
## MAIN LOGIC
#########################################################################################

# If no file selected tell the user, and stop the script.
if (!@ARGV) {
    system "zenity", "--info", "--title", "No Files Selected", "--text",
    "Unable to run junksorter.pl No files were selected.";
    exit;
}

foreach (@ARGV) {
    # Starting variables.
    my $file;
    my $dir = $ENV{'NAUTILUS_SCRIPT_CURRENT_URI'};
    my $base = basename ($_);
    my $mime = mimetype($_);
    my $dest;

    #system "zenity", "--info", "--title", "Debug", "--text",
    #"Dir: $dir\nBase: $base\nMime: $mime";
    #exit;

    # Ugly hack to determine if the script is being ran from the Desktop.
    if ($dir =~ /x-nautilus-desktop/) {
	$file = $home . "/Desktop/" . $base;
    } else {
	if ($dir =~ /file:\/\/\//) {
	    $dir =~ s/file:\/\///;
	    $file = $dir  . '/' . $base;
	} else {
	    system "zenity", "--info", "--title", "Error", "--text",
	    "Unable to move selected file.  $dir is not a valid path.";
	    exit;
	}
    }

    # Start of switch statement, which determines the file type,
    # and determines where file should be moved. If type isn't here,
    # the file is move to $home/misc/ folder.
    switch ($mime) {
	case /video/                      {$dest = $video}
	case /image/                      {$dest = $image}
	case /audio/                      {$dest = &taginfo($file)}
	case /perl/                       {$dest = $script; &makedir($document)}
	case /x-python/                   {$dest = $script; &makedir($document)}
	case /x-ruby/                     {$dest = $script; &makedir($document)}
	case /x-shellscript/              {$dest = $script; &makedir($document)}
	case /x-tar/                      {$dest = $archive}
	case /x-gtar/                     {$dest = $archive}
	case /x-bzip/                     {$dest = $archive}
	case /x-bzip-compressed-tar/      {$dest = $archive}
	case /x-compress/                 {$dest = $archive}
	case /x-compressed-tar/           {$dest = $archive}
	case /x-gzip/                     {$dest = $archive}
	case /zip/                        {$dest = $archive}
	case /word/                       {$dest = $document}
	case /pdf/                        {$dest = $document}
	case /pgp/                        {$dest = $document}
	case /postscript/                 {$dest = $document}
	case /rtf/                        {$dest = $document}
	case /ms-excel/                   {$dest = $spreadsheet; &makedir($document)}
	case /ms-powerpoint/              {$dest = $document}
	case /ms-word/                    {$dest = $document}
	case /html/                       {$dest = $webpage; &makedir($document)}
	case /x-php/                      {$dest = $webpage; &makedir($document)}
	case /css/                        {$dest = $webpage; &makedir($document)}
	case /calc/                       {$dest = $spreadsheet; &makedir($document)}
	case /draw/                       {$dest = $spreadsheet; &makedir($document)}
	case /template/                   {$dest = $template; &makedir($document)}
	case /impress/                    {$dest = $document}
	case /math/                       {$dest = $spreadsheet; &makedir($document)}
	case /writer/                     {$dest = $document}
	case /x-amipro/                   {$dest = $document}
	case /stardivision.chart/         {$dest = $document}
	case /stardivision.mail/          {$dest = $document}
	case /x-asp/                      {$dest = $webpage; &makedir($document)}
	case /x-cd-image/                 {$dest = $iso}
	case /x-cgi/                      {$dest = $webpage; &makedir($document)}
	case /x-dia-diagram/              {$dest = $document}
	case /font/                       {$dest = $font}
	case /x-gnumeric/                 {$dest = $spreadsheet; &makedir($document)}
	case /x-jar/                      {$dest = $archive}
	case /x-rpm/                      {$dest = $rpm}
	case /x-deb/                      {$dest = $deb}
	case /x-mswrite/                  {$dest = $document}
	case /x-rar/                      {$dest = $archive}
	else                              {$dest = $home . '/misc/'}
    }

    # Create folders if they don't already exist.
    my @global_folders = ($dest);

    foreach (@global_folders) {
	unless (-d ($_)) {
	    makedir ($_);
	}
    }

    # Move the select files to appropriate folder,
    # ignoring any folders accidently selected.
    unless (-d $file) {
    	if (-e $dest . $base) {
	    # Ask the user if he wishes to overwrite file that already exists.
	    my $overwrite = system "zenity", "--question", "--title",
	    "File Exists", "--text",
	    "$base already exists in $dest.  Do you want to overwrite it?";
	
            # Zenity --question will return 0  when the  user presses OK.
	    if ($overwrite == 0) {
		move ($file, $dest . $base);
	    }
	} else {
	    move ($file, $dest . $base);
	}
    }
}
