#!/usr/bin/env python

"""

superexec -- Nautilus script for building command pipelines

Version: 0.1
Requitements: python, pygtk2

Copyright (C) 2002 Krzysztof Luks <kluks@iq.pl>
Distributed under the terms of GNU GPL version 2 or later

This script allows building complicated command pipelines without need
to use shell. Commands will be executed in following order:

command1 <selected file(s)> [| command2 | ... | commandN]

Output can be saved to file, printed on screen or sent to last command
in pipeline.

Some tips:
    - superexec can also be used to run single command (e.g. fortune)
    - if you want to send selected file to stdin of the first command
      append '<' character to it's name (e.g. 'wc -l <')
    - if you want to do the above for multiple files use cat as the
      first command
    - be careful with potentialy dangerus commands like rm
    - all feedback is welcome :)

Caveats:
    - needs testing!
    - script freezes until pipeline is completed (don't try to run commands
      that dont return (e.g. lynx)
    - new entries can only be added at the end of pipeline
    - save doesn't work

Changes:
    0.1 (2003.02.01) -- initial release


TODO:
    - find a better name for the script
    - add new entry after current one
    - allow to process multiple files one by one or all at once
    - add more error checking
    - run commands in background and make it possible to interrupt them
    - change 0 and ton to gtk.FALSE and gtk.TRUE
    - saving output to file
    - printting output
    - clear entry ? clear all ?
    - better documentation
    - you name it!

"""

import os
import string
import pygtk ; pygtk.require('2.0')
import gtk

def parse_nautilus_environment():
    result = {
        'NAUTILUS_SCRIPT_SELECTED_FILE_PATHS' : [],
        'NAUTILUS_SCRIPT_SELECTED_URIS' : [],
        'NAUTILUS_SCRIPT_CURRENT_URI' : [],
        'NAUTILUS_SCRIPT_WINDOW_GEOMETRY' : [] # I wonder if anyone uses it ;)
    }

    for i in result.keys():
        if os.environ.has_key(i):
            result[i] = os.environ[i].split(':')
        else:
            result[i] = []
    return result

def destroy_cb(widget, data = None):
    gtk.main_quit()

def add_row_cb(widget, data = None):
    hbox = gtk.HBox(gtk.FALSE, 0)

    entry = gtk.Entry(max = 0)
    entries.append(entry)
    hbox.pack_start(entry)
    hbox.pack_start(gtk.VSeparator(), gtk.FALSE, gtk.TRUE, 5)

    button = gtk.Button(stock = gtk.STOCK_ADD)
    button.connect('clicked', add_row_cb)
    hbox.pack_start(button)

    button = gtk.Button(stock = gtk.STOCK_REMOVE)
    if len(entries) > 1:
        button.connect('clicked', del_row_cb, hbox)
    else:
        button.set_sensitive(gtk.FALSE)
    hbox.pack_start(button)

    entrybox.pack_start(hbox, gtk.FALSE, gtk.FALSE, 2)
    hbox.show_all()

def del_row_cb(widget, data = None):
    entry = data.get_children()[0]
    entries.remove(entry)
    entrybox.remove(data)

def execute_cb(widget, data = None):
    str = entries[0].get_text() + ' '

    paths = parse_nautilus_environment()['NAUTILUS_SCRIPT_SELECTED_FILE_PATHS']
    for path in paths:
        str += string.strip(path) + ' '

    if len(entries) == 2:
        str += ' | ' + entries[-1].get_text()
    elif len(entries) > 2:
        str += ' | '
        for e in range(1, len(entries)-1):
            str += entries[e].get_text() + ' | '
        str += entries[-1].get_text()

    import tempfile
    tmp_out = None
    tmp_err = tempfile.mktemp('superexec')

    str += ' 2> ' + tmp_err

    if lr[-1] == 'file':
        str += ' > ' + file_entry.get_text()
    elif lr[-1] == 'show':
        tmp_out = tempfile.mktemp('superexec')
        str += ' > ' + tmp_out

    decision = show_dialog(gtk.MESSAGE_QUESTION, gtk.BUTTONS_OK_CANCEL, str)

    print 'I would execeute: ',
    print str

    if decision == gtk.RESPONSE_OK:
        res = os.system(str)
        if res < 0:
            show_dialog(gtk.MESSAGE_ERROR, gtk.BUTTONS_CLOSE, 'Fork failed')
        elif res > 0:
            f = open(tmp_err)
            msg = ''
            for line in f.readlines():
                msg += line
            f.close()
            show_dialog(gtk.MESSAGE_ERROR, gtk.BUTTONS_CLOSE, msg)
        elif lr[-1] == 'show':
            show_output(tmp_out)
        os.remove(tmp_err)
        os.remove(tmp_out)

