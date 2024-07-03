#!/bin/bash

generate_hash() {
  echo $(date +%s%N | sha256sum | base64 | head -c 8)
}