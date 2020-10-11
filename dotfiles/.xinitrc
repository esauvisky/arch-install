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
## Forces Radeon GPU for everything (don't. just don't do it unless you want your house in fire)
#export DRI_PRIME=0

## Links bash to gnome-keyring-daemon
eval "$(/usr/bin/gnome-keyring-daemon --start --components=gpg,pkcs11,secrets,ssh)"
dbus-update-activation-environment --systemd DISPLAY
export "$(gnome-keyring-daemon --start --components=pkcs11,secrets,ssh,gpg)"

#############
# AUTOSTART #
#############
## Do not use .config/autostart. Instead, add the immutable attribute on it,
## and bring everything you want to automatically start to here.
## This avoids random crap you do not want to autostart from autostarting, like
## dropbox, which doesn't work if it starts too early, steam, and other bullshit.

## Also, if no logic is needed, it's preferable to create systemd units into
## .config/systemd/user and enable them manually, or even create on-the-go units.


## Starts rclone and immediatly closes it (doesn't quite work)
# xdotool search --sync --onlyvisible --name '(\([0-9]*\) ){0,1}(rclone$|rclone Web$)' windowminimize &
# rclone-browser &


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


# ## Starts WhatsApp and immediatly closes it
# sleep 15s && xdotool search --sync --onlyvisible --name '.*WhatsApp|WhatsApp Web)' windowminimize &
# sleep 10s && whatsapp-nativefier &


## Starts Telegram and immediatly closes it
sleep 5s && xdotool search --sync --onlyvisible --name '^Telegram$' windowminimize &
sleep 10s && telegram-desktop &

## Starts discord
sleep 6s && xdotool search --sync --onlyvisible --name '^Discord$' windowminimize search --sync --onlyvisible --name '^Discord$' windowminimize &
sleep 12s && discord-open &

# ## Starts slack if it's job hours
# if [[ $(date +%u) -lt 6 && $(date +%_H) -ge 8 && $(date +%_H) -lt 18 ]]; then
#    echo 'Starting slack application...'
#    sleep 10s && slack -u &
# fi


# ## Starts guake
sleep 5s && guake &


# ## Gnome: Ignore Lid Switch
sleep 5s && /usr/lib/gnome-tweak-tool-lid-inhibitor &
# ## Gnome: Allows to lock the screen
# gnome-screensaver &

############
# SESSIONS #
############
## Main Session
# GNOME on Xorg, using Gnome-Classic:
# export GDK_BACKEND=x11
# export XDG_CURRENT_DESKTOP=GNOME-Classic:GNOME
# export GNOME_SHELL_SESSION_MODE=classic
# #exec gnome-session --session=gnome-flashback --builtin
# exec gnome-session --session=gnome-classic --systemd --debug

export XDG_SESSION_TYPE=x11
export GDK_BACKEND=x11
exec gnome-session --systemd

## Crap! gnome-shell sucks ass!
#exec twm
#exec cinnamon-session
#exec mate-session

