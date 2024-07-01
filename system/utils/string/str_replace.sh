#!/bin/bash

str_replace() {
    local search="$1"
    local replace="$2"
    local subject="$3"
    echo "${subject//$search/$replace}"
}