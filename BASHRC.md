# Hidden `.bashrc` / `.inputrc` Features

Only non-obvious behavior from [`dotfiles/.bashrc`](/home/emi/Coding/arch-install/dotfiles/.bashrc) and [`dotfiles/.inputrc`](/home/emi/Coding/arch-install/dotfiles/.inputrc).

This intentionally ignores obvious aliases and cosmetic wrappers that are self-explanatory once seen in use.

## History Behavior

- History is not stored in the default `~/.bash_history`.
  - Real file: `~/.bash_eternal_history`
- Very large history retention:
  - `HISTSIZE=5000000`
  - `HISTFILESIZE=10000000`
- History is appended after every command, not only when the shell exits.
- Multiline commands stay multiline in history.
- Duplicate handling is aggressive:
  - `HISTCONTROL=ignoredups:erasedups`
- Some noise is never stored:
  - `clear`
  - `exit`
  - `history`
  - `ls`
  - `gitl`
  - `gits`

## History Search Commands

### `hh`

Regex history search with optional context.

```bash
hh 'clone.*gitlab'
hh 'clone.*gitlab' 5
hh 500
hh 500 10
```

Behavior:

- `hh <regex> [context]`: search by regex
- `hh <number> [context]`: inspect nearby history lines around an entry number
- highlights matches
- truncates output to terminal width

### `h`

Session-oriented history search.

```bash
h 'pkgctl'
h 'pkgctl' 15
```

Behavior:

- `h <regex> [gap_mins]`
- finds matching commands, then expands them into time-grouped work sessions
- useful when you want the whole command sequence around a match, not just the line itself

### `cleanup_bash_history`

Compacts `~/.bash_eternal_history`.

Behavior:

- removes the top 5% longest command blocks
- deduplicates commands while keeping the latest occurrence
- writes a backup to `~/.bash_eternal_history.bak`

## AI Shell Assistant

### `ask`

Natural-language to shell-command helper.

```bash
ask find all pdfs larger than 10MB and move them to /tmp
ask print the ten biggest directories here
```

Behavior:

- requires `GEMINI_API_KEY`
- generates a command but does not execute it
- stores both the `ask ...` prompt and the generated command in shell history
- can be disabled with `BASHRC_DISABLE_AI=1`

### `Ctrl+O`

`Ctrl+O` is bound to the same AI command generator.

Behavior:

- if the current line starts with `ask ...`, it converts that prompt into a command
- if the current line is arbitrary text, it still tries to convert it into a shell command
- it replaces the current readline buffer in place

## Prompt Semantics

The prompt is not just cosmetic. It carries state and changes terminal behavior.

- Previous command status is always shown:
  - `✔ 000` for success
  - `✘ <code>` for failure
- Terminal title changes to the currently running command while it executes.
- The prompt includes contextual environment tags:
  - `[ADB]` when running inside Android shell contexts detected via `getprop`
  - `[SSH]` when the shell ancestry indicates SSH

### Git Prompt Indicators

The git prompt exposes state that would otherwise require separate commands.

- branch name
- staged vs unstaged state
- mixed staged+dirty state
- rebase / merge / cherry-pick / revert / bisect state
- conflict state: `|CONFLICT`
- upstream divergence:
  - `↑N`
  - `↓N`
  - `↑N↓M`
- stash count:
  - `⊕N`

## Git Behavior Changes

The shell wraps `git` itself and changes behavior for some subcommands.

### `git status`

- plain `git status` becomes `gits`
- `gits` is a filtered and recolored status view, not raw git output

### `git diff`

- plain `git diff` is forced through custom flags:
  - `--patch-with-stat`
  - `--ignore-blank-lines`
  - `--ignore-all-space`
  - `--minimal`
  - `--color-moved=dimmed-zebra`
  - `--color-moved-ws=ignore-all-space`

### `git commit --amend`

- `git commit --amend` becomes `git commit --amend --no-edit`

### `git pull`

- bare `git pull` does not run normal git pull behavior
- it runs `_git_sync`

`_git_sync` does more than a regular pull:

- updates remotes with prune
- tries to set missing upstream tracking automatically
- fast-forwards the current branch when possible
- resets non-current branches to the remote when they are cleanly behind
- warns when branches have diverged

### `git stash`

- bare `git stash` and `git stash push` may auto-generate a stash message with Gemini from the current diff

