#!/usr/bin/env bash
# shellcheck disable=SC2139,SC1001,SC2155,SC1090,SC1091,SC2034
# Part of emishrc -- MANAGED FILE, overwritten on update. Edit ~/.bashrc instead.

###   ___        _                                  _      _   _
###  / _ \      | |                                | |    | | (_)
### / /_\ \_   _| |_ ___   ___ ___  _ __ ___  _ __ | | ___| |_ _  ___  _ __
### |  _  | | | | __/ _ \ / __/ _ \| '_ ` _ \| '_ \| |/ _ \ __| |/ _ \| '_ \
### | | | | |_| | || (_) | (_| (_) | | | | | | |_) | |  __/ |_| | (_) | | | |
### \_| |_/\__,_|\__\___/ \___\___/|_| |_| |_| .__/|_|\___|\__|_|\___/|_| |_|
###                                          | |
###                                          |_|
## TIP: to create autocompletion for custom funcs without
##      writing our own completion function:
# 1. Type the command, and press <Tab> to autocomplete
# 2. Run `complete -p command`
# 3. The output is the hook that was used to complete it.
# 4. Change it accordingly to apply it to your function.
## Loads bash's system-wide installed completions
if [[ -f /usr/share/bash-completion/bash_completion ]]; then
    source /usr/share/bash-completion/bash_completion
fi
## Loads gits completion file for our custom completions
if [ -f /usr/share/bash-completion/completions/git ]; then
    # The STDERR redirection is to not print an annoying bug on
    # GCP VMs that make sed error out for some stupid reason and bad coding
    source /usr/share/bash-completion/completions/git #2>/dev/null
fi
## Node autocompletions
if _e node; then

    unalias node 2>/dev/null || true # for windows users because git bash already aliases node to something else
    # alias node='node --experimental-modules --experimental-repl-await --experimental-vm-modules --experimental-worker --experimental-import-meta-resolve'
    source <(node --completion-bash)
fi
