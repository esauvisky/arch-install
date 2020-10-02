#!/usr/bin/env python2
# Nautilus CD burning script
#
# Owner: Michele Campeotto <micampe@micampe.it>
#        http://www.micampe.it
#
# Licence: GNU GPL
# Copyright (C) 2002 Michele Campeotto
#
# Dependency: GTK+ >= 2.0
#             PyGTK >= 1.99.8
#             Python >= 2.2
#             mkisofs and cdrecord
#
# 20020330 - Ver 0.1
#       First release

import sys, os, os.path, popen2

import gtk

# To configure the script, you should only need to edit these values
device = '0,0,0'
driver = 'mmc_cdr'
options = 'driveropts=burnproof'
dummy = '-dummy'

# To actually burn CDs, uncomment the following line and comment out the next one
#burn_command_template = 'mkisofs -gui -r -J -l -D -L -graft-points %(graft_points)s | cdrecord dev="%(device)s" %(options)s driver=%(driver)s %(dummy)s -eject -pad -tsize=%(size)ss -'
burn_command_template = 'mkisofs -gui -r -J -l -D -L -o image.img -graft-points %(graft_points)s'

size_command_template = 'mkisofs -r -J -l -D -L -v -print-size -graft-points %(graft_points)s'

def build_mappings(paths):
    mappings = []
    for i in paths:
        if os.path.isdir(i):
            mappings.append('"%s/=%s"' % (i.split('/')[-1], i))
        else:
            mappings.append('"%s=%s"' % (i.split('/')[-1], i))
    return mappings

def burn_command(paths):
    global graft_points
    graft_points = ' '.join(build_mappings(paths))
    return burn_command_template % globals()

def size_command(paths):
    global graft_points
    graft_points = ' '.join(build_mappings(paths))
    return size_command_template % globals()

def get_image_size(paths):
    return int(os.popen4(size_command(paths))[1].readlines()[-1])

def burn(paths, progress):
    def cb(fd, cond):
        data = os.read(fd, 80)
        print data,
        if data.find('extents') >= 0:
            progress.set_fraction(1.0)
            progress.set_text('100%')
            return gtk.TRUE
        elif data.find('read/written') >= 0:
            progress.set_text('Finishing...')
        try:
            perc = int(data.split('.')[0])
            progress.set_fraction(perc/100.0)
            progress.set_text('%d%%' % (perc,))
        except (ValueError):
            pass
    command = burn_command(paths)
    print command
    pipe = popen2.Popen4(command)
    gtk.input_add(pipe.fromchild, gtk.gdk.INPUT_READ, cb)
    while pipe.poll() < 0:
        gtk.mainiteration()
    return pipe.poll()

def response(dialog, response):
    sys.exit()

def burn_window(paths):
    win = gtk.Dialog("Nautilus Quick Burner", None, gtk.DIALOG_MODAL,
                     (gtk.STOCK_CANCEL, gtk.RESPONSE_CANCEL))
    win.connect('response', response)
    win.set_default_size(400, -1)
    
    hbox = gtk.HBox()
    hbox.set_border_width(8)
    hbox.set_spacing(8)
    win.vbox.pack_start(hbox)
    
    stock = gtk.image_new_from_stock(gtk.STOCK_DIALOG_INFO,
                                     gtk.ICON_SIZE_DIALOG)
    hbox.pack_start(stock, gtk.FALSE, gtk.FALSE)
    
    vbox = gtk.VBox()
    vbox.set_spacing(8)
    hbox.pack_start(vbox, gtk.TRUE, gtk.TRUE)
    
    label = gtk.Label("<b>Burning...</b>")
    label.set_use_markup(gtk.TRUE)
    label.set_alignment(0, 0.5)
    vbox.pack_start(label)
    
    label = gtk.Label('\n'.join(paths))
    label.set_alignment(0, 0.5)
    vbox.pack_start(label)
    
    win.progress = gtk.ProgressBar()
    win.progress.set_fraction(0.0)
    win.progress.set_text("Initializing...")
    vbox.pack_start(win.progress)
    
    win.show_all()
    return win

def help():
    win = gtk.Dialog("Nautilus Quick Burner", None,
                     gtk.DIALOG_MODAL | gtk.DIALOG_DESTROY_WITH_PARENT,
                     (gtk.STOCK_OK, gtk.RESPONSE_OK))
    
    hbox = gtk.HBox(gtk.FALSE, 8)
    hbox.set_border_width(8)
    win.vbox.pack_start(hbox)
    
    stock = gtk.image_new_from_stock(gtk.STOCK_DIALOG_ERROR,
                                     gtk.ICON_SIZE_DIALOG)
    hbox.pack_start(stock)
    
    label = gtk.Label("You must specify the files to be burned.")
    hbox.pack_start(label)
    
    win.show_all()
    return win

