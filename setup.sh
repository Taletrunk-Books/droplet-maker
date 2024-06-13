#!/bin/bash

GITIGNORE=.gitignore

# Function to add configuration file to .gitignore
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
    echo "First time setup for environment: $ENV"

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

    echo "Configuration saved for $ENV environment. Setting up SSH and cloning repository..."

    add_to_gitignore_if_not_exists

    setup_ssh_and_clone
}

# Function to setup SSH connection and clone the repository
function setup_ssh_and_clone() {
    source $CONFIG_FILE

    echo "Establishing SSH connection and cloning repository for $ENV environment..."

    # Start the ssh-agent in the background
    eval "$(ssh-agent -s)"
    ssh-add $RSA_FILE

    # Establish SSH connection and clone repository
    ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i $RSA_FILE $SSH_USER@$SSH_IP << EOF
        if [ ! -d "$REPO_FOLDER" ]; then
            echo "Repository not found. Cloning..."
            gh repo clone $REPO_LINK
        fi
        echo "Navigating to repository folder and setting up Docker..."
        cd $REPO_FOLDER
        $(copy_env_file)  # Copy .env file
        docker compose -f docker-compose.yml up -d --build
EOF
}

# Function to reconnect and refresh the docker setup
function reconnect_and_refresh() {
    source $CONFIG_FILE

    echo "Reconnecting and refreshing Docker setup for $ENV environment..."

    # Start the ssh-agent in the background
    eval "$(ssh-agent -s)"
    ssh-add $RSA_FILE

    ssh -i $RSA_FILE $SSH_USER@$SSH_IP << EOF
        echo "Navigating to repository folder..."
        cd $REPO_FOLDER
        echo "Pulling latest changes from $BRANCH_NAME..."
        git checkout $BRANCH_NAME
        git pull origin $BRANCH_NAME
        $(copy_env_file)  # Copy .env file
        echo "Taking down Docker setup..."
        docker compose -f docker-compose.yml down
        echo "Cleaning up unused Docker resources..."
        docker system prune -f
        echo "Building and starting Docker setup..."
        docker compose -f docker-compose.yml build --no-cache
        docker compose -f docker-compose.yml up -d
EOF
}

# Function to clean up Docker space
function clean_docker_space() {
    source $CONFIG_FILE

    echo "Cleaning up Docker space for $ENV environment..."

    # Start the ssh-agent in the background
    eval "$(ssh-agent -s)"
    ssh-add $RSA_FILE

    ssh -i $RSA_FILE $SSH_USER@$SSH_IP << EOF
        echo "Cleaning up unused Docker resources..."
        docker system prune -f
EOF
}

# Function to copy .env file to project directory
function copy_env_file() {
    local local_env_file=".env"
    local remote_project_dir="$REPO_FOLDER"

    if [ -f "$local_env_file" ]; then
        echo "Copying .env file to the project directory..."
        scp -i $RSA_FILE $local_env_file $SSH_USER@$SSH_IP:$remote_project_dir/.env
    else
        echo ".env file not found in the local directory."
    fi
}

# Main script logic
BRANCH_NAME="dev" # Default branch
ENV="dev"          # Default environment

PARSED_OPTIONS=$(getopt -o b:e: --long branch:,env:,clean,cleanup -- "$@")
if [[ $? -ne 0 ]]; then
    echo "Invalid option" >&2
    exit 1
fi

eval set -- "$PARSED_OPTIONS"

while true; do
    case "$1" in
        -b|--branch)
            BRANCH_NAME=$2
            shift 2
            ;;
        -e|--env)
            ENV=$2
            shift 2
            ;;
        --clean)
            CLEAN=true
            shift
            ;;
        --cleanup)
            CLEANUP=true
            shift
            ;;
        --)
            shift
            break
            ;;
        *)
            echo "Invalid option" >&2
            exit 1
            ;;
    esac
done

CONFIG_FILE="setup_${ENV}.cfg"

if [[ $CLEAN == true ]]; then
    if [ -f "$CONFIG_FILE" ]; then
        echo "Clean start requested for $ENV environment. Deleting configuration file..."
        rm $CONFIG_FILE
    fi
fi

if [[ $CLEANUP == true ]]; then
    if [ -f "$CONFIG_FILE" ]; then
        echo "Cleaning up Docker space for $ENV environment..."
        clean_docker_space
    else
        echo "Configuration file not found for $ENV environment. Cannot clean Docker space without it."
    fi
fi

if [ ! -f "$CONFIG_FILE" ]; then
    echo "Configuration file not found for $ENV environment. Setting up configuration..."
    setup_config
else
    echo "Configuration file found for $ENV environment. Reconnecting and refreshing Docker setup..."
    reconnect_and_refresh
fi
