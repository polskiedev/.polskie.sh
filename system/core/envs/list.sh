#!/bin/bash

__polskiesh_env_list() {
    # Using a Loop to Print All Environment Variables
    env | while IFS='=' read -r name value; do
        echo "$name=$value"
    done

    # echo 'export VARIABLE_NAME="value"' >> ~/.bashrc
}