#!/usr/bin/python
#
# simple script to recurse a subtree, find all the mp3 and queue them to
# XMMS.
#
# Please modify this script!  My python is rusty at best.
#
# Travis Hume -- travis@usermail.com
# Thu Oct 24 11:06:54 2002
#
# Barak Korren - ifireball@yahoo.com
# Sat Apr 03 2004
#   Some bugfixes, now preserves alphanumerical file-ordering in 
#   sub-directories

import sys, glob, os, os.path, dircache

def isAudioFile( f ):
    # to support additional file types just add their appropriate
    # extentions to this list (lower case).
    file_types = ['.mp3','.ogg','.wav']

    p,ext = os.path.splitext(f)
    try:
        file_types.index(ext.lower())
    except:
        return False

    return True


# change this to something other than None to make the script
# follow symlinks
follow_links = None

def find_mp3s( dirs=None ):
    """ finds all mp3 files rooted at dirs and returns them as a list """
    if not dirs:
        return []

    mp3s = []
    while dirs:
        if os.path.isfile(dirs[0]) and isAudioFile(dirs[0]):
            mp3s.append(dirs[0])
            dirs = dirs[1:]
        elif os.path.isdir(dirs[0]):
            found_dirs = []
            for f in dircache.listdir( dirs[0] ):
		p = dirs[0] + "/" + f;
                if os.path.isfile(p) and isAudioFile(p):
                    mp3s.append( p )
                elif os.path.isdir( p ) and not f.endswith( "/proc" ):
                    if not os.path.islink( p ) or follow_links:
                        found_dirs.append( p )

            dirs = found_dirs + dirs[1:]

    return mp3s

dirs = sys.argv[1:]
dirs.reverse()
mp3s = find_mp3s( dirs )
#inf = "";
#for mp3 in mp3s:
#  inf = inf + '"' + mp3 + '"' + "\n"
#os.execvp("zenity", ['zenity','--info','--text=' + inf] )
os.execvp("xmms", ['xmms','-p'] + mp3s )
