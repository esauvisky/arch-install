#!/usr/bin/perl
#
# A GUI for chown, chgrp and chmod. Requires perl and perl-gtk
#
# Distributed under the terms of GNU GPL version 2 or later
#
# Copyright (C) David Westlund <daw@wlug.westbo.se>
#

my $false = 0;
my $true = 1;

use Gtk;
init Gtk;

# Widgets
my $window;
my $signal;
my $main_vbox;

my $user_table_alignment;
my $user_table;
my $user_label;
my $user_entry;
my $group_label;
my $group_entry;

my $separator1;

my $chmod_table_alignment;
my $chmod_table;

my $user_chmod_label_alignment;
my $user_chmod_label;
my $group_chmod_label_alignment;
my $group_chmod_label;
my $others_chmod_label_alignment;
my $others_chmod_label;

my $read_label;
my $read_plus_label;
my $read_minus_label;
my $user_plus_read_button;
my $user_minus_read_button;
my $group_plus_read_button;
my $group_minus_read_button;
my $others_plus_read_button;
my $others_minus_read_button;

my $write_label;
my $write_plus_label;
my $write_minus_label;
my $user_plus_write_button;
my $user_minus_write_button;
my $group_plus_write_button;
my $group_minus_write_button;
my $others_plus_write_button;
my $others_minus_write_button;

my $execute_label;
my $execute_plus_label;
my $execute_minus_label;
my $user_plus_execute_button;
my $user_minus_execute_button;
my $group_plus_execute_button;
my $group_minus_execute_button;
my $others_plus_execute_button;
my $others_minus_execute_button;

my $separator2;



my $file_info_hbox_alignment;
my $file_info_hbox;
my $permission_vbox;
my @permissions;
my $owner_vbox;
my @owners_alignment;
my @owners;
my $group_vbox;
my @groups_alignment;
my @groups;
my $filename_vbox;
my @filenames_alignment;
my @filenames;
# Non-widgets (used in the ls-loop)
my $file_info;
my $rights;
my $name;

my $separator3;



my $last_hbox;
my $recursice_button;
my $ok_button;
my $cancel_button;


# Not widgets...
my $id;
my $user;
#my @groups;

