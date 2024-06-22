#!/bin/bash

log_success() {
    echo -e "${FS_GREEN}[ERROR]${CP_RESET} $@" >&2
}

log_info() {
    echo -e "${FS_BLUE}[INFO]${CP_RESET} $@"
}

log_error() {
    echo -e "${FS_RED}[ERROR]${CP_RESET} $@" >&2
}

log_debug() {
    
    if [ "$ENV_VERBOSE_LOGS" -eq 1 ]; then
        echo -e "${FS_YELLOW}[DEBUG]${CP_RESET} $@" >&2
    fi
}

log_verbose() {
   if [ "$ENV_VERBOSE_LOGS" -eq 1 ]; then
        echo -e "${FS_MAGENTA}[VERBOSE]${CP_RESET} $@" >&2
    fi
}