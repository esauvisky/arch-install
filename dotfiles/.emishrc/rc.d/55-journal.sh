#!/usr/bin/env bash
# shellcheck disable=SC2139,SC1001,SC2155,SC1090,SC1091,SC2034
# Part of emishrc -- MANAGED FILE, overwritten on update. Edit ~/.bashrc instead.

##  +-+-+-+-+-+-+-+-+-+-+
##  |j|o|u|r|n|a|l|c|t|l|
##  +-+-+-+-+-+-+-+-+-+-+
_SYSTEMD_UNIT_TYPES=(service socket timer target path mount automount slice scope)
_SYSTEMD_UNIT_FILE_TYPES=(service socket timer target path mount automount)

function _journal_paint() {
    if [[ ! -t 1 && -z ${_JOURNAL_PAINT_FORCE:-} ]]; then
        cat
        return
    fi

    awk '
        BEGIN {
            red = "\033[1;31m"
            yellow = "\033[1;33m"
            green = "\033[1;32m"
            cyan = "\033[1;36m"
            reset = "\033[0m"
        }
        {
            line = $0
            lower = tolower(line)
            message_color = ""
            if (lower ~ /(panic|segfault|fatal|critical|failed|failure|error|exception|traceback|denied)/) {
                message_color = red
            } else if (lower ~ /(warning|warn|timeout|timed out|refused|unreachable|degraded)/) {
                message_color = yellow
            } else if (lower ~ /(started|listening|mounted|reached|success|succeeded)/) {
                message_color = green
            } else if (lower ~ /(gnome-shell|kernel|systemd|sudo)/) {
                message_color = cyan
            }

            # Keep the same useful shape as direct journalctl/grc output:
            # timestamp, process, and PID remain visible even for normal lines.
            if (match(line, /^[^ ]+ +[0-9]+ +[0-9:.]+ +/) == 1) {
                timestamp = substr(line, RSTART, RLENGTH)
                rest = substr(line, RSTART + RLENGTH)
                if (match(rest, /^[^:]+: /) == 1) {
                    process = substr(rest, RSTART, RLENGTH)
                    message = substr(rest, RSTART + RLENGTH)
                    if (message_color == "") {
                        print yellow timestamp "\033[1;34m" process reset message
                    } else {
                        print yellow timestamp "\033[1;34m" process reset message_color message reset
                    }
                } else if (message_color != "") {
                    print message_color line reset
                } else {
                    print line
                }
            } else if (message_color != "") {
                print message_color line reset
            } else {
                print line
            }
            fflush()
        }
    '
}

function _journal_pretty() {
    command journalctl --no-hostname --output short-precise --no-pager -l "$@" | _journal_paint
}

function _systemd_has_unit_suffix() {
    local unit="$1"
    local suffix
    for suffix in "${_SYSTEMD_UNIT_TYPES[@]}"; do
        [[ "$unit" == *."$suffix" ]] && return 0
    done
    return 1
}

function _systemd_completion_base() {
    local unit="$1"
    local suffix
    for suffix in "${_SYSTEMD_UNIT_TYPES[@]}"; do
        [[ "$unit" == *."$suffix" ]] && {
            printf '%s\n' "${unit%.$suffix}"
            return
        }
    done
    printf '%s\n' "$unit"
}

function _systemd_completion_prefix() {
    local unit="$1"
    local suffix
    local tail

    if [[ "$unit" == *.* ]]; then
        tail="${unit##*.}"
        for suffix in "${_SYSTEMD_UNIT_TYPES[@]}"; do
            [[ "$suffix" == "$tail"* ]] && {
                printf '%s\n' "${unit%.*}"
                return
            }
        done
    fi

    printf '%s\n' "$unit"
}

function _systemd_candidate_units() {
    local unit="$1"
    local suffix

    [[ -z "$unit" ]] && return 1

    if _systemd_has_unit_suffix "$unit"; then
        printf '%s\n' "$unit"
        return
    fi

    for suffix in "${_SYSTEMD_UNIT_TYPES[@]}"; do
        printf '%s.%s\n' "$unit" "$suffix"
    done
}

function _systemd_unit_exists() {
    local scope="$1"
    local unit="$2"
    local load_state

    if [[ "$scope" == "user" ]]; then
        load_state=$(systemctl --user show --property=LoadState --value "$unit" 2>/dev/null)
    else
        load_state=$(systemctl show --property=LoadState --value "$unit" 2>/dev/null)
    fi

    [[ -n "$load_state" && "$load_state" != "not-found" ]]
}