def confirm(paths):
    win = gtk.Dialog("Nautilus Quick Burner", None,
                     gtk.DIALOG_MODAL | gtk.DIALOG_DESTROY_WITH_PARENT,
                     (gtk.STOCK_CANCEL, gtk.RESPONSE_CANCEL,
                      "_Burn 'em!", gtk.RESPONSE_OK))
    
    hbox = gtk.HBox(gtk.FALSE, 8)
    hbox.set_border_width(8)
    win.vbox.pack_start(hbox)
    
    stock = gtk.image_new_from_stock(gtk.STOCK_DIALOG_QUESTION,
                                     gtk.ICON_SIZE_DIALOG)
    hbox.pack_start(stock)
    
    vbox = gtk.VBox()
    vbox.set_spacing(8)
    hbox.pack_start(vbox)
    
    label = gtk.Label("<b>Are you sure you want to burn these?</b>")
    label.set_use_markup(gtk.TRUE)
    label.set_alignment(0, 0.5)
    vbox.pack_start(label)
    
    label = gtk.Label('\n'.join(paths))
    label.set_alignment(0, 0.5)
    vbox.pack_start(label)
    
    win.show_all()
    response = win.run()
    win.destroy()
    return response

def error(paths):
    win = gtk.Dialog("Burning finished", None,
                     gtk.DIALOG_MODAL | gtk.DIALOG_DESTROY_WITH_PARENT,
                     (gtk.STOCK_OK, gtk.RESPONSE_OK))
    
    hbox = gtk.HBox(gtk.FALSE, 8)
    hbox.set_border_width(8)
    win.vbox.pack_start(hbox)
    
    stock = gtk.image_new_from_stock(gtk.STOCK_DIALOG_ERROR,
                                     gtk.ICON_SIZE_DIALOG)
    hbox.pack_start(stock)
    
    vbox = gtk.VBox()
    vbox.set_spacing(8)
    hbox.pack_start(vbox)
    
    label = gtk.Label("<b>Some error occurred while building the image.</b>")
    label.set_use_markup(gtk.TRUE)
    label.set_alignment(0.0, 0.5)
    vbox.pack_start(label)
    
    label = gtk.Label("Run:\n<tt>%s</tt>\nfrom the commman line to see what went wrong."
                      % size_command(paths))
    label.set_use_markup(gtk.TRUE)
    label.set_selectable(gtk.TRUE)
    label.set_line_wrap(gtk.TRUE)
    vbox.pack_start(label)
    
    win.show_all()
    response = win.run()
    win.destroy()
    return response

def success():
    win = gtk.Dialog("Burning finished", None,
                     gtk.DIALOG_MODAL | gtk.DIALOG_DESTROY_WITH_PARENT,
                     (gtk.STOCK_OK, gtk.RESPONSE_OK))
    
    hbox = gtk.HBox(gtk.FALSE, 8)
    hbox.set_border_width(8)
    win.vbox.pack_start(hbox)
    
    stock = gtk.image_new_from_stock(gtk.STOCK_DIALOG_INFO,
                                     gtk.ICON_SIZE_DIALOG)
    hbox.pack_start(stock)
    
    label = gtk.Label("Burning process successfully completed.")
    hbox.pack_start(label)
    
    win.show_all()
    response = win.run()
    win.destroy()
    return response

def failed():
    win = gtk.Dialog("Burning failed", None,
                     gtk.DIALOG_MODAL | gtk.DIALOG_DESTROY_WITH_PARENT,
                     (gtk.STOCK_OK, gtk.RESPONSE_OK))
    
    hbox = gtk.HBox(gtk.FALSE, 8)
    hbox.set_border_width(8)
    win.vbox.pack_start(hbox)
    
    stock = gtk.image_new_from_stock(gtk.STOCK_DIALOG_WARNING,
                                     gtk.ICON_SIZE_DIALOG)
    hbox.pack_start(stock)
    
    label = gtk.Label("Burning process failed.")
    hbox.pack_start(label)
    
    win.show_all()
    response = win.run()
    win.destroy()
    return response

def main():
    global size
    if len(sys.argv) == 1:
        help().run()
    else:
        paths = [os.path.abspath(i) for i in sys.argv[1:]]
        if confirm(paths) == gtk.RESPONSE_OK:
            try:
                size = get_image_size(paths)
            except ValueError:
                error(paths)
            else:
                win = burn_window(paths)
                result = burn(paths, win.progress)
                print result
                win.destroy()
                if result == 0:
                    success()
                else:
                    failed()

if __name__ == '__main__':
    main()
