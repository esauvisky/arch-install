#!/usr/bin/env python2.2
#
# gtk2-grep -- gtk2 frontend to grep.
#
# Copyright (C) 2003 David Westlund
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
#
# Dependency: python-gtk2
#
# This script is based on gtk2-du. Gtk2-du is copyright (C) Krzysztof Luks

import pygtk
pygtk.require('2.0')
import gtk
import sys
import os

#set_locale Gtk;

def destroy(*args):
        """ Callback function that is activated when the program is destoyed """
        window.hide()
        gtk.main_quit()

def grep(*args):
        buffer = text.get_buffer()
        buffer.delete(buffer.get_start_iter(), buffer.get_end_iter())

	files = os.environ.get('NAUTILUS_SCRIPT_SELECTED_FILE_PATHS')
	files = files.split("\n")
        files_string = ""
        for i in files[0:]:
                files_string = files_string +"\"" + i + "\" "

        search = grep_entry.get_text()
        parameters = parameters_entry.get_text()
        out = os.popen("grep " + parameters + " \"" +  search + "\" " + files_string, "r")
        
        buffer.insert(buffer.get_start_iter(), out.read())

        out.close()

	if buffer.get_char_count() == 0:
		buffer.insert(buffer.get_start_iter(), "No match found")

def check_enter(widget, key):
	if key.keyval == 65293:
		grep()
        
def check_escape(widget, key):
	if key.keyval == 65307:
		destroy()
        
window = gtk.Window(gtk.WINDOW_TOPLEVEL)
window.connect("destroy", destroy)
window.connect("key_press_event", check_escape)
window.set_border_width(12)
window.set_title("Search in files")
window.set_default_size(400, 300)

vbox = gtk.VBox(gtk.FALSE, 12)
window.add(vbox)

table = gtk.Table(2, 3, gtk.FALSE)
vbox.pack_start(table, gtk.FALSE, gtk.FALSE, 0)
table.show()

parameters_label = gtk.Label("Parameters for grep: ")
table.attach(parameters_label, 0, 1, 0, 1, gtk.FILL, gtk.FILL, 3, 3)
parameters_label.show()

parameters_entry = gtk.Entry()
parameters_entry.connect("key_press_event", check_enter)
table.attach(parameters_entry, 1, 3, 0, 1, gtk.FILL, gtk.FILL, 3, 3)
parameters_entry.show()

alignment = gtk.Alignment(0, 0, 0, 1)
grep_label = gtk.Label("Search after: ")
alignment.add(grep_label)
table.attach(alignment, 0, 1, 1, 2, gtk.FILL, gtk.FILL, 3, 3)
grep_label.show()

grep_entry = gtk.Entry()
grep_entry.connect("key_press_event", check_enter)
table.attach(grep_entry, 1, 2, 1, 2, gtk.FILL, gtk.FILL, 3, 3)
grep_entry.grab_focus()
grep_entry.show()

grep_button = gtk.Button(stock='gtk-find')
grep_button.connect('clicked', grep)
table.attach(grep_button, 2, 3, 1, 2, gtk.FILL, gtk.FILL, 3, 3)
grep_button.show()

scroll_win = gtk.ScrolledWindow()
scroll_win.set_policy(gtk.POLICY_AUTOMATIC, gtk.POLICY_AUTOMATIC)
vbox.pack_start(scroll_win, gtk.TRUE, gtk.TRUE, 0)

text = gtk.TextView()
text.set_editable(gtk.FALSE)

scroll_win.add(text)

button_box = gtk.HButtonBox()
button_box.set_layout(gtk.BUTTONBOX_END)
button_box.show()
vbox.pack_start(button_box, gtk.FALSE, gtk.FALSE, 0)
close_button = gtk.Button(stock='gtk-close')
close_button.connect('clicked', destroy)
button_box.add(close_button)

window.show_all()
gtk.main()
