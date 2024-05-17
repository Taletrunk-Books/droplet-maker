#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Update package index
echo "Updating package index..."
sudo apt update

# Install packages to allow apt to use a repository over HTTPS
echo "Installing necessary packages..."
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

# Add Docker’s official GPG key
echo "Adding Docker's GPG key..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

# Add Docker repository
echo "Adding Docker repository..."
sudo add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

# Update package index again
echo "Updating package index again..."
sudo apt update

# Install Docker
echo "Installing Docker..."
sudo apt install -y docker-ce

# Verify Docker installation
echo "Verifying Docker installation..."
sudo docker --version

# Enable Docker to start on boot
echo "Enabling Docker to start on boot..."
sudo systemctl enable docker

echo "Docker installation completed successfully!"

# Optional: Add the current user to the docker group to avoid using sudo for Docker commands
echo "Adding current user to the Docker group..."
sudo usermod -aG docker $USER

echo "Docker installation completed successfully!"

# Install Github CLI
echo "Installing Github CLI..."

# Download the latest version of GitHub CLI
sudo apt install gh

# Verify GitHub CLI installation
gh --version

echo "Github CLI installation completed successfully!"

# Loging to Github
echo "Logging to Github..."
gh auth login

echo "Github login completed successfully!"