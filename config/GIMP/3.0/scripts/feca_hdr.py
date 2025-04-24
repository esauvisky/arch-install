#!/usr/bin/env python

#   Gimp-Python - allows the writing of Gimp plugins in Python.
#   Copyright (C) 2007 Kalman, Ferenc <fkalman@index.hu>
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program; if not, write to the Free Software
#   Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.


import math, struct
from gimpfu import *

class pixel_fetcher:
        def __init__(self, drawable):
                self.col = -1
                self.row = -1
                self.img_width = drawable.width
                self.img_height = drawable.height
                self.img_bpp = drawable.bpp
                self.img_has_alpha = drawable.has_alpha
                self.tile_width = 64
                self.tile_height = 64
                self.bg_colour = '\0\0\0\0'
                self.bounds = drawable.mask_bounds
                self.drawable = drawable
                self.tile = None
        def set_bg_colour(self, r, g, b, a):
                self.bg_colour = struct.pack('BBB', r,g,b)
                if self.img_has_alpha:
                        self.bg_colour = self.bg_colour + chr(a)
        def get_pixel(self, x, y):
                sel_x1, sel_y1, sel_x2, sel_y2 = self.bounds
                if x < sel_x1 or x >= sel_x2 or y < sel_y1 or y >= sel_y2:
                        return self.bg_colour
                col = x / self.tile_width
                coloff = x % self.tile_width
                row = y / self.tile_height
                rowoff = y % self.tile_height

                if col != self.col or row != self.row or self.tile == None:
                        self.tile = self.drawable.get_tile(FALSE, row, col)
                        self.col = col
                        self.row = row
                return self.tile[coloff, rowoff]
        def set_pixel(self, x, y, pixel):
                sel_x1, sel_y1, sel_x2, sel_y2 = self.bounds
                if x < sel_x1 or x >= sel_x2 or y < sel_y1 or y >= sel_y2:
                        return
                col = x / self.tile_width
                coloff = x % self.tile_width
                row = y / self.tile_height
                rowoff = y % self.tile_height

                if col != self.col or row != self.row or self.tile == None:
                        self.tile = self.drawable.get_tile(FALSE, row, col)
                        self.col = col
                        self.row = row
                self.tile[coloff, rowoff] = pixel

class Dummy:
        pass

