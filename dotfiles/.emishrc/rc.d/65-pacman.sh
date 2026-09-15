#!/usr/bin/env bash
# shellcheck disable=SC2139,SC1001,SC2155,SC1090,SC1091,SC2034
# Part of emishrc -- MANAGED FILE, overwritten on update. Edit ~/.bashrc instead.

##  +-+-+-+-+-+-+-+-+-+-+
##  |p|a|c|m|a|n|/|y|a|y|
##  +-+-+-+-+-+-+-+-+-+-+
if _e "pacman"; then
    if _e "yay"; then
        function yayedit() {
            CURRDIR="$PWD"
            if ! yay -Ss "$1" | grep "aur/$1 " -qm 1; then
                echo "Package $1 does not exist."
                return
            fi
            echo "Will edit PKGBUILD of package $1"
            cd /tmp/yay/build/
            yay -G "$1"
            cd "$1"
            $EDITOR PKGBUILD
            echo "Press enter when done editing... Type 'n' and press enter if you don't want makepkg to overwrite changes in src!"
            read overwrite
            if [[ $overwrite == "n" ]]; then
                echo "Not overwriting src"
                makepkg -esi --skipchecksums
            else
                makepkg -si --skipchecksums
            fi

            cd "$CURRDIR"
        }
        function yay() {
            if [[ $# == 0 ]]; then
                # if running simply `yay`, then ask for packages to ignore
                command yay --noanswerupgrade -Syu
            fi
            command yay "$@"
        }
    fi
    alias pacman="pacman "
    alias pacs="sudo pacman -S --needed --asdeps"
    alias pacr="sudo pacman -R --recursive --unneeded --cascade"
    alias pacss="pacman -Ss"
    alias paci="pacman -Qi"
    alias pacl="pacman -Ql"
    alias paccache_safedelete="sudo paccache -r && sudo paccache -ruk1"
    # alias yay="yay -Syu --noanswerupgrade"
    complete -F _complete_alias pacs
    complete -F _complete_alias pacr
    complete -F _complete_alias pacss
    complete -F _complete_alias paci
    complete -F _complete_alias pacl
    complete -F _complete_alias paccache_safedelete

    ## Pacman Awesome Updater
    # function pacsyu() {
    #     echo -e "\e[01;93mUpdating pacman repositories...\e[00m"
    #     sudo pacman -Syu

    #     mkdir -p "$HOME/.pacman-updated"
    #     currentUpdatePkgs=$(\pacman -Qu --color never)
    #     previousUpdatePkgs=$(cat .pacman-updated/$(\ls -L .pacman-updated/ | tail -n1))
    #     if [[ "$currentUpdatePkgs" == "$previousUpdatePkgs" ]]; then
    #         echo -e "\e[00;92\nThis is the same list that was previously saved, not saving again.\e[00m"
    #     else
    #         echo -e "\e[01;93m\nSaving log of packages to upgrade...\e[00m"
    #         echo "$currentUpdatePkgs" >"$HOME/.pacman-updated/pacmanQu-$(date -Iminutes)"
    #     fi

    #     echo -e "\e[01;91m\nUpdating pacman packages...\e[00m"
    #     yay -Syu --noanswerupgrade -Syu
    # }

    ## NOT REQUIRED ANYMORE BECAUSE BTRFS
    # function pacman_rollback() {
    #     echo 'WARNING THIS IS A WIP. CHECK THE SOURCE FIRST AND RUN MANUALLY.'
    #     return 1
    #     if [[ -f $1 ]]; then
    #         while read line; do
    #             pkg=$(echo "$i" | sed 's/ -> .+//' | sed 's/ /-/')
    #             echo "Downgrading $pkg"
    #             sudo pacman --noconfirm --needed -U /var/cache/pacman/pkg/$pkg*
    #         done < <(cat $1)
    #     fi
    # }

    # Optimizes pacman stuff (TODO: does it?)
    alias pacfix='sudo pacman-optimize; sudo pacman -S $(pacman -Qkqn | sed -E "s/ .+$//" | uniq | xargs); paccache -k2 --min-mtime "60 days ago" -rv'
fi

#    ___ ___ _____
#   / __|_ _|_   _|
#  | (_ || |  | |
