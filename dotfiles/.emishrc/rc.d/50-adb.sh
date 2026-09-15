#!/usr/bin/env bash
# shellcheck disable=SC2139,SC1001,SC2155,SC1090,SC1091,SC2034
# Part of emishrc -- MANAGED FILE, overwritten on update. Edit ~/.bashrc instead.

##  +-+-+-+-+-+-+-+ +-+-+-+-+-+ +-+-+-+-+-+-+
##  |a|n|d|r|o|i|d| |d|e|b|u|g| |b|r|i|d|g|e|
##  +-+-+-+-+-+-+-+ +-+-+-+-+-+ +-+-+-+-+-+-+
if _e "adb"; then
    _adb_devices=()
    function _adb_get_devices() {
        # this is how they actually do it officially lol:
        # _adb_devices=$(command adb devices 2> /dev/null | grep -v "List of devices" | awk '{ print $1 }');
        # this is more robust and works with offline devices sorry
        readarray -t _adb_devices < <(command adb devices -l 2>/dev/null | sed -E $'1d;$d;/.+offline.+/d' | awk '{print $1}')
    }
    function _adb_get_target_device() {
        # if there are multiple devices connected,
        # show a selector using select_option
        # otherwise, just return the first device
        if [[ ${#_adb_devices[@]} -gt 1 ]]; then
            echo "Multiple devices connected, please select one:"
            select_option "${_adb_devices[@]}"
            return $?
        else
            echo "${_adb_devices[0]}"
        fi
    }
    function adb() {
        local _ADB_CMDS_TO_SHOW_SELECTOR=("push" "pull" "shell" "install" "install-multiple" "install-multi-package" "uninstall"
            "bugreport" "logcat" "lolcat" "sideload" "usb" "tcpip" "root" "unroot" "reboot" "remount")
        if [[ $1 == "devices" && ($# == 1) ]] && _e grcat && [[ -f "$HOME/.grc/conf.efibootmgr" ]]; then
            while read -r a b c; do
                [[ $a != "" || $b != "" || $c != "" ]] && printf "%-7s %-28s%s\n" "$a" "$b" "$c"
            done < <(command adb devices -l | sed '1d;$d' |
                sed -E $'s/(.+) +offline .+device:(.+) transport_id:([0-9]+)/TID=\\3\tserial=\\1\tproduct=\\2\E[31;01m OFFLINE\E[00m/' |
                sed -E $'s/(.+) +unauthorized +transport_id:([0-9]+)/TID=\\2\tserial=\\1\t\E[31;01mUNAUTHORIZED\E[00m/' |
                sed -E "s/([^ ]+) +device .+device:(.+) transport_id:([0-9]+)/TID=\3\tserial=\1\tproduct=\2/") | grcat "$HOME/.grc/conf.efibootmgr"
        else
            _adb_get_devices
            # if there is no device specified
            # and the command is in the list of commands to show a selector for
            if [[ ($1 != "-s" && $1 != "-d" && $1 != "-e" && $1 != "-t") && " ${_ADB_CMDS_TO_SHOW_SELECTOR[*]} " =~ " $1 " && ${#_adb_devices[@]} -gt 1 ]]; then
                # if there are multiple devices connected
                _adb_get_target_device
                local ret=$?
                if [[ ${_adb_devices[$ret]} != "" ]]; then
                    command adb -s "${_adb_devices[$ret]}" "${@:1}"
                elif [[ $ret -eq 255 ]]; then
                    echo "Maybe next time."
                else
                    command adb "${@}"
                fi
            else
                command adb "${@}"
            fi
        fi
    }
    alias logcat=$'adb logcat -b all -v color,usec,uid -T "$(date \'+%F %T.000\' --date=\'5 minutes ago\')"'
    complete -F _complete_alias logcat
fi
