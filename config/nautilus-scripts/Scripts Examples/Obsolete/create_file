#!/usr/bin/perl -w
#
# Released under the terms of GNU GPL v 2.0 or later
#
# Copyright (C) David Westlund
#
# You will need libgtk-perl to run this program.
#
# NOTE: This script is a little buggy, and doesn't operate as expected.
# Please contribute any bugfixes to smueller@umich.edu.
#
# Config
$template_directory = $ENV{HOME} . "/Nautilus/skript/.mallar/";

# For Gtk
use Gtk;

init Gtk;
set_locale Gtk;

# For cwd, used to get the current directory
use Cwd;

my $true = 1;
my $false = 0;

# These will be used as gtk-widgets
my $window;
my $vbox;
my $hbox_1;
my $hbox_2;
my $filename_label;
my $filename_entry;
my $create_button;

# This are for the menu;
my $opt;
my $menu;
my @menu_item;
# Non-widgets for the menus...
my $i;
my $application;
my $end;

#Other variables
my $cwd = cwd;

# The gtk-signals
my $signal;


$window = new Gtk::Window( 'toplevel' );
$signal = $window->signal_connect( 'delete_event', sub { Gtk->exit( 0 ); } );
$window->border_width( 5 );
$window->set_title( "Create file" );

$vbox = new Gtk::VBox ( $false, 0 );
$window->add( $vbox );
$vbox->show ();


$hbox_1 = new Gtk::HBox ( $false, 0 );
$vbox->pack_start ($hbox_1, $false, $false, 0);
$hbox_1->show();


$filename_label = new Gtk::Label ( "Filename: " );
$hbox_1->pack_start ($filename_label, $false, $false, 0);
$filename_label->show();

$filename_entry = new Gtk::Entry ();
$hbox_1->pack_start ($filename_entry, $false, $false, 0);
$filename_entry->set_usize ( 100, undef );
$filename_entry->show();


# Row nr two
$hbox_2 = new Gtk::HBox ( $false, 0 );
$vbox->pack_start ($hbox_2, $false, $false, 0);
$hbox_2->show();


# Create the button
$create_button = new Gtk::Button ( "Create file" );
$create_button->signal_connect ('clicked', \&create_file );
$hbox_2->pack_start ($create_button, $false, $false, 0);
$create_button->show();



# Creating the menu
$opt = new Gtk::OptionMenu ();
$menu = new Gtk::Menu ();

$i = 0;
chdir $template_directory;
while (<*>) {
	$application = $_;
	$end = $_;
	$application  =~ s/\..*//;
	$end =~ s/$application//;

	$menu_item[$i] = new Gtk::MenuItem ( "$application" );
	$menu_item[$i]->signal_connect ( 'activate', \&create_app_file, $application, $end);
	$menu->append ($menu_item[$i]);
	$menu_item[$i]->show ();
	$i++;
}
$opt->set_menu ($menu);
$opt->show ();

$hbox_2->pack_start ($opt, $false, $false, 0);


$window->show ();
main Gtk;

sub create_file
{
	my $filename;

	$filename = $filename_entry->get_text ();

	$filename = $cwd . "\/$filename";

	system (": > $filename");

	Gtk->exit (0);
}

sub create_app_file
{
	my ($info, $application, $end) = @_;
	my $filename;
	my $template;
	$filename = $filename_entry->get_text ();

	$filename = $filename . $end;
	$filename = $cwd . "\/$filename";

	$template = $application . $end;

	system ("cp $template_directory/$template $filename");

	Gtk->exit (0);
}
