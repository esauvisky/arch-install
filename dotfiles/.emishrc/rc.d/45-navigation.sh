#!/usr/bin/env bash
# shellcheck disable=SC2139,SC1001,SC2155,SC1090,SC1091,SC2034
# Part of emishrc -- MANAGED FILE, overwritten on update. Edit ~/.bashrc instead.

##  +-+-+-+-+ +-+-+-+-+-+-+-+
##  |E|a|s|y| |E|x|t|r|a|c|t|
##  +-+-+-+-+ +-+-+-+-+-+-+-+
## Extracts compressed and archived files of any type
## without having to remember every single fucking argument
## for every single fucking compressed file extension
function extract() {
    for n in "$@"; do
        if [ -f "$n" ]; then
            case "${n%,}" in
            *.cbt | *.tar.bz2 | *.tar.gz | *.tar.xz | *.tbz2 | *.tgz | *.txz | *.tar)
                tar xvf "$n"
                ;;
            *.lzma) unlzma ./"$n" ;;
            *.bz2) bunzip2 ./"$n" ;;
            *.cbr | *.rar) unrar x -ad ./"$n" ;;
            *.gz) gunzip ./"$n" ;;
            *.cbz | *.epub | *.zip) unzip ./"$n" ;;
            *.z) uncompress ./"$n" ;;
            *.7z | *.arj | *.cab | *.cb7 | *.chm | *.deb | *.dmg | *.iso | *.lzh | *.msi | *.pkg | *.rpm | *.udf | *.wim | *.xar)
                7z x ./"$n"
                ;;
            *.xz) unxz ./"$n" ;;
            *.exe) cabextract ./"$n" ;;
            *.cpio) cpio -id <./"$n" ;;
            *.cba | *.ace) unace x ./"$n" ;;
            *)
                echo "extract: '$n' - unknown archive method"
                return 1
                ;;
            esac
        else
            echo "'$n' - file does not exist"
            return 1
        fi
    done
}

##  +-+-+-+-+-+-+-+
##  |m|a|g|i|c|C|D|
##  +-+-+-+-+-+-+-+
## Searches for directories recursively and cds into them
## Usage:
##   alias ALIAS_NAME='_magicCD DIR_DEPTH BASE_DIR
## Where DIR_DEPTH is how many nested directories from
## within BASE_DIR to recursively search into.
## Author: emi~
##
## Example:
## Suppose you have this structure:
## - $HOME/Coding/
##   - Projects/
##       - project_1/
##       - project_2/
##       - foo/
##   - Personal/
##      - secret_self_bot/
##      - wip_project/
##
## If you add to this file,
##   alias cdp='_magicCD 2 $HOME/Coding/'
## then if you run,
## cdp: will send you to $HOME/Coding/
## cdp proj: will show you a selector with all the dirs containing 'proj',
##           i.e.: $HOME/Coding/Projects/project_1 and 2 and wip_project from Personal
## cdp wip: will directly send you to the only dir containing 'wip'
##           i.e.: $HOME/Coding/Projects/wip_project
function _magicCD() {
    if [[ ! -d "$2" && ! "$1" -ge 2 ]]; then
        echo "Error in the syntax."
        return 1
    fi

    __MAGIC_CD_DIR="${2}"
    __DEPTH="${1}"
    shift
    shift

    # If the search query is exactly the dir name
    # then just cd
    if [[ -d "${1}" ]]; then
        cd "${1}"
        return
    elif [[ -d "${__MAGIC_CD_DIR}${1}" ]]; then
        cd "${__MAGIC_CD_DIR}${1}"
        return
    fi

    # Black magic ;)
    # results=()
    # while IFS=  read -r -d $'\0'; do
    #     results+=("$REPLY")
    # done < <(find "${__MAGIC_CD_DIR}" -depth  -maxdepth 2 -type d -iname \*${*}\* -print0)

    # Neat black magic (bash 4.4 only)
    readarray -d '' results < <(find -L ${__MAGIC_CD_DIR} -maxdepth ${__DEPTH} -path "*node_modules*" -prune -o -type d -iname \*${*}\* -print0)

    if [[ ${#results[@]} -eq 1 ]]; then
        # If there's an unique result for the argument, cd into it:
        cd "${results[0]}"
    elif [[ ${#results[@]} -eq 0 || ${#results[@]} -gt 20 ]]; then
        cd "${__MAGIC_CD_DIR}"
    else
        # Let the user choose
        select_option "${results[@]}"
        cd "${results[$?]}"
    fi
}

##  +-+-+-+-+-+-+
##  |F|I|N|D|I|R|
##  +-+-+-+-+-+-+
## Finds directories recursively, and shows select_option
## afterwards if less than 20 results.
function findir() {
    readarray -d '' results < <(find . -path "*node_modules*" -prune -o -type d -iname \*"${1}"\* -print0 2>/dev/null)

    if [[ ${#results[@]} -eq 1 ]]; then
        # If there's an unique result for the argument, cd into it:
        cd "${results[0]}"
    elif [[ ${#results[@]} -eq 0 || ${#results[@]} -gt 20 ]]; then
        printf '%s\n' "${results[@]}"
    else
        # Let the user choose
        select_option "${results[@]}"
        cd "${results[$?]}"
    fi
}

##  +-+-+-+-+-+-+
##  |c|d|c|o|o|l|
##  +-+-+-+-+-+-+
## This shows a selector to quickly change
## cd into commonly used, hard-to-type directories,
## changing to a su prompt if the user doesn't have
## reading permissions as well.
function cdcool() {
    # Filters the array in case there's an arg
    if [[ -n "$1" ]]; then
        for index in "${!cool_places[@]}"; do
            if [[ ! ${cool_places[$index]} =~ $1 ]]; then
                unset -v 'cool_places[$index]'
            fi
        done
    fi

    # Let the user choose
    if [[ ${#cool_places[@]} -eq 1 ]]; then
        selected_index=0
    else
        select_option "${cool_places[@]}"
        selected_index="$?"
    fi

    final_path="${cool_places[$selected_index]/#\$HOME/$HOME}"

    if [[ ! -d "$final_path" ]]; then
        echo "The selected path does not exist. Fix your script." && return 1
    elif ! test -r "$final_path"; then
        echo -n "No read permissions for $final_path! "
        sudo su root sh -c "cd $final_path; bash" # don't ask, just don't.
    else
        cd "$final_path" || return 1
    fi
}
## List of places to show when using 'cdcool [arg]'
cool_places=(
    "$HOME/.local/share/gnome-shell/extensions"
    "$HOME/.local/share/nautilus/scripts"
    "$HOME/.local/share/applications"
    "$HOME/.config/systemd/user/"
    "/etc/systemd/user/"
    "/var/cache/pacman/pkg/"
    "/var/lib/docker/volumes"
    "/usr/share/bash-completion/completions"
)