## File / Command Safety Changes

### `rm`

If `gio` is available, interactive `rm` is not normal `rm`.

Behavior:

- prefers `gio trash`
- strips recursive flags because trashing is already recursive
- falls back to real `rm` only for unsupported option patterns

### `cat`

Interactive single-file `cat` may become `bat -P` when the file extension is supported by `bat`.

### `grep`

Interactive `grep` is wrapped.

Behavior:

- adds line numbers and context
- prefers colored output when appropriate
- tries to avoid breaking pipes, command substitution, and completion

## ADB Behavior Changes

`adb` is wrapped for multi-device workflows.

Behavior:

- `adb devices` gets custom formatted output when the supporting color tool exists
- for commands like `push`, `pull`, `shell`, `install`, `logcat`, `reboot`, and similar:
  - if multiple devices are connected and no explicit target flag is passed, a device selector is shown

## systemd / journalctl Behavior

### `log <service-name>`

`log` completion is limited to currently running system and user service
units. It intentionally does not scan the journal while completing, so Tab
stays fast and does not surface transient D-Bus or coredump units.

Bare service names are matched against all related service-unit names, so
`log pulseaudio` includes every currently running system or user service containing
`pulseaudio` in its name. Unmatched words retain the message-text fallback.

### `sys`

Interactive `sys` output is opened in `less -R` so the overview can be paged;
redirected and piped output remains non-interactive.

### `st <unit>`

`st` does not just call journalctl blindly.

Behavior:

- if the unit exists only in user scope, it uses `_SYSTEMD_USER_UNIT`
- otherwise it uses `_SYSTEMD_UNIT`

### `sstart`, `sstop`, `srestart`, `sstatus`, `senable`, `sdisable`

These wrappers auto-select user vs system scope.

Behavior:

- if the unit exists as a user unit only, they run `systemctl --user ...`
- otherwise they run regular `systemctl ...`

## Python Behavior Changes

### Virtualenv prompt

- the normal virtualenv prompt injection is disabled
- python / venv info is rendered by the custom prompt instead

### `pip install`

If `pipman` exists and no virtualenv is active:

- `pip install ...` is redirected to `pipman -S ...`
- `--break-system-packages` is removed before dispatch

### `venv`

`venv` is a custom helper, not just shorthand for `python -m venv`.

Behavior:

- prefers `pyenv`
- offers an interactive Python version picker when no version is passed
- installs missing Python versions through pyenv if needed
- recreates `.venv` if it already exists
- activates the environment after creation

## Other Non-Obvious Shell Behavior

- `IGNOREEOF=1`
  - exiting an interactive shell requires pressing `Ctrl+D` twice
- `GPG_TTY=$(tty)` is always exported
  - this matters for git signing in the current terminal

## `.inputrc` Keybindings and Completion Behavior

### Tab completion model

Tab completion is not using the default readline flow.

- `Tab` runs `menu-complete`
  - repeated `Tab` cycles through candidates
- `Shift+Tab` cycles backward
- first `Tab` can show the candidate list before cycling further
- completion paging is disabled
- ambiguous completion lists can be shown immediately

### Completion matching rules

- completion is case-insensitive
- hidden files are ignored unless the pattern starts with `.`
- long common prefixes in completion lists are collapsed after length 10
- completion lists show file-type markers
- completion looks at text after the cursor too (`skip-completed-text`)

### History navigation

Up/down arrows do prefix history search, not plain chronological traversal.

Behavior:

- type a prefix
- press `Up` / `Down`
- readline searches history entries that start with that prefix

### Word-deletion behavior

Several deletion keys are rebound to shell-aware word operations.

- `Ctrl+W`: delete backward by shell word
- `Ctrl+D`: delete forward by shell word
- `Ctrl+Backspace`: backward kill word
- `Ctrl+Delete`: forward kill word
- `Alt+Backspace`: shell-backward-kill-word
- `Alt+Delete`: shell-kill-word

### Word navigation

Custom bindings exist for terminal-specific arrow escape sequences.

- `Ctrl+Left` / `Ctrl+Right`: move by word
- `Alt+Left` / `Alt+Right`: move by shell word

### Unbound keys

Several default readline bindings are intentionally removed so they can be repurposed elsewhere:

- `Alt+0` through `Alt+9`
- function keys `F1` through `F10`, plus `F12`
