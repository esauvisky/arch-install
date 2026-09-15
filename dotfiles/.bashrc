#!/usr/bin/env bash
#
# ~/.bashrc
#

# >>> emishrc >>>
# Managed block -- keep it at the very top of this file.
# Loads emi's bashrc from ~/.emishrc/ (https://github.com/esauvisky/arch-install).
# Updates ONLY ever rewrite ~/.emishrc/. This file is yours: edit it freely,
# it will never be overwritten again. Anything you (or an installer) put below
# runs after emishrc, so your settings always win.
# Set EMISHRC_DISABLE=1 above this line to turn it off.
# emishrc legacy update marker, do not remove: export _RCVERSION=48
[[ -r "$HOME/.emishrc/init.sh" ]] && source "$HOME/.emishrc/init.sh"
# <<< emishrc <<<

# If not running interactively, don't do anything else.
[[ $- != *i* ]] && return

## Dangerous stuff that interferes with scripts.
# Allows non case-sensitive wildcard globs (*, ?):
shopt -s nocaseglob
# Allows extended wildcard globs
shopt -s extglob
# Enables the ** glob
shopt -s globstar

# Your aliases, functions and exports go below.