def button_cb(widget, data = None):
    print data

def radio_cb(widget, data = None):
    if data == 'file' and widget.get_active():
        file_entry.set_sensitive(1)
        file_button.set_sensitive(1)
    else:
        file_entry.set_sensitive(0)
        file_button.set_sensitive(0)

    lr.pop()
    lr.append(data)

def make_buttons():
    box = gtk.VBox(gtk.FALSE, 0)

    hbox = gtk.HBox(gtk.FALSE, 0)
    widget = gtk.RadioButton(None, 'show')
    widget.connect('toggled', radio_cb, 'show')
    widget.set_active(1)
    group = widget
    hbox.pack_start(widget)
    widget = gtk.RadioButton(group, 'last command')
    widget.connect('toggled', radio_cb, 'last')
    hbox.pack_start(widget)
    widget = gtk.RadioButton(group, 'file')
    widget.connect('toggled', radio_cb, 'file')
    hbox.pack_start(widget)
    box.pack_start(hbox, gtk.FALSE, gtk.FALSE, 2)

    hbox = gtk.HBox(gtk.FALSE, 0)
    widget = gtk.Entry(max = 0)
    f_entry = widget
    f_entry.set_sensitive(0)
    hbox.pack_start(widget)
    widget = gtk.Button(label = 'Browse...')
    f_button = widget
    f_button.set_sensitive(0)
    widget.connect('clicked', execute_cb)
    hbox.pack_start(widget)
    box.pack_start(hbox, gtk.FALSE, gtk.FALSE, 2)

    hbox = gtk.HBox(gtk.FALSE, 0)
    widget = gtk.Button(stock = gtk.STOCK_EXECUTE)
    widget.connect('clicked', execute_cb)
    hbox.pack_start(widget)
    widget = gtk.Button(stock = gtk.STOCK_CLOSE)
    widget.connect('clicked', destroy_cb)
    hbox.pack_start(widget)
    box.pack_start(hbox, gtk.FALSE, gtk.FALSE, 2)

    return box, f_entry, f_button

def show_dialog(type, buttons, str):
    dialog = gtk.MessageDialog(win,
                               gtk.DIALOG_MODAL | gtk.DIALOG_DESTROY_WITH_PARENT,
                               type, buttons, str)
    result = dialog.run()
    dialog.destroy()
    return result

def show_output(file):
    dialog = gtk.Dialog("Command output", win, 0,
                        (gtk.STOCK_SAVE_AS, gtk.RESPONSE_OK,
                         gtk.STOCK_CLOSE, gtk.RESPONSE_CANCEL))
    buff = gtk.TextBuffer(None)
    f = open(file)
    for line in f.readlines():
        buff.insert_at_cursor(line, len(line))
    f.close()
    tv = gtk.TextView()
    tv.set_buffer(buff)
    tv.set_editable(gtk.FALSE)
    tv.set_cursor_visible(gtk.FALSE)

    sw = gtk.ScrolledWindow()
    sw.set_policy(gtk.POLICY_AUTOMATIC, gtk.POLICY_AUTOMATIC)
    sw.set_shadow_type(gtk.SHADOW_IN)
    sw.add(tv)

    dialog.vbox.pack_start(sw, gtk.TRUE, gtk.TRUE, 0)
    dialog.set_default_size(640, 480)
    dialog.show_all()
    result = dialog.run()
    dialog.destroy()
    return result

entries = []
lr = ['show']

win = gtk.Window()
win.set_title('superexec')
win.connect("delete_event", destroy_cb)
win.set_border_width(5)

buttonbox, file_entry, file_button = make_buttons()
entrybox = gtk.VBox(gtk.FALSE, 0)
entrybox.set_border_width(5)

frame1 = gtk.Frame('Command chain')
frame1.add(entrybox)
frame2 = gtk.Frame('Output')
frame2.add(buttonbox)

mainbox = gtk.VBox(gtk.FALSE, 0)
mainbox.pack_start(frame1)
mainbox.pack_start(frame2)

win.add(mainbox)
add_row_cb(None)

geom = parse_nautilus_environment()['NAUTILUS_SCRIPT_WINDOW_GEOMETRY']
if len(geom) > 0:
    geom = geom[0]
    geom = geom.replace('x', '+').split('+')
    # position script window in the center of current nautilus window
    x = (int(geom[0]) / 2) + int(geom[2])
    y = (int(geom[1]) / 2) + int(geom[3])
    win.move(x, y)

win.show_all()
gtk.main()
