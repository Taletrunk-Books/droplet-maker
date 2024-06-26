# Droplet Maker

This project contains a script for setting up a new droplet with Docker and GitHub CLI pre-installed.

## Getting Started

These instructions will get you a copy of the project up and running on your remote machine for development and testing purposes.

### Prerequisites

- A Unix-like operating system: macOS, Linux, BSD.
- `bash`, `curl`, `sudo`

### Installation

Connect to your remote machine via SSH:

```sh
ssh -i path/to/your/private-key user@ip-address
```

Copy and paste the following commands into your terminal:

```sh
# Clone the repository
git clone https://github.com/Taletrunk-Books/droplet-maker.git

# Navigate to the project directory
cd droplet-maker

# Make the script executable
chmod +x make-droplet.sh

# Run the script
./make-droplet.sh
```

## Usage

After running the script, Docker and GitHub CLI will be installed on your machine. You can verify the installations with the following commands:

```sh
docker --version
gh --version
```
