#!/bin/bash
####################
# Xorg Boilerplate #
####################
userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap
## Merge in defaults and keymaps
if [ -f $sysresources ]; then xrdb -merge $sysresources; fi
if [ -f $sysmodmap ]; then xmodmap $sysmodmap; fi
if [ -f "$userresources" ]; then xrdb -merge "$userresources"; fi
if [ -f "$usermodmap" ]; then xmodmap "$usermodmap"; fi
## Start some nice programs
if [ -d /etc/X11/xinit/xinitrc.d ]; then
    for f in /etc/X11/xinit/xinitrc.d/?*.sh; do
        [ -x "$f" ] && . "$f"
    done
    unset f
fi


###########
# ENVVARS #
###########
## Links bash to gnome-keyring-daemon
# dbus-update-activation-environment --systemd DISPLAY
# eval "$(/usr/bin/gnome-keyring-daemon --start --components=gpg,pkcs11,secrets,ssh)"
# export "$(gnome-keyring-daemon --start --components=pkcs11,secrets,ssh,gpg)"
# dbus-update-activation-environment --all --systemd

## Fixes HiDPI QT5 Applications (that respect the config)
## In particular, fixes copyq menu below
export QT_AUTO_SCREEN_SCALE_FACTOR=1

source ~/.bash_globals

#############
# AUTOSTART #
#############
## Do not use .config/autostart. Instead, add the immutable attribute on it,
## and bring everything you want to automatically start to here.
## This avoids random crap you do not want to autostart from autostarting, like
## dropbox, which doesn't work if it starts too early, steam, and other bullshit.

## Also, if no logic is needed, it's preferable to create systemd units into
## .config/systemd/user and enable them manually, or even create on-the-go units.

## Starts Deluge only if there's something to be downloaded
# sleep 5 && (
#     deluged && sleep 5 &&
#     if [[ $(deluge-console info | egrep -c 'Error|Downloading') -eq 0 ]]; then
#         killall deluged
#     else
#         killall deluged && systemd-run --user --unit deluge deluge
#     fi) &

## Starts electrum
# sleep 10 && systemd-run --user --unit electrum electrum --dir ~/.config/electrum --wallet ~/Documents/Wallets/native_wallet gui -m &

# ## Starts slack if it's job hours
# if [[ $(date +%u) -lt 6 && $(date +%_H) -ge 8 && $(date +%_H) -lt 18 ]]; then
#    echo 'Starting slack application...'
#    sleep 10s && slack -u &
# fi

## Starts Telegram
# sleep 5s && xdotool search --sync --onlyvisible --name '^Telegram$' windowminimize &
# sleep 2s && 64gram-desktop &

## Starts discord
# sleep 5s && xdotool search --sync --onlyvisible --name '^Discord$' windowminimize search --sync --onlyvisible --name '^Discord$' windowminimize &
# sleep 2s && discord &

## Starts spotify
# sleep 5s && xdotool search --sync --onlyvisible --name '^Discord$' windowminimize search --sync --onlyvisible --name '^Discord$' windowminimize &
# sleep 2s && spotify &

# sleep 2s && openrgb &

#syncthing-gtk &
solaar -w hide &
imwheel &
.config/xkb/set_custom_layout.sh &
.adb-mount-manager.sh &
## guake daemon
# guake &

# Copyq daemon
(while :; do sleep 5s && copyq; done) &

## Gnome: Ignore Lid Switch
#/usr/lib/gnome-tweak-tool-lid-inhibitor &
## Gnome: Allows to lock the screen
# gnome-screensaver &
## Gnome: turns on bluetooth automatically
# sleep 5s && rfkill unblock bluetooth &

## Loads XKB custom symbols map:
if [ -d ${HOME}/.config/xkb ]; then
    xkbcomp -I$HOME/.config/xkb $HOME/.config/xkb/custom_layout.xkb $DISPLAY -w 10
fi

############
# SESSIONS #
############
## Main Session
# GNOME on Xorg, using Gnome-Classic:
# export XDG_CURRENT_DESKTOP=GNOME-Classic:GNOME
# export GNOME_SHELL_SESSION_MODE=classic
# #exec gnome-session --session=gnome-flashback --builtin
# exec gnome-session --session=gnome-classic --systemd --debug

export XDG_SESSION_TYPE=x11
export GDK_BACKEND=x11
gnome-session #--systemd-service
# exec gnome-shell -r --x11 -d 0 -r --sm-disable --sync --mode user

#exec twm
#exec cinnamon-session
#exec mate-session
