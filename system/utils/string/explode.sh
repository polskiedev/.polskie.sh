#!/bin/bash

explode() {
    local delimiter="$1"
    local string="$2"
    local array=()

    IFS="$delimiter" read -r -a array <<< "$string"
    echo "${array[@]}"
}