# Fix info about the user and the groups
$id = `id`;
$user = $id;
$user =~ s/^[^\(]+\(//;
$user =~ s/\).*//s;


# I don't use the code for groups now, but it may be handy
# in the future...
#@groups = split ",", $id;
#$groups[0] =~ s/.*gid[^\(]+\(.*\(//;
#$groups[0] =~ s/\).*//;

#foreach (@groups) {
	#$_ =~ s/.*\(//;
	#$_ =~ s/\).*//s;
#}

# Create the gtk-program
$window = new Gtk::Window ( 'toplevel' );
$signal = $window->signal_connect ('delete_event',
				   sub { Gtk->exit (0); } );

$window->border_width (5);
$window->set_title ("Chmog");

$main_vbox = new Gtk::VBox ($false, 0);
$window->add ($main_vbox);
$main_vbox->show ();


# The table to put owner and group in
$user_table_alignment = new Gtk::Alignment (0.5, 0, 0, 0);
$user_table = new Gtk::Table (2, 2, $true);
$user_table_alignment->add ($user_table);
$main_vbox->pack_start ($user_table_alignment, $false, $false, 0);
$user_table_alignment->show ();
$user_table->show ();

# Create the owners and groups row.
if ($user =~ /^root$/) {
	$user_label = new Gtk::Label ("owner: ");
	$user_table->attach ($user_label, 0, 1, 0, 1, "fill", 0, 0, 0);
	$user_label->show ();

	$user_entry = new Gtk::Entry ( 10 );
	$user_entry->set_usize (60, undef);

	$user_table->attach ($user_entry, 1, 2, 0, 1, "fill", 0, 0, 0);
	$user_entry->show ();
}
	

$group_label = new Gtk::Label ("group: ");
$user_table->attach ($group_label, 0, 1, 1, 2, "fill", 0, 0, 0);
$group_label->show ();

$group_entry = new Gtk::Entry ( 10 );
$group_entry->set_usize (60, undef);
$user_table->attach ($group_entry, 1, 2, 1, 2, "fill", 0, 0, 0);
$group_entry->show ();

$separator1 = new Gtk::HSeparator ();
$main_vbox->pack_start ($separator1, $true, $true, 10);
$separator1->show ();


# Time for the chmod-section
$chmod_table_alignment = new Gtk::Alignment (0.5, 0, 0, 0);
$chmod_table = new Gtk::Table (5, 7, $true);
$chmod_table_alignment->add ($chmod_table);
$main_vbox->pack_start ($chmod_table_alignment, $false, $false, 0);
$chmod_table->set_col_spacings ( 0 );
$chmod_table_alignment->show ();
$chmod_table->show ();


# Adding the labels to the chmod_table
$user_chmod_label_alignment = new Gtk::Alignment (1,0,0,0);
$user_chmod_label = new Gtk::Label ("user:");
$user_chmod_label_alignment->add ($user_chmod_label);
$chmod_table->attach ($user_chmod_label_alignment, 0, 1, 2, 3,"fill", 0, 0, 0);
$user_chmod_label_alignment->show ();
$user_chmod_label->show ();

$group_chmod_label_alignment = new Gtk::Alignment (1,0,0,0);
$group_chmod_label = new Gtk::Label ("group:");
$group_chmod_label_alignment->add ($group_chmod_label);
$chmod_table->attach ($group_chmod_label_alignment,0, 1, 3, 4,"fill", 0, 0, 0);
$group_chmod_label_alignment->show ();
$group_chmod_label->show ();

$others_chmod_label_alignment = new Gtk::Alignment (1,0,0,0);
$others_chmod_label = new Gtk::Label ("others:");
$others_chmod_label_alignment->add ($others_chmod_label);
$chmod_table->attach ($others_chmod_label_alignment,0, 1, 4, 5,"fill", 0, 0, 0);
$others_chmod_label_alignment->show ();
$others_chmod_label->show ();

# Adding the labels and the buttons to the read_vbox
$read_label = new Gtk::Label ("read");
$chmod_table->attach ($read_label, 1, 3, 0, 1, 0, 0, 0, 0);
$read_label->show ();

$read_plus_label = new Gtk::Label ("+");
$chmod_table->attach ($read_plus_label, 1, 2, 1, 2, 0, 0, 0, 0);
$read_plus_label->show ();

$read_minus_label = new Gtk::Label ("-");
$chmod_table->attach ($read_minus_label, 2, 3, 1, 2, 0, 0, 0, 0);
$read_minus_label->show ();

$user_plus_read_button = new Gtk::CheckButton ();
$chmod_table->attach ($user_plus_read_button, 1, 2, 2, 3, 0, 0, 0, 0);
$user_plus_read_button->show ();

$user_minus_read_button = new Gtk::CheckButton ();
$chmod_table->attach ($user_minus_read_button, 2, 3, 2, 3, 0, 0, 0, 0);
$user_minus_read_button->show ();

#callbacks
$user_plus_read_button->signal_connect ("clicked", \&check_button_callback,
					$user_minus_read_button);
$user_minus_read_button->signal_connect ("clicked", \&check_button_callback,
					$user_plus_read_button);

$group_plus_read_button = new Gtk::CheckButton ();
$chmod_table->attach ($group_plus_read_button, 1, 2, 3, 4, 0, 0, 0, 0);
$group_plus_read_button->show ();

$group_minus_read_button = new Gtk::CheckButton ();
$chmod_table->attach ($group_minus_read_button, 2, 3, 3, 4, 0, 0, 0, 0);
$group_minus_read_button->show ();

#callbacks
$group_plus_read_button->signal_connect ("clicked", \&check_button_callback,
					$group_minus_read_button);
$group_minus_read_button->signal_connect ("clicked", \&check_button_callback,
					$group_plus_read_button);


$others_plus_read_button = new Gtk::CheckButton ();
$chmod_table->attach ($others_plus_read_button, 1, 2, 4, 5, 0, 0, 0, 0);
$others_plus_read_button->show ();

$others_minus_read_button = new Gtk::CheckButton ();
$chmod_table->attach ($others_minus_read_button, 2, 3, 4, 5, 0, 0, 0, 0);
$others_minus_read_button->show ();

#callbacks
$others_plus_read_button->signal_connect ("clicked", \&check_button_callback,
					$others_minus_read_button);
$others_minus_read_button->signal_connect ("clicked", \&check_button_callback,
					$others_plus_read_button);





# Adding the labels and the buttons to the write_vbox
$write_label = new Gtk::Label ("write");
$chmod_table->attach ($write_label, 3, 5, 0, 1, 0, 0, 0, 0);
$write_label->show ();

$write_plus_label = new Gtk::Label ("+");
$chmod_table->attach ($write_plus_label, 3, 4, 1, 2, 0, 0, 0, 0);
$write_plus_label->show ();

$write_minus_label = new Gtk::Label ("-");
$chmod_table->attach ($write_minus_label, 4, 5, 1, 2, 0, 0, 0, 0);
$write_minus_label->show ();

$user_plus_write_button = new Gtk::CheckButton ();
$chmod_table->attach ($user_plus_write_button, 3, 4, 2, 3, 0, 0, 0, 0);
$user_plus_write_button->show ();

$user_minus_write_button = new Gtk::CheckButton ();
$chmod_table->attach ($user_minus_write_button, 4, 5, 2, 3, 0, 0, 0, 0);
$user_minus_write_button->show ();

#callbacks
$user_plus_write_button->signal_connect ("clicked", \&check_button_callback,
					$user_minus_write_button);
$user_minus_write_button->signal_connect ("clicked", \&check_button_callback,
					$user_plus_write_button);

$group_plus_read_button = new Gtk::CheckButton ();
$group_plus_write_button = new Gtk::CheckButton ();
$chmod_table->attach ($group_plus_write_button, 3, 4, 3, 4, 0, 0, 0, 0);
$group_plus_write_button->show ();

$group_minus_write_button = new Gtk::CheckButton ();
$chmod_table->attach ($group_minus_write_button, 4, 5, 3, 4, 0, 0, 0, 0);
$group_minus_write_button->show ();

#callbacks
$group_plus_write_button->signal_connect ("clicked", \&check_button_callback,
					$group_minus_write_button);
$group_minus_write_button->signal_connect ("clicked", \&check_button_callback,
					$group_plus_write_button);


$others_plus_write_button = new Gtk::CheckButton ();
$chmod_table->attach ($others_plus_write_button, 3, 4, 4, 5, 0, 0, 0, 0);
$others_plus_write_button->show ();

$others_minus_write_button = new Gtk::CheckButton ();
$chmod_table->attach ($others_minus_write_button, 4, 5, 4, 5, 0, 0, 0, 0);
$others_minus_write_button->show ();

#callbacks
$others_plus_write_button->signal_connect ("clicked", \&check_button_callback,
					$others_minus_write_button);
$others_minus_write_button->signal_connect ("clicked", \&check_button_callback,
					$others_plus_write_button);



# Adding the labels and the buttons to the execute_vbox
$execute_label = new Gtk::Label ("execute");
$chmod_table->attach ($execute_label, 5, 7, 0, 1, 0, 0, 0, 0);
$execute_label->show ();

$execute_plus_label = new Gtk::Label ("+");
$chmod_table->attach ($execute_plus_label, 5, 6, 1, 2, 0, 0, 0, 0);
$execute_plus_label->show ();

$execute_minus_label = new Gtk::Label ("-");
$chmod_table->attach ($execute_minus_label, 6, 7, 1, 2, 0, 0, 0, 0);
$execute_minus_label->show ();

$user_plus_execute_button = new Gtk::CheckButton ();
$chmod_table->attach ($user_plus_execute_button, 5, 6, 2, 3, 0, 0, 0, 0);
$user_plus_execute_button->show ();

$user_minus_execute_button = new Gtk::CheckButton ();
$chmod_table->attach ($user_minus_execute_button, 6, 7, 2, 3, 0, 0, 0, 0);
$user_minus_execute_button->show ();

#callbacks
$user_plus_execute_button->signal_connect ("clicked", \&check_button_callback,
					$user_minus_execute_button);
$user_minus_execute_button->signal_connect ("clicked", \&check_button_callback,
					$user_plus_execute_button);

$group_plus_read_button = new Gtk::CheckButton ();

$group_plus_execute_button = new Gtk::CheckButton ();
$chmod_table->attach ($group_plus_execute_button, 5, 6, 3, 4, 0, 0, 0, 0);
$group_plus_execute_button->show ();

$group_minus_execute_button = new Gtk::CheckButton ();
$chmod_table->attach ($group_minus_execute_button, 6, 7, 3, 4, 0, 0, 0, 0);
$group_minus_execute_button->show ();

#callbacks
$group_plus_execute_button->signal_connect ("clicked", \&check_button_callback,
					$group_minus_execute_button);
$group_minus_execute_button->signal_connect ("clicked", \&check_button_callback,
					$group_plus_execute_button);

$others_plus_execute_button = new Gtk::CheckButton ();
$chmod_table->attach ($others_plus_execute_button, 5, 6, 4, 5, 0, 0, 0, 0);
$others_plus_execute_button->show ();

$others_minus_execute_button = new Gtk::CheckButton ();
$chmod_table->attach ($others_minus_execute_button, 6, 7, 4, 5, 0, 0, 0, 0);
$others_minus_execute_button->show ();

#callbacks
$others_plus_execute_button->signal_connect ("clicked", \&check_button_callback,
					$others_minus_execute_button);
$others_minus_execute_button->signal_connect ("clicked",\&check_button_callback,
					$others_plus_execute_button);



$separator2 = new Gtk::HSeparator ();
$main_vbox->pack_start ($separator2, $true, $true, 10);
$separator2->show ();



# Creating the list with filenames and permissions
$file_info_hbox_alignment = new Gtk::Alignment (0.5,0,0,0);
$file_info_hbox = new Gtk::HBox ($false, 0);
$file_info_hbox_alignment->add ($file_info_hbox);
$main_vbox->pack_start ($file_info_hbox_alignment, $false, $false, 0);
$file_info_hbox_alignment->show ();
$file_info_hbox->show ();

$permission_vbox = new Gtk::VBox ($fase, 0);
$file_info_hbox->pack_start ($permission_vbox, $false, $false, 20);
$permission_vbox->show ();

$owner_vbox = new Gtk::VBox ($false, 0);
$file_info_hbox->pack_start ($owner_vbox, $false, $false, 10);
$owner_vbox->show ();

$group_vbox = new Gtk::VBox ($false, 0);
$file_info_hbox->pack_start ($group_vbox, $false, $false, 10);
$group_vbox->show ();

$filename_vbox = new Gtk::VBox ($false, 0);
$file_info_hbox->pack_start ($filename_vbox, $false, $false, 20);
$filename_vbox->show ();


$i = 0;
foreach ( @ARGV ) {
	$file_info = `ls -ld \"$_\"`;
	chop $file_info;
	$rights = $file_info;
	$rights =~ s/\s.*//;
	$owner = $file_info;
	$owner =~ s/\S+\s+\S+\s+//;
	$owner =~ s/\s.*//;
	$group = $file_info;
	$group =~ s/\S+\s+\S+\s+\S+\s+//;
	$group =~ s/\s.*//;
	$name = $file_info;
	$name =~ s/\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+\S+\s+//;

	$permissions[$i] = new Gtk::Label ("$rights");
	$permission_vbox->pack_start ($permissions[$i], $false, $false, 0);
	$permissions[$i]->show ();

	$owners_alignment[$i] = new Gtk::Alignment (0,1,0,0);
	$owners[$i] = new Gtk::Label ("$owner");
	$owners_alignment[$i]->add ($owners[$i]);
	$owner_vbox->pack_start ($owners_alignment[$i],$false, $false, 0);
	$owners_alignment[$i]->show ();
	$owners[$i]->show ();

	$groups_alignment[$i] = new Gtk::Alignment (0,1,0,0);
	$groups[$i] = new Gtk::Label ("$group");
	$groups_alignment[$i]->add ($groups[$i]);
	$group_vbox->pack_start ($groups_alignment[$i],$false, $false, 0);
	$groups_alignment[$i]->show ();
	$groups[$i]->show ();

	$filenames_alignment[$i] = new Gtk::Alignment (0,1,0,0);
	$filenames[$i] = new Gtk::Label ("$name");
	$filenames_alignment[$i]->add ($filenames[$i]);
	$filename_vbox->pack_start ($filenames_alignment[$i],$false, $false, 0);
	$filenames_alignment[$i]->show ();
	$filenames[$i]->show ();
	$i++;
}


$separator3 = new Gtk::HSeparator ();
$main_vbox->pack_start ($separator3, $true, $true, 10);
$separator3->show ();



#This is the last line of widgets in the program...
$last_hbox = new Gtk::HBox ( $false, 0);
$main_vbox->pack_start ($last_hbox, $false, $false, 5);
$last_hbox->show ();

$recursive_button = new Gtk::CheckButton ("Change recursive");
$last_hbox->pack_start ($recursive_button, $false, $false, 10);
$recursive_button->show ();

$ok_button = new Gtk::Button ("Ok");
$last_hbox->pack_start ($ok_button, $false, $false, 10);
$ok_button->signal_connect ('clicked', \&chmod);
$ok_button->show;

$cancel_button = new Gtk::Button ("Cancel");
$last_hbox->pack_start ($cancel_button, $false, $false, 10);
$cancel_button->signal_connect ('clicked', sub { Gtk->exit (0) } );
$cancel_button->show ();


$window->show ();
main Gtk;
exit (1);

sub check_button_callback
{
	$button1 = $_[0];
	$button2 = $_[1];

	$button2->set_active ($false) if $button1->get_active;
}

sub chmod
{
	my $mode = 0;
	my $recursive = "";
	my $files = "";
	my $new_group = $group_entry->get_text ();
	my $upmode = "u+";
	my $ummode = "u-";
	my $gpmode = "g+";
	my $gmmode = "g-";
	my $opmode = "o+";
	my $ommode = "o-";

	$upmode .= "r" if $user_plus_read_button->active;
	$upmode .= "w" if $user_plus_write_button->active;
	$upmode .= "x" if $user_plus_execute_button->active;
	$ummode .= "r" if $user_minus_read_button->active;
	$ummode .= "w" if $user_minus_write_button->active;
	$ummode .= "x" if $user_minus_execute_button->active;
	$gpmode .= "r" if $group_plus_read_button->active;
	$gpmode .= "w" if $group_plus_write_button->active;
	$gpmode .= "x" if $group_plus_execute_button->active;
	$gmmode .= "r" if $group_minus_read_button->active;
	$gmmode .= "w" if $group_minus_write_button->active;
	$gmmode .= "x" if $group_minus_execute_button->active;
	$opmode .= "r" if $others_plus_read_button->active;
	$opmode .= "w" if $others_plus_write_button->active;
	$opmode .= "x" if $others_plus_execute_button->active;
	$ommode .= "r" if $others_minus_read_button->active;
	$ommode .= "w" if $others_minus_write_button->active;
	$ommode .= "x" if $others_minus_execute_button->active;
	$recursive = "-R" if $recursive_button->active;
	$recursive = "-R" if $recursive_button->active;

	$upmode = "" if $umode =~ /^u\+$/;
	$ummode = "" if $umode =~ /^u\-$/;
	$gpmode = "" if $gmode =~ /^g\+$/;
	$gmmode = "" if $gmode =~ /^g\-$/;
	$opmode = "" if $omode =~ /^o\+$/;
	$ommode = "" if $omode =~ /^o\-$/;


	foreach (@ARGV) {
		$files .= "\"$_\"" . " ";
	}

	system ("chmod $recursive $upmode,$gpmode,$opmode,$ummode,$gmmode,$ommode $files");

	if ($user eq "root") {
		my $new_user = $user_entry->get_text ();
		system ("chown $recursive $new_user $files") if $new_user =~ /\w+/;
	}
		
	system ("chgrp $recursive $new_group $files") if $new_group =~ /\w+/;
		
	
	Gtk->exit ( 0 );
}
