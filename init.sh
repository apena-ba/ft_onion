#!/bin/bash

# COLOURS

blue=$'\033[0;34m'
red=$'\033[0;31m'
yellow=$'\033[0;33m'
green=$'\033[0;32m'
reset=$'\033[0;39m'

# VARS

IMG_NAME='ft_onion-image'
CONT_NAME='ft_onion-container'

PUB_KEY_PATH="$HOME/.ssh/id_rsa.pub"
DOCKFILE_PATH='.'

LOGS_FILE_PATH='/dev/null' # Set to /dev/null if no logs wanted

# UTILS FUNCTIONS

function exitErr(){
    echo -n "$red""Error: " && echo "$1$reset"
    if $2; then
        rm -f ./temp_pub_key.pub
    fi
    exit 1
}

function askingLoop(){
    # Asks the user if the image present should be overwritten
    while true; do
        local res
        read -p "$1 called $yellow$2$reset was found, do you want to overwrite it? (y/n): $reset" res
        if [[ "$res" == [n] ]]; then
            echo -e "\n$1 called $yellow$2$reset was not overwritten, stopping"
            exit 0
        elif [[ "$res" == [y] ]]; then
            break
        else
            echo ''
        fi
    done
}

function handle_signal(){
    echo -e "\n$red\0Exiting$reset"
    exit 1
}

function parser(){
    # Checks if you can write into log file
    if ! [ -w "$LOGS_FILE_PATH" ]; then
        exitErr "Could not write into log file $yellow$LOGS_FILE_PATH$red, check permissions" false
    fi
    # Checks if docker commands work
    if ! docker ps >> "$LOGS_FILE_PATH" 2>&1 ; then
        exitErr "Docker commands not working, check if docker is running" false
    fi
    # Checks if the path to the public key provided is present and readable
    if ! [ -f "$PUB_KEY_PATH" ]; then
        exitErr "File $PUB_KEY_PATH does not exist" false
    elif ! [ -r "$PUB_KEY_PATH" ]; then
        exitErr "Could not access file $PUB_KEY_PATH, check permissions" false
    fi
}

# MAIN

function main(){
    # Handle SIGINT (ctrl-c) for clear exit
    trap handle_signal SIGINT
    parser
    # Checks if an image with the name provided is alredy in the system
    if docker images --format '{{.Repository}}' | grep -q "^$IMG_NAME$"; then
        askingLoop 'Image' "$IMG_NAME"
    fi
    if docker ps -a --format '{{.Names}}' | grep -q "^$CONT_NAME$"; then
        askingLoop 'Container' "$CONT_NAME"
        docker rm -f "$CONT_NAME"
    fi
    if ! cat "$PUB_KEY_PATH" > ./temp_pub_key.pub; then
        exitErr "Public key temporary file creation failed" false
    fi
    # Checks if docker commands fail
    if ! docker build -t "$IMG_NAME" "$DOCKFILE_PATH" >> "$LOGS_FILE_PATH" 2>&1; then
        exitErr "Could not build docker image" true
    fi
    echo -e "\n$green""Image called $yellow$IMG_NAME$green created successfully$reset"
    if ! docker run -d --name "$CONT_NAME" -p 80:80 -p 4242:4242 "$IMG_NAME" >> "$LOGS_FILE_PATH" 2>&1; then
        exitErr "Could not create docker container" true
    fi
    echo -e "\n$green""Container called $yellow$CONT_NAME$green created successfully$reset"
    rm -f ./temp_pub_key.pub 2>&1 >> "$LOGS_FILE_PATH"
    exit 0
}

main
