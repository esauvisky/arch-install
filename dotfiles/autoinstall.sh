#!/usr/bin/env bash
set -o errexit; set -o errtrace; set -o pipefail # Exit on errors
# Uncomment line below for debugging:
#PS4=$'+ $(tput sgr0)$(tput setaf 4)DEBUG ${FUNCNAME[0]:+${FUNCNAME[0]}}$(tput bold)[$(tput setaf 6)${LINENO}$(tput setaf 4)]: $(tput sgr0)'; set -o xtrace
__deps=( "sed" "grep" )
for dep in ${__deps[@]}; do hash $dep >& /dev/null || (echo "$dep was not found. Please install it and try again." && exit 1); done


dotfiles=( ".bashrc" ".bash_completion" ".dircolors" ".inputrc" ".toprc" )


cd "$HOME"

if gio trash $(mktemp -p .); then
    # has gio support, can send older scripts to trash
    for dep in ${dotfiles[@]}; do
        echo "Downloading script $dep from esauvisky/arch-install/master/dotfiles"
        url="https://raw.githubusercontent.com/esauvisky/arch-install/master/dotfiles/$dep"
        wget "$url" || curl -o "$dep.1" "$url"
        gio trash "./$dep"
        mv "./$dep.1" "./$dep"
        if [[ -f "./$dep" ]]; then
            echo -e "All good! Moving on...\n"
        fi
    done
    echo -e "Everything went well! Your old files are in the trashbin in case something explodes. Buh-bye!"
else
    # no gio support, better backup in place
    for dep in ${dotfiles[@]}; do
        echo "Downloading script $dep from esauvisky/arch-install/master/dotfiles"
        url="https://raw.githubusercontent.com/esauvisky/arch-install/master/dotfiles/$dep"
        wget "$url" || curl -o "$dep.1" "$url"
        mv "./$dep" "./$dep.bak"
        mv "./$dep.1" "./$dep"
        if [[ -f "./$dep" ]]; then
            echo -e "All good! Moving on...\n"
        fi
    done
    echo -e "Everything went well! Your old files are backed up with a .bak extension! Buh-bye!"
fi
