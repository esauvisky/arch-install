#!/usr/bin/env bash
#
# ~/.bashrc
#

# ================================== emishrc ===================================
# Loads emi's shell config from ~/.emishrc/  (github.com/esauvisky/arch-install)
# Updates rewrite ~/.emishrc/ only. This file was written once and is now yours.
#
# Knobs, set them above the source line or in the environment:
#   EMISHRC_DISABLE=1                  skip emishrc entirely
#   EMISHRC_SKIP="50-adb 85-python"    skip these ~/.emishrc/rc.d/ modules
#   EMISHRC_NO_UPDATE=1                never check for updates
#
# emishrc legacy update marker, do not remove: export _RCVERSION=50
[[ -r "$HOME/.emishrc/init.sh" ]] && source "$HOME/.emishrc/init.sh"
# =============================== end of emishrc ===============================

# ##############################################################################
# ##                                                                          ##
# ##      FROM HERE DOWN IT IS ALL YOURS.  emishrc stops at the line above.   ##
# ##                                                                          ##
# ##   Aliases, functions, exports: put them here. Updates never touch this   ##
# ##   file again, and it runs after emishrc, so what you write here wins.    ##
# ##                                                                          ##
# ##############################################################################

[[ $- != *i* ]] && return    # non-interactive shells stop here

# Starter globbing options emishrc put here for you. Change or delete freely.
shopt -s nocaseglob    # case-insensitive globs
shopt -s extglob       # extended patterns: !(x) +(x) @(x)
shopt -s globstar      # ** matches recursively

