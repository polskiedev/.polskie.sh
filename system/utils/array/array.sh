#!/bin/bash

in_array() {
  local value="$1"
  shift
  local array=("$@")

  for element in "${array[@]}"; do
    if [[ "$element" == "$value" ]]; then
      return 0 # value found
    fi
  done

  return 1 # value not found
}