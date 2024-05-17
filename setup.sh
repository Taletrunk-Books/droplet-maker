#!/bin/bash

CONFIG_FILE=setup.cfg

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

    echo "Configuration saved. Setting up SSH and cloning repository..."
    setup_ssh_and_clone
}

# Function to setup SSH connection and clone the repository
function setup_ssh_and_clone() {
    source $CONFIG_FILE

    echo "Establishing SSH connection and cloning repository..."
    # Prompt for passphrase
    read -s -p "Enter the passphrase for the SSH key: " SSH_PASSPHRASE
    echo

    # Start the ssh-agent in the background
    eval "$(ssh-agent -s)"
    # Add your SSH private key to the ssh-agent
    echo $SSH_PASSPHRASE | ssh-add $RSA_FILE

    # Establish SSH connection and clone repository
    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i $RSA_FILE $SSH_USER@$SSH_IP << EOF
        if [ ! -d "$REPO_FOLDER" ]; then
            echo "Repository not found. Cloning..."
            git clone $REPO_LINK
        fi
        echo "Navigating to repository folder and setting up Docker..."
        cd $REPO_FOLDER
        docker-compose up -d --build
EOF
}

# Function to reconnect and refresh the docker setup
function reconnect_and_refresh() {
    source $CONFIG_FILE

    echo "Reconnecting and refreshing Docker setup..."
    # Prompt for passphrase
    read -s -p "Enter the passphrase for the SSH key: " SSH_PASSPHRASE
    echo

    # Start the ssh-agent in the background
    eval "$(ssh-agent -s)"
    # Add your SSH private key to the ssh-agent
    echo $SSH_PASSPHRASE | ssh-add $RSA_FILE

    ssh -i $RSA_FILE $SSH_USER@$SSH_IP << EOF
        echo "Navigating to repository folder..."
        cd $REPO_FOLDER
        echo "Taking down Docker setup..."
        docker-compose down
        echo "Building and starting Docker setup..."
        docker-compose up -d --build
EOF
}

# Main script logic
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Configuration file not found. Setting up configuration..."
    setup_config
else
    echo "Configuration file found. Reconnecting and refreshing Docker setup..."
    reconnect_and_refresh
fi