def python_feca_hdr(image, drawable, width1, width2, blur, levelLight, levelDark):
        self = Dummy()
        self.width = drawable.width
        self.height = drawable.height
        self.bpp = drawable.bpp
        self.has_alpha = drawable.has_alpha
        self.bounds = drawable.mask_bounds
        self.sel_x1, self.sel_y1, self.sel_x2, self.sel_y2 = \
                     drawable.mask_bounds
        self.sel_w = self.sel_x2 - self.sel_x1
        self.sel_h = self.sel_y2 - self.sel_y1

        gimp.tile_cache_ntiles(2 * (self.width + 63) / 64)

        if (len(image.layers) != 3):
                pdb.gimp_message("You need have exactly 3 layers (order is not important): Normal, +EV, -EV!")
                return

	pdb.gimp_image_undo_group_start(image)

        layer_normal = image.layers[2]
        layer_dark = image.layers[1]
        layer_bright = image.layers[0]

        layer_normal.add_alpha()

        progress = 0
        max_progress = 5
        gimp.progress_init("High Dynamic Range with Tone Mapping...")

        pfn = pixel_fetcher(layer_normal)
        pfd = pixel_fetcher(layer_dark)
        pfb = pixel_fetcher(layer_bright)

        cn = 0
        cd = 0
        cb = 0

        for row in range(self.sel_y1, self.sel_y2, 50):
            for col in range(self.sel_x1, self.sel_x2, 50):
                pixeln = pfn.get_pixel(col, row)
                pixelb = pfb.get_pixel(col, row)
                pixeld = pfd.get_pixel(col, row)
                rn = ord(pixeln[0]) + 1
                gn = ord(pixeln[1]) + 1
                bn = ord(pixeln[2]) + 1
                rd = ord(pixeld[0]) + 1
                gd = ord(pixeld[1]) + 1
                bd = ord(pixeld[2]) + 1
                rb = ord(pixelb[0]) + 1
                gb = ord(pixelb[1]) + 1
                bb = ord(pixelb[2]) + 1
                if (rn > rd): cn = cn +1
                else: cd = cd + 1
                if (gn > gd): cn = cn +1
                else: cd = cd + 1
                if (bn > bd): cn = cn +1
                else: cd = cd + 1
                if (rn > rb): cn = cn +1
                else: cb = cb + 1
                if (gn > gb): cn = cn +1
                else: cb = cb + 1
                if (bn > bb): cn = cn +1
                else: cb = cb + 1
                if (rd > rb): cd = cd +1
                else: cb = cb + 1
                if (gd > gb): cd = cd +1
                else: cb = cb + 1
                if (bd > bb): cd = cd +1
                else: cb = cb + 1
        if (cn > cd):
            if (cn > cb):
                layer = layer_bright
                layer_bright = layer_normal
                if (cd > cb):
                    layer_normal = layer_dark
                    layer_dark = layer
                    image.lower_layer(layer_normal)
                else:
                    layer_normal = layer
                    image.lower_layer(layer_normal)
                    image.lower_layer(layer_normal)
        else:
            if (cd > cb):
                layer = layer_bright
                layer_bright = layer_dark
                if (cn > cb):
                    layer_dark = layer
                else:
                    layer_dark = layer_normal
                    layer_normal = layer
                    image.lower_layer(layer_normal)
                    image.lower_layer(layer_normal)
            else:
                layer = layer_normal
                layer_normal = layer_dark
                layer_dark = layer
                image.lower_layer(layer_normal)

        if (layer_dark.mask != None):
            pdb.gimp_layer_remove_mask(layer_dark, 1)
        if (layer_bright.mask != None):
            pdb.gimp_layer_remove_mask(layer_bright, 1)

        layer_two = layer_normal.copy()
        layer_two.name = "Dark"
        image.add_layer(layer_two, 0)

        progress += 1
        gimp.progress_update(float(progress) / max_progress)

        cp2 = (0,0, 255-width2,25, 255-width1,240, 255,255)
        pdb.gimp_curves_spline(layer_two, HISTOGRAM_VALUE, 8, cp2)
        pdb.gimp_drawable_set_visible(layer_two, 0)

        layer_one = layer_normal.copy()
        layer_one.name = "Bright"
        image.add_layer(layer_one, 0)

        cp1 = [0,255, width1,240, width2,25, 255,0]
        pdb.gimp_curves_spline(layer_one, HISTOGRAM_VALUE, 8, cp1)
        pdb.gimp_drawable_set_visible(layer_one, 0)

        pdb.plug_in_gauss_rle2(image, layer_two, blur, blur)

        pdb.plug_in_gauss_rle2(image, layer_one, blur, blur)

        progress += 1
        gimp.progress_update(float(progress) / max_progress)

        progress += 1
        gimp.progress_update(float(progress) / max_progress)

        if (layer_dark.mask == None):
            mask_dark = pdb.gimp_layer_create_mask(layer_dark, 0)
            pdb.gimp_layer_add_mask(layer_dark, mask_dark)
        else:
            mask_dark = layer_dark.mask
        if (layer_bright.mask == None):
            mask_bright = pdb.gimp_layer_create_mask(layer_bright, 0)
            pdb.gimp_layer_add_mask(layer_bright, mask_bright)
        else:
            mask_bright = layer_bright.mask

        progress += 1
        gimp.progress_update(float(progress) / max_progress)

        pdb.gimp_edit_copy(layer_two)
        floating_sel = pdb.gimp_edit_paste(mask_dark, 0)
        pdb.gimp_floating_sel_anchor(floating_sel)

        progress += 1
        gimp.progress_update(float(progress) / max_progress)

        pdb.gimp_edit_copy(layer_one)
        floating_sel = pdb.gimp_edit_paste(mask_bright, 0)
        pdb.gimp_floating_sel_anchor(floating_sel)

        pdb.gimp_image_remove_layer(image, layer_one)
        pdb.gimp_image_remove_layer(image, layer_two)

        cp1 = [0,0, 128,128-levelLight, 255,255]
        pdb.gimp_curves_spline(layer_bright, HISTOGRAM_VALUE, 6, cp1)

        cp1 = [0,0, 128,128+levelDark, 255,255]
        pdb.gimp_curves_spline(layer_dark, HISTOGRAM_VALUE, 6, cp1)

	pdb.gimp_image_flatten(image)
	pdb.gimp_image_undo_group_end(image)

register(
        "python_fu_feca_hdr",
        "High dynamic range with tone mapping",
        "High dynamic range with tone mapping",
        "Ferenc Kalman",
        "Ferenc Kalman",
        "2007",
        "<Image>/Filters/Emi's/HDR/Tone Mapping",
        "*",
        [
                (PF_SPINNER, "width1", "Extreme value width (10-50)", 40, (10, 50, 1)),
                (PF_SPINNER, "width2", "Greater width (20-100)", 50, (20, 100, 1)),
                (PF_SPINNER, "blur", "Blurring of extreme colors (0-50)", 10, (0, 50, 1)),
                (PF_SPINNER, "levelLight", "Light colors darking (-100-100)", 30, (-100, 100, 1)),
                (PF_SPINNER, "levelDark", "Dark colors lighting (-100-100)", 30, (-100, 100, 1))
        ],
        [],
        python_feca_hdr)

main()
