#!/bin/bash

__polskiesh_log_message() {
    local color="${1:-$FS_WHITE}"
    local title="${2:-"MESSAGE"}"

    shift; shift

    echo -e "${color}[${title}]${CP_RESET} $@" >&2
}

log_success() {
    __polskiesh_log_message "$FS_GREEN" "SUCCESS" "$@"
}

log_info() {
    __polskiesh_log_message "$FS_BLUE" "INFO" "$@"
}

log_error() {
    __polskiesh_log_message "$FS_RED" "ERROR" "$@"
}

log_debug() {
    
    if [ "$ENV_VERBOSE_LOGS" -eq 1 ]; then
        __polskiesh_log_message "$FS_YELLOW" "DEBUG" "$@"
    fi
}

log_verbose() {
   if [ "$ENV_VERBOSE_LOGS" -eq 1 ]; then
        __polskiesh_log_message "$FS_MAGENTA" "VERBOSE" "$@"
    fi
}