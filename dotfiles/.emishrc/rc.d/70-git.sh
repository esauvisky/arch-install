#!/usr/bin/env bash
# shellcheck disable=SC2139,SC1001,SC2155,SC1090,SC1091,SC2034
# Part of emishrc -- MANAGED FILE, overwritten on update. Edit ~/.bashrc instead.

#   \___|___| |_|
if _e git; then
    export GIT_MERGE_AUTOEDIT=no
    export GIT_COMPLETION_SHOW_ALL_COMMANDS=1

    # gitl remains an alias as it's a specific log view
    alias gitl="git log --graph --all --pretty=format:'%C(auto,yellow)%h%C(magenta)%C(auto,bold)% G? %C(reset)%>(12,trunc) %ad %C(auto,blue)%<(10,trunc)%aN%C(auto)%d %C(auto,reset)%s' --date=relative"

    function gitd() {
        if [[ $# -eq 0 ]]; then
            git diff
            return
        fi

        local commit="$1" next
        [[ $commit == "~" || $commit == "$HOME" ]] && commit="HEAD~"

        if [[ $# -eq 1 ]]; then
            next=$(git rev-list --ancestry-path --reverse "${commit}..HEAD" | head -n 1)
            [[ -n $next ]] || { echo "gitd: no next commit from $commit to HEAD" >&2; return 1; }
            git diff "$commit" "$next"
            return
        fi

        git diff "$@"
    }

    function gitm() {
        git commit --amend -m "$*"
    }

    function gits() {
        local current_block="" line status path emoji
        # Define specific colors for echo output
        local c_orange_light='\033[38;5;214m'
        local c_orange_bold='\033[1;38;5;208m'
        local c_reset='\033[0m'

        local -A emoji_map=(
            [modified]="🟠"
            [deleted]="🔴"
            [added]="🟢"
            ["new file"]="🟢"
            [renamed]="🔵"
        )

        while IFS= read -r line; do
            # --- 1. Filter Noise ---

            # A. Rebase/Merge History & Hints
            [[ $line =~ ^[[:space:]]*(pick|drop|edit|squash|fixup|exec|label|reset|merge)[[:space:]] ]] && continue
            [[ $line =~ ^(Last|Next)[[:space:]]commands ]] && continue
            [[ $line =~ ^interactive[[:space:]]rebase[[:space:]]in[[:space:]]progress ]] && continue

            # B. Parenthetical Hints (The heavy lifter)
            # Removes (use "git add"...) (fix conflicts...) (use "git push"...)
            [[ $line =~ ^[[:space:]]*\(.*\)$ ]] && continue

            # C. Specific Messages to Hide
            [[ $line =~ ^nothing\ to\ commit,\ working\ tree\ clean ]] && continue
            [[ $line =~ ^no\ changes\ added\ to\ commit ]] && continue
            [[ $line =~ ^You\ have\ unmerged\ paths\. ]] && continue

            # [NEW] Hide "Up to date" (Prompt already shows this via lack of arrows)
            [[ $line =~ ^Your\ branch\ is\ up\ to\ date\ with ]] && continue

            # [NEW] Hide Ignored files header
            [[ $line =~ ^Ignored\ files: ]] && continue

            # [NEW] Hide simple "On branch" if strictly boring (Prompt shows branch)
            # We keep it if it's "HEAD detached" or complex states, but "On branch main" is noise
            # unless we want to confirm the name explicitly.
            # Commented out by default, uncomment if you trust your prompt 100%
            # [[ $line =~ ^On\ branch\  ]] && continue


            # --- 2. Headers & Coloring ---

            if [[ $line =~ ^(On branch|HEAD detached at) ]]; then
                echo -e "\e[01;94m$line.\e[00m"
                continue
            elif [[ $line =~ ^Your\ branch\ is ]]; then
                echo -e "\e[94m$line\e[00m"
                continue
            elif [[ $line =~ ^You\ are\ currently\ rebasing ]]; then
                echo -e "\e[01;96m$line\e[00m"
                continue
            fi

            # --- DIVERGENCE MESSAGE REPLACEMENT ---
            if [[ $line =~ ^Your\ branch\ and\ .*have\ diverged ]]; then
                echo -e "${c_orange_light}${line}${c_reset}"
                continue
            elif [[ $line =~ ^and\ have\ .*different\ commits ]]; then
                echo -e "${c_orange_light}${line}${c_reset}"
                echo ""
                echo -e "${c_orange_bold}You will need rewrite the history if you want to push to"
                echo -e "the remote repository using \"git push --force\".${c_reset}"
                continue
            fi

            # Add spacing before sections
            if [[ $line =~ ^(Changes|Untracked|Unmerged) ]]; then
                echo ""
            fi

            case "$line" in
                *"Changes to be committed:"*)
                    current_block="staged"
                    echo -e "\e[01;32m$line\e[00m"
                    continue
                    ;;
                *"Changes not staged for commit:"*)
                    current_block="changes"
                    echo -e "\e[01;33m$line\e[00m"
                    continue
                    ;;
                *"Untracked files:"*)
                    current_block="untracked"
                    echo -e "\e[01;96m$line\e[00m"
                    continue
                    ;;
                *"Unmerged paths:"*)
                    current_block="unmerged"
                    echo -e "\e[01;31m$line\e[00m"
                    continue
                    ;;
            esac

            # --- 3. File List Processing ---
            if [[ $line =~ ^[[:space:]]+([^:]+):[[:space:]]+(.+)$ ]]; then
                status="${BASH_REMATCH[1]}"
                path="${BASH_REMATCH[2]}"

                case "$current_block" in
                    staged)
                        for key in "${!emoji_map[@]}"; do
                            if [[ $status == *"$key"* ]]; then
                                emoji="${emoji_map[$key]}"
                                break
                            fi
                        done
                        echo -e "\e[01;32m     ${emoji:-⚪️}$line\e[00m"
                        ;;
                    changes)
                        if [[ $status == *modified* ]]; then
                            echo -e "\e[33m\tmodified:\t$path\e[00m"
                        elif [[ $status == *deleted* ]]; then
                            echo -e "\e[91m\tdeleted: \t$path\e[00m"
                        elif [[ $status == *added* || $status == *"new file"* ]]; then
                            echo -e "\e[92m\tnew file:\t$path\e[00m"
                        elif [[ $status == *renamed* ]]; then
                            echo -e "\e[95m\trenamed: \t$path\e[00m"
                        elif [[ $status == *typechange* ]]; then
                            echo -e "\e[93m\ttypechange:\t$path\e[00m"
                        else
                            echo -e "$line"
                        fi
                        ;;
                    unmerged)
                        echo -e "\e[31m\t$status:\t$path\e[00m"
                        ;;
                esac
            elif [[ $line =~ ^[[:space:]]+(.+)$ && $current_block == "untracked" ]]; then
                echo -e "\e[96m\tuntracked:  \t${BASH_REMATCH[1]}\e[00m"
            elif [[ -n $line ]]; then
                 if [[ $line =~ ^Your\ stash\ currently ]]; then
                    echo ""
                    echo -e "\e[37m$line\e[00m"
                 else
                    echo -e "$line"
                 fi
            fi
        done < <(git status --show-stash --long 2>/dev/null)
    }

    function gitcleanbranches() {
        local master="${1:-master}"
        local merge_base commit_hash
        git fetch --prune || return 1
        git checkout "$master" 2>/dev/null || { echo "Pass the master branch name as argv[1]!"; return 1; }
        while IFS= read -r branch; do
            [[ "$branch" == "$master" ]] && continue
            merge_base=$(git merge-base "$master" "$branch" 2>/dev/null) || continue
            commit_hash=$(git rev-parse --verify "$branch" 2>/dev/null) || continue
            [[ "$merge_base" == "$commit_hash" ]] && git branch --delete "$branch"
        done < <(git for-each-ref refs/heads --format='%(refname:short)')
    }

    function _git_sync() {
        local -r bold=$'\033[1m' fgre=$'\033[32m' fblu=$'\033[34m'
        local -r fred=$'\033[31m' fyel=$'\033[33m' fvio=$'\033[35m' end=$'\033[0m'
        local current_branch remote branch
        current_branch=$(git rev-parse --abbrev-ref HEAD)

        while IFS= read -r remote; do
            [[ -z "$remote" ]] && continue
            git remote update "$remote" --prune 2>&1 | \
                sed "s/ - \[deleted\]..*-> *$remote\/\(.*\)/   ${fyel}Branch ${bold}\1${end}${fyel} was deleted from $remote and will be pruned locally.${end}/"

            while IFS= read -r branch; do
                if ! git rev-parse --abbrev-ref "$branch@{upstream}" &>/dev/null; then
                    if git branch --set-upstream-to="$remote/$branch" "$branch" &>/dev/null; then
                        echo -e "   ${fvio}Branch ${bold}$branch${end}${fvio} was not tracking any remote branch! It was set to track ${bold}$remote/$branch.${end}"
                    fi
                fi
            done < <(git for-each-ref --format='%(refname:short)' refs/heads/*)

            while IFS=' ' read -r rb lb; do
                [[ -z "$rb" || -z "$lb" ]] && continue
                local arb="refs/remotes/$remote/$rb"
                local alb="refs/heads/$lb"
                local nbehind nahead
                nbehind=$(git rev-list --count "$alb..$arb" 2>/dev/null || echo 0)
                [[ $nbehind -eq 0 ]] && continue
                nahead=$(git rev-list --count "$arb..$alb" 2>/dev/null || echo 0)

                if [[ $nahead -gt 0 ]]; then
                    echo -e "   ${fred}Branch ${bold}$lb${end}${fred} is ${bold}$nbehind${end}${fred} commit(s) behind and ${bold}$nahead${end}${fred} commit(s) ahead of ${bold}$remote/$rb${end}${fred}. Could not be fast-forwarded.${end}"
                elif [[ "$lb" == "$current_branch" ]]; then
                    if git merge -q "$arb" 2>/dev/null; then
                        echo -e "   ${fblu}Branch ${bold}$lb${end}${fblu} was ${bold}$nbehind${end}${fblu} commit(s) behind of ${bold}$remote/$rb${end}${fblu}. Fast-forward merge.${end}"
                    else
                        echo -e "   ${fred}${bold}Warning! Branch $lb${end}${fred} (currently checked out) will conflict with new commits incoming from ${bold}$remote/$rb${end}${fred}!${end}"
                        echo -e "   ${fred}You'll need to stash your changes before. Try \`${bold}git stash${end}${fred}\`, \`${bold}git merge${end}${fred}\`, then \`${bold}git stash pop${end}${fred}\`, and good luck!${end}"
                    fi
                else
                    echo -e "   ${fgre}Branch ${bold}$lb${end}${fgre} was ${bold}$nbehind${end}${fgre} commit(s) behind of ${bold}$remote/$rb${end}${fgre}. Resetting local branch to remote.${end}"
                    git branch -f "$lb" -t "$arb" &>/dev/null
                fi
            done < <(git remote show "$remote" -n | awk '/merges with remote/{print $5" "$1}')
        done < <(git remote)
    }

    function _git_ai_stash_message() {
        local diff_content
        diff_content=$(git diff HEAD --no-color 2>/dev/null | head -c 12000)
        [[ -z "$diff_content" ]] && return 1
        echo -ne "\e[35m🤖 Analyzing changes with Gemini...\e[0m\n" >&2
        local sys_prompt="You are a git assistant. Write a git stash message (max 10 words, imperative mood) based on the diff provided. Output ONLY the message text. No quotes, no markdown."
        _gemini_query "$sys_prompt" "$diff_content"
    }

    function git() {
        case "$1" in
            stash)
                if [[ $# -eq 1 || ($# -eq 2 && "$2" == "push") ]]; then
                    local ai_message
                    if ai_message=$(_git_ai_stash_message); then
                        command git stash push -m "🤖 $ai_message"
                    else
                        command git "$@"
                    fi
                    return
                fi
                ;;
            pull)
                [[ $# -eq 1 ]] && { _git_sync; return; }
                ;;
            commit)
                [[ $# -eq 2 && "$2" == "--amend" ]] && { command git commit --amend --no-edit; return; }
                ;;
            # [NEW] Intercept 'status' to use custom gits function
            status)
                if [[ $# -eq 1 ]]; then
                    gits
                    return
                fi
                ;;
            # [NEW] Intercept 'diff' to use custom flags (replacing gitd alias)
            diff)
                shift
                command git diff --color --patch-with-stat --ignore-blank-lines \
                    --minimal --abbrev --ignore-all-space \
                    --color-moved=dimmed-zebra --color-moved-ws=ignore-all-space "$@"
                return
                ;;
        esac
        command git "$@"
    }

    _git_commit() {
        case "$prev" in
            -c|-C) __git_complete_refs; return ;;
            -m) __gitcomp "\"feat: \"fix: \"style: \"refactor: \"build: \"perf: \"ci: \"docs: \"test: \"chore: \"revert: "; return ;;
        esac
        case "$cur" in
            --cleanup=*) __gitcomp "default scissors strip verbatim whitespace" "" "${cur##--cleanup=}"; return ;;
            --message=*) __gitcomp "\"feat: \"fix: \"style: \"refactor: \"build: \"perf: \"ci: \"docs: \"test: \"chore: \"revert:" "" "${cur##--message=}"; return ;;
            --reuse-message=*|--reedit-message=*|--fixup=*|--squash=*) __git_complete_refs --cur="${cur#*=}"; return ;;
            --untracked-files=*) __gitcomp "$__git_untracked_file_modes" "" "${cur##--untracked-files=}"; return ;;
            --*) __gitcomp_builtin commit; return ;;
        esac
        if __git rev-parse --verify --quiet HEAD >/dev/null; then
            __git_complete_index_file "--committable"
        else
            __git_complete_index_file "--cached"
        fi
    }

    # =========================================================================
    #  CUSTOM GIT PROMPT
    # =========================================================================
    # Count stashes by reading the ref log directly; `git stash list` forks a
    # process and walks the ref just to give us a number. Sets _GIT_STASH_COUNT.
    function _git_stash_count() {
        local git_dir="$1" common="$1" log line
        _GIT_STASH_COUNT=0
        # linked worktrees keep refs (and the stash) in the common dir
        [[ -f "$git_dir/commondir" ]] && common="$git_dir/$(<"$git_dir/commondir")"
        log="$common/logs/refs/stash"
        [[ -f "$log" ]] || return
        while IFS= read -r line; do ((_GIT_STASH_COUNT++)); done < "$log"
    }

    function _git_prompt() {
        # Quick check: git must be available and we must be in a git repo
        local git_dir
        git_dir=$(git rev-parse --git-dir 2>/dev/null) || return
        [[ -n "$git_dir" ]] || return

        # Check cache using git HEAD file as trigger
        local head_file="$git_dir/HEAD"
        local cache_key="${PWD}:_git_prompt"

        # Use HEAD file content as cache trigger (changes on branch switch)
        # Also include index modification time to detect staging/unstaging
        # And stash count for stash changes
        local head_trigger=""
        [[ -f "$head_file" ]] && head_trigger=$(cat "$head_file" 2>/dev/null)
        [[ -f "$git_dir/index" ]] && head_trigger+=":$(stat -c %Y "$git_dir/index" 2>/dev/null)"
        _git_stash_count "$git_dir"
        head_trigger+=":stash:${_GIT_STASH_COUNT}"

        # Try to get cached result
        if cached=$(_cache_get "$cache_key" "$_PROMPT_CACHE_TTL_GIT" "$head_trigger" 2>/dev/null); then
            echo -ne "$cached"
            return
        fi

        # Not cached, compute fresh result
        local bname=""
        local detached="no"
        local op_text=""
        local op_state="normal"
        local dirty=""
        local staged=""
        local conflict=""
        local upstream_status=""

        # 1. Detect Operation State (from git dir structure)
        if [ -d "$git_dir/rebase-merge" ]; then
            bname=$(cat "$git_dir/rebase-merge/head-name" 2>/dev/null)
            bname=${bname##refs/heads/}
            op_text="REBASE"
            op_state="rebase"
        elif [ -d "$git_dir/rebase-apply" ]; then
             if [ -f "$git_dir/rebase-apply/rebasing" ]; then
                bname=$(cat "$git_dir/rebase-apply/head-name" 2>/dev/null)
                bname=${bname##refs/heads/}
                op_text="REBASE"
                op_state="rebase"
             elif [ -f "$git_dir/rebase-apply/applying" ]; then
                op_text="AM"
                op_state="rebase"
             else
                op_text="AM/REBASE"
                op_state="rebase"
             fi
        elif [ -f "$git_dir/MERGE_HEAD" ]; then
            op_text="MERGING"
            op_state="merge"
        elif [ -f "$git_dir/CHERRY_PICK_HEAD" ]; then
            op_text="CHERRY-PICKING"
            op_state="merge"
        elif [ -f "$git_dir/REVERT_HEAD" ]; then
            op_text="REVERTING"
            op_state="merge"
        elif [ -f "$git_dir/BISECT_LOG" ]; then
            op_text="BISECTING"
            op_state="bisect"
        fi

        # 2. Get Status without walking the whole worktree
        # `git status` stats (and rehashes) every tracked file and scans for
        # untracked ones before printing anything -- hundreds of ms in big or
        # very dirty trees. We only need three booleans, and `git diff --quiet`
        # bails out at the first difference it finds, so ask one at a time.
        local _gitq=(timeout "${_PROMPT_GIT_TIMEOUT:-0.35}" git --no-optional-locks)
        local slow=""

        # Branch name
        if [ -z "$bname" ]; then
            if bname=$(git symbolic-ref --quiet --short HEAD 2>/dev/null); then
                detached="no"
            else
                # Detached HEAD
                detached="yes"
                bname=$(git describe --tags --exact-match HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
                bname="($bname)"
            fi
        fi

        if [[ "${_PROMPT_GIT_NO_DIRTY:-0}" != 1 ]]; then
            # Unstaged changes (untracked files never affected the prompt, so
            # skip the untracked scan entirely)
            "${_gitq[@]}" diff --no-ext-diff --quiet --ignore-submodules=dirty 2>/dev/null
            case $? in
                0)   ;;
                1)   dirty="*" ;;
                124) slow="yes" ;;
            esac

            # Staged changes
            "${_gitq[@]}" diff --no-ext-diff --cached --quiet --ignore-submodules=dirty 2>/dev/null
            case $? in
                0)   ;;
                1)   staged="+" ;;
                124) slow="yes" ;;
            esac

            # Conflicts: index-only, so cheap no matter how big the worktree is
            if [[ -n "$(git --no-optional-locks ls-files --unmerged 2>/dev/null)" ]]; then
                conflict="|CONFLICT"
            fi

            # Timed out: say so rather than claim the tree is clean
            [[ -n "$slow" ]] && dirty=""
        fi

        # 3. Upstream divergence (left = upstream-only = behind, right = ahead)
        local ab_counts
        if ab_counts=$(git --no-optional-locks rev-list --count --left-right '@{upstream}...HEAD' 2>/dev/null); then
            local behind="${ab_counts%%[[:space:]]*}"
            local ahead="${ab_counts##*[[:space:]]}"

            # If both present, we're diverged
            if [[ $ahead -gt 0 && $behind -gt 0 ]]; then
                upstream_status="$__Bold$__OrangeLight↑${ahead}↓${behind}$__Reset"
                # Will override color below
            elif [[ $ahead -gt 0 ]]; then
                upstream_status="$__BlueLightBold↑${ahead}$__Reset"
            elif [[ $behind -gt 0 ]]; then
                upstream_status="$__YellowLightBold↓${behind}$__Reset"
            fi
        fi

        # Check for stashed changes (already counted for the cache trigger)
        local stash_count=$_GIT_STASH_COUNT
        local stash_status=""
        if [[ $stash_count -gt 0 ]]; then
            stash_status="${__CyanBold}⊕${stash_count}${__Reset}"
        fi

        # Status unknown: git took longer than _PROMPT_GIT_TIMEOUT
        local slow_status=""
        [[ -n "$slow" ]] && slow_status="${__Bold}${__Gray}?${__Reset}"

        # 4. Determine Colors
        local frame_color=""
        local branch_color_str=""
        local conflict_color="$__RedBold"
        local op_color="$__RedBold"

        # Set Frame Color based on operation state
        case "$op_state" in
            rebase) frame_color="$__VioletBold" ;;
            merge)  frame_color="$__VioletBold" ;;
            bisect) frame_color="$__CyanLightBold" ;;
            *)      frame_color="$__Bold$__Gray" ;;
        esac

        # Set Branch Name Color (based on file state)
        if [[ -n "$dirty" && -n "$staged" ]]; then
            # Split-color for mixed state
            local len=${#bname}
            local half=$((len / 2))
            branch_color_str="$__GreenBold${bname:0:half}$__YellowBold${bname:half}"
        elif [[ -n "$staged" ]]; then
            branch_color_str="$__GreenBold$bname"
        elif [[ -n "$dirty" ]]; then
            branch_color_str="$__YellowLightBold$bname"
        elif [[ "$detached" == "yes" ]]; then
            branch_color_str="$__VioletLightBold$bname"
        elif [[ -n "$upstream_status" && "$upstream_status" == *"<>"* ]]; then
            # Diverged from upstream
            branch_color_str="$__OrangeBold$bname"
        else
            branch_color_str="$__Bold$__Gray$bname"
        fi

        # 5. Build the output string
        local pipe_str=""
        if [[ -n "$op_text" ]]; then
            pipe_str="${frame_color}|"
            op_text="${op_color}${op_text}"
        fi

        local result=" ${frame_color}[${branch_color_str}${pipe_str}${op_text}${conflict_color}${conflict}${upstream_status}${stash_status}${slow_status}${frame_color}]$__Reset"

        # Cache the result
        _cache_set "$cache_key" "$result" "$head_trigger"

        echo -ne "$result"
    }
fi
