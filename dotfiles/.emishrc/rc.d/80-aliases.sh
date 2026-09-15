#!/usr/bin/env bash
# shellcheck disable=SC2139,SC1001,SC2155,SC1090,SC1091,SC2034
# Part of emishrc -- MANAGED FILE, overwritten on update. Edit ~/.bashrc instead.


###   ___  _ _                                        _    _____                     _     _
###  / _ \| (_)                                      | |  |  _  |                   (_)   | |
### / /_\ \ |_  __ _ ___  ___  ___     __ _ _ __   __| |  | | | |_   _____ _ __ _ __ _  __| | ___  ___
### |  _  | | |/ _` / __|/ _ \/ __|   / _` | '_ \ / _` |  | | | \ \ / / _ \ '__| '__| |/ _` |/ _ \/ __|
### | | | | | | (_| \__ \  __/\__ \  | (_| | | | | (_| |  \ \_/ /\ V /  __/ |  | |  | | (_| |  __/\__ \
### \_| |_/_|_|\__,_|___/\___||___/   \__,_|_| |_|\__,_|   \___/  \_/ \___|_|  |_|  |_|\__,_|\___||___/
## Allows using aliases after sudo (the ending space is what does teh trick)
alias sudo='sudo '


_e "blkid" && alias blkid="${GRC}blkid"
_e "docker" && alias docker="${GRC}docker"
_e "efibootmgr" && alias efibootmgr="${GRC}efibootmgr"
_e "du" && alias du="${GRC}du -h"
_e "free" && alias free="${GRC}free"
_e "fdisk" && alias fdisk="${GRC}fdisk"
_e "findmnt" && alias findmnt="${GRC}findmnt"
_e "make" && alias make="${GRC}make"
_e "gcc" && alias gcc="${GRC}gcc"
_e "g++" && alias g+"='${GRC}g++"
_e "id" && alias id="${GRC}id"
_e "ip" && alias ip="${GRC}ip"
_e "iptables" && alias iptables="${GRC}iptables"
_e "journalctl" && alias journalctl="${GRC}journalctl"
_e "kubectl" && alias kubectl="${GRC}kubectl"
_e "lsof" && alias lsof="${GRC}lsof"
_e "lsblk" && alias lsblk="${GRC}lsblk"
_e "lspci" && alias lspci="${GRC}lspci"
_e "netstat" && alias netstat="${GRC}netstat"
_e "ping" && alias ping="${GRC}ping"
_e "traceroute" && alias traceroute="${GRC}traceroute"
_e "traceroute6" && alias traceroute6="${GRC}traceroute6"
_e "dig" && alias dig="${GRC}dig"
_e "mount" && alias mount="${GRC}mount"
_e "ps" && alias ps="${GRC}ps"
_e "mtr" && alias mtr="${GRC}mtr"
_e "semanage" && alias semanage="${GRC}semanage"
_e "getsebool" && alias getsebool="${GRC}getsebool"
_e "ifconfig" && alias ifconfig="${GRC}ifconfig"
_e "sockstat" && alias sockstat="${GRC}sockstat"

## Navigation
alias ls="${GRC}ls -ltr --file-type --human-readable $_COLOR_ALWAYS_ARG --group-directories-first --literal --time-style=long-iso"
alias g="xdg-open"