function _systemd_resolve_units() {
    local unit="$1"
    local candidate
    local found=1

    while read -r candidate; do
        if _systemd_unit_exists user "$candidate"; then
            printf 'user %s\n' "$candidate"
            found=0
        fi
        if _systemd_unit_exists system "$candidate"; then
            printf 'system %s\n' "$candidate"
            found=0
        fi
    done < <(_systemd_candidate_units "$unit")

    return "$found"
}

function _systemd_resolve_control_unit() {
    local unit="$1"
    local scope
    local resolved
    local user_match=

    while read -r scope resolved; do
        if [[ "$scope" == "system" ]]; then
            printf 'system %s\n' "$resolved"
            return 0
        fi
        [[ -z "$user_match" ]] && user_match="$resolved"
    done < <(_systemd_resolve_units "$unit")

    if [[ -n "$user_match" ]]; then
        printf 'user %s\n' "$user_match"
        return 0
    fi

    return 1
}

function _systemctl_exists_user() {
    local scope
    local unit

    read -r scope unit < <(_systemd_resolve_control_unit "$1") || return 1
    [[ "$scope" == "user" ]]
}

function _systemd_list_units() {
    local scope="$1"
    local state="${2:-}"
    local unit_type_arg
    local unit_file_type_arg

    unit_type_arg=$(IFS=, ; echo "${_SYSTEMD_UNIT_TYPES[*]}")
    unit_file_type_arg=$(IFS=, ; echo "${_SYSTEMD_UNIT_FILE_TYPES[*]}")

    if [[ "$scope" == "user" ]]; then
        if [[ "$state" == "enabled" || "$state" == "disabled" ]]; then
            systemctl --user list-unit-files --all --no-legend --no-pager --type="$unit_file_type_arg" --state="$state" 2>/dev/null | awk '{print $1}'
        elif [[ -n "$state" && "$state" != "loaded" ]]; then
            systemctl --user list-units --all --no-legend --no-pager --type="$unit_type_arg" --state="$state" 2>/dev/null | awk '{print $1}'
        else
            systemctl --user list-units --all --no-legend --no-pager --type="$unit_type_arg" 2>/dev/null | awk '{print $1}'
            systemctl --user list-unit-files --all --no-legend --no-pager --type="$unit_file_type_arg" 2>/dev/null | awk '{print $1}'
        fi
    else
        if [[ "$state" == "enabled" || "$state" == "disabled" ]]; then
            systemctl list-unit-files --all --no-legend --no-pager --type="$unit_file_type_arg" --state="$state" 2>/dev/null | awk '{print $1}'
        elif [[ -n "$state" && "$state" != "loaded" ]]; then
            systemctl list-units --all --no-legend --no-pager --type="$unit_type_arg" --state="$state" 2>/dev/null | awk '{print $1}'
        else
            systemctl list-units --all --no-legend --no-pager --type="$unit_type_arg" 2>/dev/null | awk '{print $1}'
            systemctl list-unit-files --all --no-legend --no-pager --type="$unit_file_type_arg" 2>/dev/null | awk '{print $1}'
        fi
    fi
}

function _systemd_completion_units() {
    local state="${1:-}"

    {
        _systemd_list_units system "$state"
        _systemd_list_units user "$state"
    } | while read -r unit; do
        [[ -n "$unit" ]] && _systemd_completion_base "$unit"
    done | sort -u
}

function _complete_systemd_units() {
    local cur
    local prefix
    local -a matches
    local state="${1:-}"
    local unit

    COMPREPLY=()
    cur=${COMP_WORDS[COMP_CWORD]}
    prefix=$(_systemd_completion_prefix "$cur")
    matches=()

    while IFS= read -r unit; do
        [[ -n "$unit" ]] || continue
        [[ "$unit" == "$prefix"* ]] || continue
        [[ "$unit" =~ [^[:print:]] ]] && continue
        matches+=("$unit")
    done < <(_systemd_completion_units "$state")

COMPREPLY=("${matches[@]}")
}

