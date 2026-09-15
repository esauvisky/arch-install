#!/usr/bin/env bash
# shellcheck disable=SC2139,SC1001,SC2155,SC1090,SC1091,SC2034
# Part of emishrc -- MANAGED FILE, overwritten on update. Edit ~/.bashrc instead.

### Python
if _e python || _e python3; then
    ##  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    ##  |d|i|s|a|b|l|e|_|v|e|n|v|_|p|r|o|m|p|t|
    ##  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    ## Disables the native embedded venv prompt so we can make our own
    export VIRTUAL_ENV_DISABLE_PROMPT=0
    _python_info() {
        # Create cache key based on environment state
        local cache_key="${PWD}:${VIRTUAL_ENV}:${PYENV_VERSION}:_python_info"
        local cache_trigger="${VIRTUAL_ENV}:${PYENV_VERSION}"

        # Try to get cached result
        if cached=$(_cache_get "$cache_key" "$_PROMPT_CACHE_TTL_PYTHON" "$cache_trigger" 2>/dev/null); then
            echo "$cached"
            return
        fi

        local pyenv_version pyenv_origin venv_origin
        local git_root_dir pyenv_info venv_info
        local py_version venv_version
        local py_major py_minor py_patch
        local venv_major venv_minor venv_patch
        local pyenv_major pyenv_minor pyenv_patch

        # Build output
        local out_info="$__BlueLight($__Reset"

        # Get git root directory (for path simplification) - reuse git root cache
        git_root_dir=""
        if _e git; then
            # Try to get from git prompt cache if available
            git_root_dir=$(git rev-parse --show-toplevel 2>/dev/null)
            if _e cygpath; then
                git_root_dir=$(cygpath "$git_root_dir" 2>/dev/null)
            fi
        fi

        # Get current python version (parse from pyvenv.cfg if in venv, else python binary)
        if [[ -n "$VIRTUAL_ENV" ]] && [[ -f "$VIRTUAL_ENV/pyvenv.cfg" ]]; then
            # Read python version from venv config (faster than invoking python)
            while IFS= read -r line; do
                if [[ $line == version* ]]; then
                    py_version="${line#*= }"
                    IFS='.' read -r py_major py_minor py_patch _ <<< "$py_version"
                    break
                fi
            done < "$VIRTUAL_ENV/pyvenv.cfg"
        else
            # Only invoke python if we really need to
            read -r py_major py_minor py_patch < <(python -c 'import sys; v=sys.version_info; print(f"{v.major} {v.minor} {v.micro}")' 2>/dev/null || echo "0 0 0")
        fi

        # Get pyenv information (only if PYENV_SHELL is set)
        if [[ -n "$PYENV_SHELL" ]]; then
            # Get pyenv version and origin
            pyenv_version=$(command pyenv version-name 2>/dev/null)
            pyenv_origin=$(command pyenv version-origin 2>/dev/null)

            if _e cygpath; then
                pyenv_origin=$(cygpath "$pyenv_origin" 2>/dev/null)
            fi

            # Simplify path replacements
            if [[ -n "$git_root_dir" && -n "$pyenv_origin" ]]; then
                pyenv_origin="${pyenv_origin#"$git_root_dir"/}"
            fi
            if [[ -n "$pyenv_origin" ]]; then
                pyenv_origin="${pyenv_origin/#"$HOME"/\~}"
            fi

            # Extract major.minor from pyenv version
            if [[ -n "$pyenv_version" ]]; then
                IFS='.' read -r pyenv_major pyenv_minor pyenv_patch _ <<< "$pyenv_version"

                if [[ "$py_major.$py_minor.$py_patch" == "$pyenv_major.$pyenv_minor.$pyenv_patch" ]]; then
                    pyenv_info="${__Reset}${__Blue}${pyenv_origin}:${__Bold}${pyenv_major}.${pyenv_minor}"
                else
                    out_info="$__BlueLight(${__Bold}$py_major.$py_minor.$py_patch$__ResetBold|"
                    pyenv_info="${__Reset}${__Red}${pyenv_origin}:${__Bold}${pyenv_version}"
                fi
            fi
        fi

        # Get virtualenv information (only if VIRTUAL_ENV is set)
        if [[ -n "$VIRTUAL_ENV" ]]; then
            venv_origin="$VIRTUAL_ENV"

            if _e "cygpath"; then
                venv_origin=$(cygpath "$venv_origin" 2>/dev/null)
            fi

            if [[ -n "$git_root_dir" && -n "$venv_origin" ]]; then
                venv_origin="${venv_origin#"$git_root_dir"/}"
            fi
            if [[ -n "$venv_origin" ]]; then
                venv_origin="${venv_origin/#"$HOME"/\~}"
            fi

            # Extract version from py_version (already read from pyvenv.cfg above)
            if [[ -n "$py_version" ]]; then
                IFS='.' read -r venv_major venv_minor venv_patch _ <<< "$py_version"
            fi

            if [[ "$py_major.$py_minor.$py_patch" == "$venv_major.$venv_minor.$venv_patch" ]]; then
                venv_info="${__Reset}${__BlueLight}${venv_origin}${__Bold}:${venv_major}.${venv_minor}"
            else
                out_info="$__BlueLight(${__Bold}$py_major.$py_minor.$py_patch$__ResetBold|"
                venv_info="${__Reset}${__Red}${venv_origin}:${__Bold}${venv_major}.${venv_minor}.${venv_patch}"
            fi
        fi

        # Build final output
        if [[ -n "$pyenv_info" && -n "$venv_info" ]]; then
            out_info="$out_info${pyenv_info}$__BlueLight|${__Reset}${venv_info}$__BlueLight)${__Reset}"
        elif [[ -n "$pyenv_info" ]]; then
            out_info="$out_info${pyenv_info}$__BlueLight)$__Reset"
        elif [[ -n "$venv_info" ]]; then
            out_info="$out_info${venv_info}$__BlueLight)$__Reset"
        else
            # No python env to display - cache this result too (prevents repeated expensive checks)
            _cache_set "$cache_key" "" "$cache_trigger"
            return
        fi

        # Cache the result
        _cache_set "$cache_key" "$out_info" "$cache_trigger"
        echo "$out_info"
    }

    function pip() {
        local cmd="$1"

        if _e "pipman" && [[ "$cmd" == "install" && -z "$VIRTUAL_ENV" ]]; then
            shift

            local params=()  # I seriously hate bash
            for param in "$@"; do
                if [[ "$param" != "--break-system-packages" ]]; then
                    params+=("$param")
                fi
            done

            mkdir -p "$HOME/.pipman"
            echo -e '\e[01;93mCreating PKGBUILDs...\e[00m'
            pipman -t "$HOME/.pipman" -S "${params[@]}"
        else
            command pip "$@"
        fi
    }

    function venv() {
        local python_version python_executable

        # Check if pyenv is available
        if ! _e "pyenv"; then
            echo "pyenv is not available. Creating venv with system python..."
            python3 -m venv .venv
            source .venv/bin/activate
            return
        fi

        # If an argument is provided, use it as the python version
        if [[ $# -eq 1 ]]; then
            python_version="$1"
        else
            # Get available python versions from pyenv
            local versions=()
            readarray -t versions < <(pyenv versions --bare | grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | sort -V)

            if [[ ${#versions[@]} -eq 0 ]]; then
                echo "No Python versions found in pyenv. Install one with: pyenv install <version>"
                return 1
            fi

            echo "Available Python versions:"
            select_option "${versions[@]}" "Type custom version"
            local choice=$?

            if [[ $choice -eq $((${#versions[@]})) ]]; then
                # User chose to type custom version
                echo -n "Enter Python version: "
                read -r python_version
            else
                python_version="${versions[$choice]}"
            fi
        fi

        # Check if the specified version is installed
        if ! pyenv versions --bare | grep -q "^${python_version}$"; then
            echo "Python $python_version is not installed. Installing..."
            if ! pyenv install "$python_version"; then
                echo "Failed to install Python $python_version"
                return 1
            fi
        fi

        # Get the python executable path
        python_executable="$(pyenv prefix "$python_version")/bin/python"

        if [[ ! -x "$python_executable" ]]; then
            echo "Python executable not found at $python_executable"
            return 1
        fi

        echo "Creating virtual environment with Python $python_version..."

        # Remove existing .venv if it exists
        if [[ -d ".venv" ]]; then
            echo "Removing existing .venv directory..."
            rm -rf .venv
        fi

        # Create the virtual environment
        if "$python_executable" -m venv .venv; then
            echo "Virtual environment created successfully."
            echo "Activating virtual environment..."
            source .venv/bin/activate
            echo "Virtual environment activated. Python version: $(python --version)"
        else
            echo "Failed to create virtual environment"
            return 1
        fi
    }
fi
