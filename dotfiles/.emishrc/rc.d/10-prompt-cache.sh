#!/usr/bin/env bash
# shellcheck disable=SC2139,SC1001,SC2155,SC1090,SC1091,SC2034
# Part of emishrc -- MANAGED FILE, overwritten on update. Edit ~/.bashrc instead.


###  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
###  |P|r|o|m|p|t| |C|a|c|h|e| |I|n|f|r|a|s|t|r|u|c|t|u|r|e|
###  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
# Cache system for optimizing expensive prompt operations
# Reduces git/python subprocess calls and file reads

# Cache configuration (customize in ~/.bashrc if needed)
: "${_PROMPT_CACHE_TTL_GIT:=2}"        # Git cache TTL in seconds
: "${_PROMPT_CACHE_TTL_PYTHON:=5}"     # Python cache TTL in seconds
: "${_PROMPT_CACHE_TTL_PWD:=1}"        # PWD cache TTL in seconds
: "${_VTE_CACHE_TTL:=5}"               # VTE prompt cache TTL in seconds

# Initialize cache arrays (associative arrays for cache key->value storage)
declare -gA _PROMPT_CACHE_DATA=()      # Cache data: key -> value
declare -gA _PROMPT_CACHE_TIME=()      # Cache timestamp: key -> time
declare -gA _PROMPT_CACHE_TRIGGER=()   # Cache trigger: key -> trigger_value

# Helper function: Check if cache is still valid
# Usage: _cache_is_valid "key" "ttl" ["trigger_value"]
_cache_is_valid() {
    local key="$1"
    local ttl="$2"
    local trigger_value="${3:-}"
    local current_time=$(date +%s)

    # If key doesn't exist, cache is invalid
    [[ -z "${_PROMPT_CACHE_DATA[$key]:-}" ]] && return 1

    # Check timestamp expiry
    local cache_time="${_PROMPT_CACHE_TIME[$key]:-0}"
    if (( current_time - cache_time > ttl )); then
        return 1  # Cache expired
    fi

    # If trigger value is provided, check if it changed
    if [[ -n "$trigger_value" ]]; then
        local cached_trigger="${_PROMPT_CACHE_TRIGGER[$key]:-}"
        if [[ "$cached_trigger" != "$trigger_value" ]]; then
            return 1  # Trigger changed, cache invalid
        fi
    fi

    return 0  # Cache is valid
}

# Helper function: Set cache value
# Usage: _cache_set "key" "value" ["trigger_value"]
_cache_set() {
    local key="$1"
    local value="$2"
    local trigger_value="${3:-}"

    _PROMPT_CACHE_DATA[$key]="$value"
    _PROMPT_CACHE_TIME[$key]=$(date +%s)
    _PROMPT_CACHE_TRIGGER[$key]="$trigger_value"
}

# Helper function: Get cached value if valid, otherwise return empty
# Usage: _cache_get "key" "ttl" ["trigger_value"]
_cache_get() {
    local key="$1"
    local ttl="$2"
    local trigger_value="${3:-}"

    if _cache_is_valid "$key" "$ttl" "$trigger_value"; then
        echo "${_PROMPT_CACHE_DATA[$key]}"
        return 0
    fi
    return 1
}
