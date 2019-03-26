#!/usr/bin/perl -w
#
# gtk-du -- gtk frontend to du. You will need
# libgtk-perl to run the program.
#
# Distributed under the terms of GNU GPL v 2.0 or later
#
# Copyright (C) David Westlund <daw@wlug.westbo.se>


use Gtk;
#use strict;

init Gtk;
set_locale Gtk;

my $true = 1;
my $false = 0;

# These will be used as gtk-widgets
my $window;
my $vbox;
my $hbox;
my $parameters_label;
my $parameters_entry;
my $du_button;
my $table;
my $scroll;
my $text;
my $close_button;

# The gtk-signals
my $signal;



$window = new Gtk::Window( 'toplevel' );
$signal = $window->signal_connect( 'delete_event', sub { Gtk->exit( 0 ); } );
$window->border_width( 15 );
$window->set_title( "gtk-du" );

$vbox = new Gtk::VBox ( $false, 0 );
$window->add( $vbox );


$hbox = new Gtk::HBox ( $false, 0 );
$vbox->pack_start ($hbox, $false, $false, 0);
$hbox->show();


$parameters_label = new Gtk::Label ( "Parameters" );
$hbox->pack_start ($parameters_label, $false, $false, 0);
$parameters_label->show();

$parameters_entry = new Gtk::Entry ();
$hbox->pack_start ($parameters_entry, $false, $false, 0);
$parameters_entry->set_text ( "-chs" );
$parameters_entry->show();

$du_button = new Gtk::Button ( "du" );
$du_button->signal_connect ('clicked', \&du );
$hbox->pack_start ($du_button, $false, $false, 0);
$du_button->show();

$table = new Gtk::Table (2, 1, $false);
$table->set_usize ( 300, 200 );
$vbox->pack_start ($table, $false, $false, 0);
$table->show();

$text = new Gtk::Text ( undef, undef );
$text->set_editable ($false);
$table->attach( $text, 0, 1, 0, 1,
		[ 'expand', 'fill' ],
		[ 'expand', 'fill' ],
		0, 0 );
$text->show;

$scroll = new Gtk::VScrollbar ( $text->vadj );
$table->attach( $scroll, 1, 2, 0, 1, 'fill',
		[ 'expand', 'fill' ], 0, 0 );
$scroll->show;

$close_button = new Gtk::Button( "Close" );
$close_button->signal_connect( 'clicked', sub { Gtk->exit( 0 ); } );
$vbox->pack_start( $close_button, $false, $false, 0 );
$close_button->show();

$vbox->show();
$window->show();

du ();


main Gtk;
exit (0);


sub du
{
	my $length;
	my $row;
	my $parameters;
	my $files = " ";

	$length = $text->get_length ();
	$text->backward_delete ($length);

	foreach (@ARGV) {
		$files = $files . "\"$_\"" . " ";
	}

	$parameters = $parameters_entry->get_text();

	open DU, "du $parameters $files 2>&1 |";

	while ( $row = <DU> ) {

		$text->insert ( undef, undef,undef , $row );
	
	}

	close DU;
}
