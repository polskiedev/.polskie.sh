#!/bin/bash

substr() {
    local input="$1"
    local start="$2"
    local length="$3"
    echo "${input:start:length}"
}