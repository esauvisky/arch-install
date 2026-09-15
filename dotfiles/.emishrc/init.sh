#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091,SC2155
#
#   emi's bashrc -- entry point
#
#   MANAGED FILE. Everything under ~/.emishrc/ is replaced wholesale on update.
#   Your own aliases, functions and exports belong in ~/.bashrc, which the
#   updater never touches. This file is sourced from the top of it.
#
#   Escape hatches (set them in the environment or above the emishrc block):
#     EMISHRC_DISABLE=1              skip emishrc entirely
#     EMISHRC_SKIP="50-adb 85-python"   skip individual rc.d modules
#     EMISHRC_NO_UPDATE=1            never phone home for updates
#
#   https://github.com/esauvisky/arch-install

## Interactive shells only. `return` here only leaves this file, so the rest of
## the user's .bashrc still runs (or hits its own non-interactive guard).
[[ $- != *i* ]] && return 0

## Opt-out.
[[ ${EMISHRC_DISABLE:-0} == 1 ]] && return 0

## Don't load twice. Protects against a stale legacy .bashrc that still has the
## old monolith inlined, and against people re-sourcing ~/.bashrc by hand.
[[ -n ${_EMISHRC_LOADED:-} ]] && return 0
_EMISHRC_LOADED=1

## Resolve our own directory so a copy in /etc/skel or a checkout elsewhere works.
if [[ -n ${BASH_SOURCE[0]:-} ]]; then
    EMISHRC_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)
else
    EMISHRC_DIR="$HOME/.emishrc"
fi
export EMISHRC_DIR

[[ -r "$EMISHRC_DIR/VERSION" ]] || return 0

## Version, changelog and the self-updater.
source "$EMISHRC_DIR/update.sh"

## Check for updates in the background, at most once a day.
if [[ ${EMISHRC_NO_UPDATE:-0} != 1 ]]; then
    (check_updates 2>/dev/null & disown)
fi

## Load the modules, in filename order.
for _emishrc_mod in "$EMISHRC_DIR"/rc.d/*.sh; do
    [[ -r $_emishrc_mod ]] || continue
    if [[ -n ${EMISHRC_SKIP:-} ]]; then
        _emishrc_name=${_emishrc_mod##*/}
        _emishrc_name=${_emishrc_name%.sh}
        [[ " $EMISHRC_SKIP " == *" $_emishrc_name "* ]] && continue
    fi
    source "$_emishrc_mod"
done
unset _emishrc_mod _emishrc_name

## Greet: show the changelog once per version bump, otherwise a rare fortune.
_emishrc_greet() {
    local seen=""
    [[ -s $_EMISHRC_SEEN ]] && seen=$(< "$_EMISHRC_SEEN")

    if [[ ${seen//[^0-9]/} != "$_RCVERSION" ]]; then
        _changelog
        echo "$_RCVERSION" >"$_EMISHRC_SEEN" 2>/dev/null
    elif [[ $RANDOM -lt 10000 ]]; then
        _e "fortune" "cowthink" "lolcat" &&
            fortune -s -n 200 | PERL_BADLANG=0 cowthink | lolcat -F 0.1 -p 30 -S 1
    fi
}
[[ -n ${PS1:-} ]] && _emishrc_greet

return 0
