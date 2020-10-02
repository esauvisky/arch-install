#!/usr/bin/perl -w

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#                                                                       #
# EXIF Dump script for Nautilus                                         #
#                                                                       #
# Shows various things modern digital cameras embed in the image files  #
# like exposure time and aperture and other interesting information.    #
#                                                                       #
# Depends on gdialog for the display part and jhead for the actual      #
# EXIF data parsing from the images. You can get jhead from             #
# http://www.sentex.net/~mwandel/jhead/, it probably works on anything  #
# that has a C compiler. Happy notice is that it does work on linux/ppc #
# as well.                                                              #
#                                                                       #
# Hacked together by Tuomas Kuosmanen <tigert@ximian.com> and           #
# Jakub Steiner <jimmac@ximian.com> (icons)                             #
# Released under the GPL license.                                       #
#                                                                       #
# The code is ugly, but it worksforme and this is perl.                 #
# My perl is ugly. -tigert-                                             #
#                                                                       #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 

use POSIX;
use Digest::MD5 qw(md5_hex);

die "No files.. Easy job." unless @ARGV;

$hash = md5_hex(localtime);
$tempfile = "/tmp/foo.$hash";

foreach $file (@ARGV) {
	 $reply=`jhead \"$file\" 2>&1 > $tempfile`;
#	 print("REPLY:: $reply\n");
	 if ($reply =~ "aborting") {
		  system("gdialog --title \"EXIF Data Error\" --msgbox \"The file $file does not contain any EXIF information.\" 100 100");
	 } else {
		  system("gdialog --title \"EXIF Information for $file\" --textbox $tempfile 34 42");
	 }
}
system("rm $tempfile");


