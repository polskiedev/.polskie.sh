#!/bin/bash
# devenv_precmd
source $(realpath "$HOME/.devenv.sources.sh")

test() {
    echo "Testing 'logs' function"

    log_success "Success log message"
    log_info "Info log message"
    log_error "Error log message"
    log_debug "Debug log message"
    log_verbose "Verbose log message"
}

test