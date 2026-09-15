#!/usr/bin/env bash
# shellcheck disable=SC2139,SC1001,SC2155,SC1090,SC1091,SC2034
# Part of emishrc -- MANAGED FILE, overwritten on update. Edit ~/.bashrc instead.

##  +-+-+-+-+-+-+-+-+-+
##  |s|y|s|t|e|m|c|t|l|
##  +-+-+-+-+-+-+-+-+-+
if _e "systemctl"; then
    function _scomps() {
        _complete_systemd_units "$1"
    }
    function _systemd_control() {
        local action="$1"
        local requested
        local scope
        local unit

        shift
        requested="${1:-}"
        [[ $# -gt 0 ]] && shift

        if [[ -z "$requested" ]]; then
            systemctl "$action" "$@"
            return
        fi

        read -r scope unit < <(_systemd_resolve_control_unit "$requested") || {
            echo "${action}: no systemd unit found for '$requested'" >&2
            return 1
        }

        if [[ "$scope" == "user" ]]; then
            systemctl --user "$action" "$unit" "$@"
        else
            systemctl "$action" "$unit" "$@"
        fi
    }
    function _sstart() {
        _scomps inactive
    }
    function _sstop() {
        _scomps running
    }
    function _srestart() {
        _scomps loaded
    }
    function _sstatus() {
        _scomps loaded
    }
    function _senable() {
        _scomps disabled
    }
    function _sdisable() {
        _scomps enabled
    }

    sstart() {
        _systemd_control start "$@"
    }
    complete -F _sstart sstart
    sstop() {
        _systemd_control stop "$@"
    }
    complete -F _sstop sstop
    srestart() {
        _systemd_control restart "$@"
    }
    complete -F _srestart srestart
    sstatus() {
        _systemd_control status "$@"
    }
    complete -F _sstatus sstatus
    senable() {
        _systemd_control enable "$@"
    }
    complete -F _senable senable
    sdisable() {
        _systemd_control disable "$@"
    }
    complete -F _sdisable sdisable
fi
