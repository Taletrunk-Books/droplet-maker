#!/bin/bash

CONFIG_FILE=setup.cfg
GITIGNORE=.gitignore

function add_to_gitignore_if_not_exists() {
    if [ ! -f "$GITIGNORE" ]; then
        touch "$GITIGNORE"
    fi

    if ! grep -q "$CONFIG_FILE" "$GITIGNORE"; then
        echo "$CONFIG_FILE" >> "$GITIGNORE"
        echo "Added $CONFIG_FILE to $GITIGNORE"
    else
        echo "$CONFIG_FILE is already in $GITIGNORE"
    fi
}

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

    add_to_gitignore_if_not_exists

    setup_ssh_and_clone
}

# Function to setup SSH connection and clone the repository
function setup_ssh_and_clone() {
    source $CONFIG_FILE

    echo "Establishing SSH connection and cloning repository..."

    # Start the ssh-agent in the background
    eval "$(ssh-agent -s)"
    ssh-add $RSA_FILE

    # Establish SSH connection and clone repository
    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i $RSA_FILE $SSH_USER@$SSH_IP << EOF
        if [ ! -d "$REPO_FOLDER" ]; then
            echo "Repository not found. Cloning..."
            gh repo clone $REPO_LINK -- -b $BRANCH_NAME $REPO_FOLDER
        fi
        echo "Navigating to repository folder and setting up Docker..."
        cd $REPO_FOLDER
        docker compose up -d --build
EOF
}

# Function to reconnect and refresh the docker setup
function reconnect_and_refresh() {
    source $CONFIG_FILE

    echo "Reconnecting and refreshing Docker setup..."

    # Start the ssh-agent in the background
    eval "$(ssh-agent -s)"
    ssh-add $RSA_FILE

    ssh -i $RSA_FILE $SSH_USER@$SSH_IP << EOF
        echo "Navigating to repository folder..."
        cd $REPO_FOLDER
        echo "Pulling latest changes from $BRANCH_NAME..."
        git checkout $BRANCH_NAME
        git pull origin $BRANCH_NAME
        echo "Taking down Docker setup..."
        docker compose down
        echo "Cleaning up unused Docker resources..."
        docker system prune -f
        echo "Building and starting Docker setup..."
        docker compose build --no-cache
        docker compose up -d
EOF
}

# Function to clean up Docker space
function clean_docker_space() {
    source $CONFIG_FILE

    echo "Cleaning up Docker space..."

    # Start the ssh-agent in the background
    eval "$(ssh-agent -s)"
    ssh-add $RSA_FILE

    ssh -i $RSA_FILE $SSH_USER@$SSH_IP << EOF
        echo "Cleaning up unused Docker resources..."
        docker system prune -f
EOF
}

# Main script logic
BRANCH_NAME="main" # Default branch

while getopts "b:" opt; do
    case $opt in
        b) BRANCH_NAME=$OPTARG ;;
        \?) echo "Invalid option -$OPTARG" >&2; exit 1 ;;
    esac
done

if [[ $1 == "--clean" ]]; then
    if [ -f "$CONFIG_FILE" ]; then
        echo "Clean start requested. Deleting configuration file..."
        rm $CONFIG_FILE
    fi
elif [[ $1 == "--cleanup" ]]; then
    if [ -f "$CONFIG_FILE" ]; then
        echo "Cleaning up Docker space..."
        clean_docker_space
    else
        echo "Configuration file not found. Cannot clean Docker space without it."
    fi
elif [ ! -f "$CONFIG_FILE" ]; then
    echo "Configuration file not found. Setting up configuration..."
    setup_config
else
    echo "Configuration file found. Reconnecting and refreshing Docker setup..."
    reconnect_and_refresh
fi