if _e "journalctl"; then
    function _systemd_running_service_units() {
        {
            systemctl list-units --type=service --state=running --no-legend --no-pager 2>/dev/null | awk '{print "system " $1}'
            systemctl --user list-units --type=service --state=running --no-legend --no-pager 2>/dev/null | awk '{print "user " $1}'
        } | awk 'NF == 2 && $2 ~ /\.service$/ && $2 !~ /[^[:print:]]/ && !seen[$0]++'
    }

    function _systemd_running_service_matches() {
        local query="$1"

        _systemd_running_service_units | awk -v query="$query" '
            index(tolower($2), tolower(query)) { print }
        '
    }

    function _complete_log_services() {
        local cur
        local prefix
        local scope
        local unit
        local -a matches=()

        COMPREPLY=()
        cur=${COMP_WORDS[COMP_CWORD]}
        prefix=$(_systemd_completion_prefix "$cur")

        while read -r scope unit; do
            [[ -n "$unit" ]] || continue
            unit=$(_systemd_completion_base "$unit")
            [[ "$unit" == "$prefix"* ]] || continue
            matches+=("$unit")
        done < <(_systemd_running_service_units)

        if ((${#matches[@]})); then
            COMPREPLY=($(printf '%s\n' "${matches[@]}" | sort -u))
        fi
    }

    function log() {
        local boot_arg=()
        local extra_args=()
        local follow=1
        local less_init='+F'
        local user_n=0
        local opts_with_args=(-p -u -n -S -t -o -g -D -M -F -c -x)
        local arg i opt
        local resolved_scope
        local resolved_unit

        # Refresh sudo timestamp so the viewer doesn't have to interrupt later.
        if _e sudo; then
            sudo -v 2>/dev/null || true
        fi

        for ((i = 1; i <= $#; i++)); do
            arg="${!i}"

            case "$arg" in
                -[0-9]|-[0-9][0-9]*)
                    if [[ "$arg" == "-0" ]]; then
                        boot_arg=(-b)
                    else
                        boot_arg=(-b "$arg")
                    fi
                    follow=0
                    less_init='+G'
                    ;;
                --since|--until)
                    extra_args+=("$arg")
                    if (( i + 1 <= $# )) && [[ "${@:i+1:1}" != -* ]]; then
                        extra_args+=("${@:i+1:1}")
                        ((i++))
                    fi
                    ;;
                --*)
                    extra_args+=("$arg")
                    ;;
                -[A-Za-z]*)
                    extra_args+=("$arg")
                    opt="${arg:0:2}"
                    if [[ " ${opts_with_args[*]} " == *" $opt "* ]]; then
                        if (( i + 1 <= $# )) && [[ "${@:i+1:1}" != -* ]]; then
                            extra_args+=("${@:i+1:1}")
                            [[ "$opt" == "-n" ]] && user_n=1
                            ((i++))
                        fi
                    fi
                    ;;
                *)
                    if [[ "$arg" == *=* ]]; then
                        extra_args+=("$arg")
                        continue
                    fi

                    local log_match_count=0
                    while read -r resolved_scope resolved_unit; do
                        if [[ "$resolved_scope" == "system" ]]; then
                            extra_args+=(--unit "$resolved_unit")
                        else
                            extra_args+=(--user-unit "$resolved_unit")
                        fi
                        ((log_match_count++))
                    done < <(_systemd_running_service_matches "$arg")

                    if (( log_match_count == 0 )); then
                        extra_args+=("-g" "$arg")
                    fi
                    ;;
            esac
        done

        local jcmd=(journalctl --no-hostname --output short-precise -l)
        if (( ${#boot_arg[@]} )); then
            jcmd+=("${boot_arg[@]}")
        else
            jcmd+=(-b)
        fi
        jcmd+=("${extra_args[@]}")
        local _JOURNAL_PAINT_FORCE=1
        export _JOURNAL_PAINT_FORCE
        if (( follow )); then
            (( user_n )) || jcmd+=(-n 500)
            jcmd+=(-f)
            ( trap '' INT; command "${jcmd[@]}" | _journal_paint ) | less -R "$less_init"
        else
            command "${jcmd[@]}" | _journal_paint | less -R "$less_init"
        fi
    }
    function st() {
        local unit="$1"
        local scope
        local resolved
        local matches=()
        local match_count=0

        if [[ -z "$unit" ]]; then
            echo "Usage: st <systemd-unit>"
            return 2
        fi

        while read -r scope resolved; do
            matches+=("$scope:$resolved")
            ((match_count++))
        done < <(_systemd_resolve_units "$unit")

        if [[ "$match_count" -eq 0 ]]; then
            echo "st: no systemd unit found for '$unit'" >&2
            echo "Try tab completion with the base name, for example: st pulseaudio" >&2
            return 1
        fi

        for match in "${matches[@]}"; do
            scope="${match%%:*}"
            resolved="${match#*:}"
            if [[ "$match_count" -gt 1 ]]; then
                printf '\e[1;36m==> %s %s\e[0m\n' "$scope" "$resolved"
            fi
            if [[ "$scope" == "user" ]]; then
                _journal_pretty -b -n "${ST_LINES:-200}" _SYSTEMD_USER_UNIT="$resolved"
            else
                _journal_pretty -b -n "${ST_LINES:-200}" _SYSTEMD_UNIT="$resolved"
            fi
        done
    }
    function _complete_journalctl() {
        _complete_systemd_units
    }
    function _sys_section() {
        if [[ -t 1 || -n ${_SYS_COLOR_FORCE:-} ]]; then
            printf '\n\033[1;35m==> %s\033[0m\n' "$1"
        else
            printf '\n==> %s\n' "$1"
        fi
    }
    function _sys_colorize() {
        if [[ ! -t 1 && -z ${_SYS_COLOR_FORCE:-} ]]; then
            cat
            return
        fi

        sed -E \
            -e 's/^([[:space:]]*[[:alnum:]_ /()-]+:)/\x1b[1;36m\1\x1b[0m/' \
            -e '/not installed|unavailable|no PSI|without sudo/I s/^/\x1b[1;33m/; /not installed|unavailable|no PSI|without sudo/I s/$/\x1b[0m/' \
            -e '/failed|error/I s/^/\x1b[1;31m/; /failed|error/I s/$/\x1b[0m/'
    }
    function _sys_impl() {
        local all=0
        if [[ $# -gt 1 ]]; then
            echo "Usage: sys [-a]" >&2
            return 2
        fi
        if [[ $# -eq 1 ]]; then
            if [[ "$1" == "-a" ]]; then
                all=1
            else
                echo "sys: unknown argument '$1'" >&2
                echo "Usage: sys [-a]" >&2
                return 2
            fi
        fi

        local os_name
        if [[ -r /etc/os-release ]]; then
            os_name=$(awk -F= '/^PRETTY_NAME=/ {gsub(/^"|"$/, "", $2); print $2; exit}' /etc/os-release)
            [[ -z "$os_name" ]] && os_name=$(awk -F= '/^NAME=/ {gsub(/^"|"$/, "", $2); print $2; exit}' /etc/os-release)
        fi
        [[ -z "$os_name" ]] && os_name=$(uname -o)

        _sys_section "System"
        printf 'OS:      %s\n' "$os_name"
        printf 'Kernel:  %s\n' "$(uname -r)"
        command uptime

        _sys_section "CPU"
        if _e lscpu; then
            command lscpu | grep -iE '^(Architecture|Model name|Socket|Core|Thread|CPU\(s\):)' | sed 's/^/  /'
        else
            awk -F': ' '/model name/ {print "  " $2; exit}' /proc/cpuinfo
            awk '/^processor/ {n++} END {print "  CPUs: " n+0}' /proc/cpuinfo
        fi

        _sys_section "Memory"
        command free -h

        _sys_section "Swap"
        command free -h | awk '/^Swap:/ {print "  " $0}'
        if _e swapon; then
            command swapon --show=NAME,TYPE,SIZE,USED,PRIO 2>/dev/null | sed 's/^/  /'
        else
            echo "  swapon not installed"
        fi

        _sys_section "Pressure"
        if [[ -r /proc/pressure/cpu ]]; then
            for f in /proc/pressure/cpu /proc/pressure/memory /proc/pressure/io; do
                [[ -r "$f" ]] && awk -v p="$f" '{printf "  %s: %s\n", p, $0}' "$f"
            done
        else
            echo "  No PSI data in /proc/pressure"
        fi

        _sys_section "Temperatures"
        if _e sensors; then
            command sensors 2>/dev/null | sed 's/^/  /'
        else
            echo "  lm-sensors (sensors) not installed"
        fi

        _sys_section "Filesystems"
        command df -hT -x tmpfs -x devtmpfs 2>/dev/null

        _sys_section "Block devices"
        if _e lsblk; then
            command lsblk -o NAME,TYPE,SIZE,FSTYPE,FSUSE%,MOUNTPOINTS 2>/dev/null | sed 's/^/  /'
        else
            echo "  lsblk not installed"
        fi

        _sys_section "Failed system units"
        systemctl --failed --no-pager --plain 2>/dev/null || echo "  systemctl --failed unavailable"

        _sys_section "Failed user units"
        systemctl --user --failed --no-pager --plain 2>/dev/null || echo "  systemctl --user --failed unavailable"

        _sys_section "Network interfaces"
        if _e ip; then
            command ip -br addr 2>/dev/null | sed 's/^/  /'
        else
            echo "  ip not installed"
        fi

        _sys_section "Established connections"
        if _e ss; then
            command ss -tun state established 2>/dev/null | head -n 25 | sed 's/^/  /'
        else
            echo "  ss not installed"
        fi

        _sys_section "Top CPU consumers"
        command ps -eo pid,ppid,stat,pcpu,pmem,comm --sort=-pcpu 2>/dev/null | head -n 15 | sed 's/^/  /'

        _sys_section "Top memory consumers"
        command ps -eo pid,ppid,stat,pcpu,pmem,comm --sort=-pmem 2>/dev/null | head -n 15 | sed 's/^/  /'

        if (( all )); then
            _sys_section "Detailed CPU"
            if _e lscpu; then
                command lscpu | sed 's/^/  /'
            else
                echo "  lscpu not installed"
            fi

            _sys_section "PCI devices"
            if _e lspci; then
                command lspci | sed 's/^/  /'
            else
                echo "  lspci not installed"
            fi

            _sys_section "USB devices"
            if _e lsusb; then
                command lsusb | sed 's/^/  /'
            else
                echo "  lsusb not installed"
            fi

            _sys_section "Storage details"
            if _e lsblk; then
                command lsblk -f 2>/dev/null | sed 's/^/  /'
                echo
                command lsblk -o NAME,TYPE,SIZE,MODEL,STATE 2>/dev/null | sed 's/^/  /'
            else
                echo "  lsblk not installed"
            fi
            if _e smartctl; then
                echo "  SMART health summary:"
                command lsblk -dn -o NAME 2>/dev/null | while read -r d; do
                    command smartctl -H /dev/"$d" 2>/dev/null | grep -i 'SMART overall-health' | sed "s/^/    /;s/$/ ($d)/" || true
                done
            else
                echo "  smartctl not installed (install smartmontools for SMART data)"
            fi

            _sys_section "Mounts"
            if _e findmnt; then
                command findmnt 2>/dev/null | sed 's/^/  /'
            else
                command mount 2>/dev/null | sed 's/^/  /'
            fi

            _sys_section "Routes"
            if _e ip; then
                command ip route 2>/dev/null | sed 's/^/  /'
            else
                echo "  ip not installed"
            fi

            _sys_section "Listening sockets"
            if _e ss; then
                command ss -tulnp 2>/dev/null | sed 's/^/  /'
            else
                echo "  ss not installed"
            fi

            _sys_section "Graphics"
            if _e lspci; then
                command lspci | grep -iE 'vga|3d|display|graphics' | sed 's/^/  /'
            else
                echo "  lspci not installed"
            fi
            if _e glxinfo; then
                command glxinfo 2>/dev/null | grep -E 'OpenGL renderer|OpenGL vendor' | sed 's/^/  /'
            else
                echo "  glxinfo not installed (install mesa-utils for GPU renderer info)"
            fi

            _sys_section "Battery"
            if _e acpi; then
                command acpi -i 2>/dev/null | sed 's/^/  /'
            elif _e upower; then
                command upower -e 2>/dev/null | while read -r bat; do
                    [[ "$bat" == *battery* ]] && command upower -i "$bat" 2>/dev/null | sed 's/^/  /'
                done
            else
                echo "  acpi/upower not installed (install acpi or upower for battery info)"
            fi

            _sys_section "Desktop session"
            printf '  Desktop:  %s\n' "${XDG_CURRENT_DESKTOP:-unknown}"
            printf '  Session:  %s\n' "${XDG_SESSION_TYPE:-unknown}"
            printf '  Display:  %s\n' "${WAYLAND_DISPLAY:-${DISPLAY:-none}}"
            if _e loginctl; then
                command loginctl show-user "$USER" -p Display -p State 2>/dev/null | sed 's/^/  /'
            fi
        fi
    }
    function sys() {
        if [[ -t 1 ]] && _e less; then
            local _SYS_COLOR_FORCE=1
            export _SYS_COLOR_FORCE
            _sys_impl "$@" | _sys_colorize | command less -R
        else
            _sys_impl "$@"
        fi
    }
    complete -F _complete_journalctl st
    complete -F _complete_log_services log
fi
