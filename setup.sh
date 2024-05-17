#!/bin/bash

CONFIG_FILE=config.cfg

# Function to prompt the user for input and save to config file
function setup_config() {
    echo "First time setup:"
    
    read -p "Enter the repository link: " REPO_LINK
    read -p "Enter the id_rsa file location: " RSA_FILE
    read -p "Enter the user name for SSH connection: " SSH_USER
    read -p "Enter the IP address for SSH connection: " SSH_IP
    read -p "Enter the repository folder name (without extension): " REPO_FOLDER

    echo "REPO_LINK=$REPO_LINK" > $CONFIG_FILE
    echo "RSA_FILE=$RSA_FILE" >> $CONFIG_FILE
    echo "SSH_USER=$SSH_USER" >> $CONFIG_FILE
    echo "SSH_IP=$SSH_IP" >> $CONFIG_FILE
    echo "REPO_FOLDER=$REPO_FOLDER" >> $CONFIG_FILE

    setup_ssh_and_clone
}

# Function to setup SSH connection and clone the repository
function setup_ssh_and_clone() {
    source $CONFIG_FILE

    # Establish SSH connection and clone repository
    ssh -i $RSA_FILE $SSH_USER@$SSH_IP << EOF
        if [ ! -d "$REPO_FOLDER" ]; then
            git clone $REPO_LINK
        fi
        cd $REPO_FOLDER
        docker-compose up -d --build
EOF
}

# Function to reconnect and refresh the docker setup
function reconnect_and_refresh() {
    source $CONFIG_FILE

    ssh -i $RSA_FILE $SSH_USER@$SSH_IP << EOF
        cd $REPO_FOLDER
        docker-compose down
        docker-compose up -d --build
EOF
}

# Main script logic
if [ ! -f "$CONFIG_FILE" ]; then
    setup_config
else
    reconnect_and_refresh
fi
