#!/usr/bin/env bash
set -o errexit
set -o errtrace
set -o pipefail # Exit on errors

dirs=("/org/gnome/shell/"
    "/org/gnome/desktop/wm/"
    "/org/gnome/settings-daemon/plugins/media-keys/"
    "/org/gnome/mutter/"
    "/org/gnome/mutter/wayland/"
    "/org/gnome/terminal/legacy/")

if [[ $1 == "dump" ]]; then
    mkdir -p dconf
    for dir in ${dirs[@]}; do
        name=$(echo $dir | \sed 's/^.\(.*\).$/\1/g;s:/:.:g')
        echo "Dumping altered keys in $name..."
        dconf dump $dir >dconf/$name.dconf
    done
elif [[ $1 == "restore" ]]; then
    for file in dconf/*; do
        name=$(echo "/${file##.dconf}/" | \sed 's/\./\//g')
        echo "Loading keys for $name..."
        dconf load $name <$file
    done
else
    echo "Use \`$0 dump\` to dump current dconf settings to ./dconf"
    echo "Use \`$0 restore\` to load dconf settings, overwriting, from ./dconf"
fi
