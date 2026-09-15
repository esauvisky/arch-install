#!/usr/bin/env bash
# shellcheck disable=SC2139,SC1001,SC2155,SC1090,SC1091,SC2034
# Part of emishrc -- MANAGED FILE, overwritten on update. Edit ~/.bashrc instead.

##  +-+-+-+-+-+ +-+-+-+-+-+-+-+ +-+-+-+-+-+-+
##  |S|w|i|f|t| |H|i|s|t|o|r|y| |S|e|a|r|c|h|
##  +-+-+-+-+-+ +-+-+-+-+-+-+-+ +-+-+-+-+-+-+
## Fancy way of quickly grepping the command history.
## An alternative to Ctrl+R that supports regex.
##
## Usage:
##   hh                       Show help
##   hh -h / hh --help        Show help
##   hh 'clone.*gitlab'       Search history (regex supported)
##   hh 42                    Show context around history line 42
##   hh 500 30                Show 30 lines of context around line 500
##   hh 'clone.*gitlab' 30    Search with 30 lines of context per match
##
## Replay entry #4513:  !!4513
##  +-+-+-+-+-+ +-+-+-+-+-+-+-+ +-+-+-+-+-+-+
##  |S|w|i|f|t| |H|i|s|t|o|r|y| |S|e|a|r|c|h|
##  +-+-+-+-+-+ +-+-+-+-+-+-+-+ +-+-+-+-+-+-+
function hh() {
    if [[ $# -eq 0 || "$1" == "-h" || "$1" == "--help" ]]; then
        echo -e "\e[01;95mSwift History Search\e[00m"
        echo "Fancy way of quickly grepping the command history."
        echo "An alternative to Ctrl+R that supports regex."
        echo ""
        echo -e "\e[01;96mUsage:\e[00m"
        echo "  hh <query> [context]   : Search history for regex <query> with [context] lines around it (default 0)."
        echo "  hh <number> [context]  : Show [context] lines around history entry <number> (default 30)."
        echo "  h  <query> [gap_mins]  : Search history for regex <query> and group into time-based work sessions."
        echo ""
        echo -e "\e[01;96mExamples:\e[00m"
        echo "  hh 'clone.*gitlab' 5   : Find gitlab clone commands with 5 lines of context around matches."
        echo "  hh 'something\b'       : Search using regex word boundaries."
        echo "  hh 500 10              : Show 10 lines of context around history line 500."
        echo "  h 'pkgctl' 15          : Find 'pkgctl' and show the surrounding work session (splits if inactive for 15+ mins)."
        return 0
    fi

    local GET_NEARBY=0
    local target_num=""
    local context=0
    local query=""

    # Argument parsing
    if [[ "$1" =~ ^[0-9]+$ ]]; then
        GET_NEARBY=1
        target_num="$1"
        context="${2:-30}"
    else
        query="$1"
        context="${2:-0}"
    fi

    local MAX_RESULTS=1000  # Limit total results to prevent hanging
    local result_count=0
    local max_number_length=$(history | tail -n 1 | awk '{print length($1)}')
    local term_cols=$(tput cols 2>/dev/null || echo 80)

    printf "\e[01;95m=== Search Results ===\e[00m\n"

    if [[ $GET_NEARBY == 1 ]]; then
        mapfile -t matching_entries < <(
            LANG=C history | \
            awk -v target="$target_num" -v ctx="$context" '
                match($0, /^[ ]*[0-9]+/) {
                    num = substr($0, RSTART, RLENGTH)
                    num = num + 0
                    entry = substr($0, RSTART + RLENGTH)
                    if (num >= target - ctx && num <= target + ctx) {
                        print num entry
                    }
                }' 2>/dev/null
        )

        for entry in "${matching_entries[@]}"; do
            if [[ -n "$entry" ]]; then
                entry="${entry#"${entry%%[![:space:]]*}"}"
                local number="${entry%% *}"
                local cmd="${entry#* }"
                cmd="${cmd#"${cmd%%[![:space:]]*}"}"

                # Truncate command to fit terminal width
                local max_cmd_len=$(( term_cols - max_number_length - 2 ))
                if [[ ${#cmd} -gt $max_cmd_len ]]; then
                    cmd="${cmd:0:$max_cmd_len-3}..."
                fi

                if [[ "$number" == "$target_num" ]]; then
                    printf "\e[2m%-*s \e[00m\e[1;33m%s\e[00m\n" "$max_number_length" "$number" "$cmd"
                else
                    printf "\e[2m%-*s \e[00m%s\n" "$max_number_length" "$number" "$cmd"
                fi
            fi
        done
    else
        local grep_args=(-E -i -- "$query")
        if [[ $context -gt 0 ]]; then
            grep_args=(-E -i -C "$context" -- "$query")
        fi

        while IFS=$'\n' read -r entry; do
            if [[ "$entry" == "--" ]]; then
                printf "\e[01;90m%s\e[00m\n" "----------------------------------------"
                continue
            fi

            entry="${entry#"${entry%%[![:space:]]*}"}"
            local number="${entry%% *}"
            local cmd="${entry#* }"
            cmd="${cmd#"${cmd%%[![:space:]]*}"}"

            # Truncate command to fit terminal width before colorizing to avoid breaking ANSI
            local max_cmd_len=$(( term_cols - max_number_length - 2 ))
            if [[ ${#cmd} -gt $max_cmd_len ]]; then
                cmd="${cmd:0:$max_cmd_len-3}..."
            fi

            local highlighted_cmd="$cmd"

            if echo "$cmd" | grep -E -i -q -- "$query"; then
                ((result_count++))
                if [[ $result_count -gt $MAX_RESULTS ]]; then
                    printf "\e[01;93m=== Results limited to %d matches ===\e[00m\n" "$MAX_RESULTS"
                    break
                fi
                highlighted_cmd=$(echo "$cmd" | GREP_COLORS='mt=1;33' grep -E -i --color=always -- "$query")
            fi

            printf "\e[2m%-*s \e[00m%s\n" "$max_number_length" "$number" "$highlighted_cmd"
        done < <(history | grep "${grep_args[@]}")
    fi
    printf "\e[01;95m======================\e[00m\n"
}

function h() {
    if [[ $# -eq 0 || "$1" == "-h" || "$1" == "--help" ]]; then
        echo -e "\e[01;95mSession History Search\e[00m"
        echo "Search history for regex matches and expand them into time-based work sessions."
        echo ""
        echo -e "\e[01;96mUsage:\e[00m"
        echo "  h  <query> [gap_mins]  : Show the surrounding work session for regex matches."
        echo ""
        echo -e "\e[01;96mExamples:\e[00m"
        echo "  h 'pkgctl'             : Show the nearby commands around pkgctl matches."
        echo "  h 'pkgctl' 15          : Split sessions if inactive for 15+ minutes."
        return 0
    fi

    local query="$1"
    local gap_mins="${2:-15}"

    printf "\e[01;95m=== Session Search Results ===\e[00m\n"

    HISTTIMEFORMAT="%s " history | python3 -c '
import sys, re, datetime, shutil

query = sys.argv[1]
gap_seconds = int(sys.argv[2]) * 60

try:
    regex = re.compile(query, re.IGNORECASE)
except re.error as e:
    print(f"Invalid regex: {e}")
    sys.exit(1)

history = []

for line in sys.stdin:
    line = line.strip()
    if not line: continue

    parts = line.split(maxsplit=2)
    if len(parts) < 3: continue

    try:
        num = int(parts[0])
        timestamp = int(parts[1])
        cmd = parts[2]
        history.append((num, timestamp, cmd))
    except ValueError:
        pass

if not history:
    sys.exit(0)

# Sort strictly by timestamp to fix any out-of-order history entries
history.sort(key=lambda x: (x[1], x[0]))

matches = []
for idx, (_, _, cmd) in enumerate(history):
    if regex.search(cmd):
        matches.append(idx)

if not matches:
    sys.exit(0)

sessions = []
for m_idx in matches:
    start_idx = m_idx
    end_idx = m_idx

    while start_idx > 0:
        if history[start_idx][1] - history[start_idx-1][1] <= gap_seconds:
            start_idx -= 1
        else:
            break

    while end_idx < len(history) - 1:
        if history[end_idx+1][1] - history[end_idx][1] <= gap_seconds:
            end_idx += 1
        else:
            break

    # Merge overlapping sessions
    if sessions and start_idx <= sessions[-1][1]:
        sessions[-1] = (sessions[-1][0], max(sessions[-1][1], end_idx))
    else:
        sessions.append((start_idx, end_idx))

max_num_len = len(str(history[-1][0])) if history else 5
term_cols = shutil.get_terminal_size().columns

for s_i, (start, end) in enumerate(sessions):
    start_ts = history[start][1]
    end_ts = history[end][1]

    start_dt = datetime.datetime.fromtimestamp(start_ts)
    end_dt = datetime.datetime.fromtimestamp(end_ts)

    date_str = start_dt.strftime("%Y-%m-%d")
    time_span = "{} -> {}".format(start_dt.strftime("%H:%M:%S"), end_dt.strftime("%H:%M:%S"))

    # Beautifully formatted separator
    sep_inner = f" {date_str} ---- {time_span} "
    sep_dashes_left = "-" * 6
    sep_dashes_right = "-" * max(6, term_cols - len(sep_inner) - len(sep_dashes_left))

    if s_i > 0:
        print(f"\033[01;90m{sep_dashes_left}{sep_inner}{sep_dashes_right}\033[00m")

    for i in range(start, end + 1):
        num, ts, cmd = history[i]

        time_str = datetime.datetime.fromtimestamp(ts).strftime("%H:%M:%S")

        # Truncate command if it exceeds terminal width
        max_cmd_len = term_cols - max_num_len - len(time_str) - 6
        if len(cmd) > max_cmd_len and max_cmd_len > 0:
            cmd = cmd[:max_cmd_len-3] + "..."

        def repl(match):
            return f"\033[1;33m{match.group(0)}\033[0m"

        highlighted_cmd = regex.sub(repl, cmd) if regex.search(cmd) else cmd

        print(f"\033[2m{num:<{max_num_len}}\033[00m [{time_str}] {highlighted_cmd}")

' "$query" "$gap_mins"

    printf "\e[01;95m==============================\e[00m\n"
}
