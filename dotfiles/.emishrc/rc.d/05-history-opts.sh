#!/usr/bin/env bash
# shellcheck disable=SC2139,SC1001,SC2155,SC1090,SC1091,SC2034
# Part of emishrc -- MANAGED FILE, overwritten on update. Edit ~/.bashrc instead.

### ______           _       _____ _                        _   _   _ _     _
### | ___ \         | |     |  ___| |                      | | | | | (_)   | |
### | |_/ / __ _ ___| |__   | |__ | |_ ___ _ __ _ __   __ _| | | |_| |_ ___| |_ ___  _ __ _   _
### | ___ \/ _` / __| '_ \  |  __|| __/ _ \ '__| '_ \ / _` | | |  _  | / __| __/ _ \| '__| | | |
### | |_/ / (_| \__ \ | | | | |___| ||  __/ |  | | | | (_| | | | | | | \__ \ || (_) | |  | |_| |
### \____/ \__,_|___/_| |_| \____/ \__\___|_|  |_| |_|\__,_|_| \_| |_/_|___/\__\___/|_|   \__, |
###                                                                                        __/ |
###                                                                                       |___/
# Change the file location because certain bash sessions truncate .bash_history file upon close:
export HISTFILE=$HOME/.bash_eternal_history
# Maximum number of entries on the current session (nothing is infinite):
export HISTSIZE=5000000
# Maximum number of lines in HISTFILE (nothing is infinite).
export HISTFILESIZE=10000000
# Commands to ignore and skip saving
export HISTIGNORE="clear:exit:history:ls:gitl:gits"
# Ignores dupes and deletes old ones (latest doesn't work _quite_ properly, but does the trick)
export HISTCONTROL=ignoredups:erasedups
# Custom history time prefix format
export HISTTIMEFORMAT='[%F %T] '
# Writes multiline commands on the history as multiline entries
shopt -s cmdhist
shopt -s lithist
# Appends to history after every command instead of only after the shell session ends.
shopt -s histappend
# WIP/FIXME: Erases history dups on EXIT
# function historymerge() {
#     history -n
#     history -w
#     history -c
#     history -r
# }
# trap historymerge EXIT
